import 'package:isar_community/isar.dart';
import 'package:mangayomi/eval/model/m_bridge.dart';
import 'package:mangayomi/utils/chapter_recognition.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/changed.dart';
import 'package:mangayomi/models/chapter.dart';
import 'package:mangayomi/models/download.dart';
import 'package:mangayomi/models/history.dart';
import 'package:mangayomi/models/update.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/modules/more/settings/sync/providers/sync_providers.dart';
import 'package:mangayomi/services/get_detail.dart';
import 'package:mangayomi/services/library_update_preferences_service.dart';
import 'package:mangayomi/utils/extensions/string_extensions.dart';
import 'package:mangayomi/utils/fetch_interval.dart';
import 'package:mangayomi/utils/orphan_chapter_policy.dart';
import 'package:mangayomi/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'update_manga_detail_providers.g.dart';

@riverpod
Future<dynamic> updateMangaDetail(
  Ref ref, {
  required int? mangaId,
  required bool isInit,
  bool showToast = true,
}) async {
  try {
    final manga = isar.mangas.getSync(mangaId!);
    if (manga == null) return;

    // loadSync() so .isNotEmpty is reliable (IsarLinks are lazy by default).
    manga.chapters.loadSync();

    if ((manga.isLocalArchive ?? false) ||
        (manga.chapters.isNotEmpty && isInit)) {
      return;
    }
    final source = getSource(
      manga.lang!,
      manga.source!,
      manga.sourceId,
      installedOnly: true,
    );
    if (source == null) return;

    final detailProvider = getDetailProvider(url: manga.link!, source: source);
    if (!isInit) {
      ref.invalidate(detailProvider);
    }
    final getManga = await ref.read(detailProvider.future);

    final genre =
        getManga.genre
            ?.map((e) => e.toString().trim())
            .toList()
            .toSet()
            .toList() ??
        [];

    final imgUrl = getManga.imageUrl.trimmedOrDefault(manga.imageUrl);
    final now = DateTime.now().millisecondsSinceEpoch;

    manga
      ..imageUrl = imgUrl == null
          ? null
          : imgUrl.startsWith('http')
          ? imgUrl
          : '${source.baseUrl ?? ''}/${imgUrl.getUrlWithoutDomain}'
      ..name = getManga.name.trimmedOrDefault(manga.name)
      ..genre = (genre.isEmpty ? null : genre) ?? manga.genre ?? []
      ..author = getManga.author.trimmedOrDefault(manga.author) ?? ""
      ..artist = getManga.artist.trimmedOrDefault(manga.artist) ?? ""
      ..status = getManga.status == Status.unknown
          ? manga.status
          : getManga.status ?? Status.unknown
      ..description =
          getManga.description.trimmedOrDefault(manga.description) ?? ""
      ..link = getManga.link.trimmedOrDefault(manga.link)
      ..source = manga.source
      ..lang = manga.lang
      ..itemType = source.itemType
      ..lastUpdate = now
      ..updatedAt = now;

    final chaps = getManga.chapters;
    var unseenUpdatesToAdd = 0;
    final removeMissing =
        getLibraryUpdatePreferences().removeMissingChaptersOnUpdate;

    await isar.writeTxn(() async {
      // Persist updated manga metadata.
      final savedMangaId = await isar.mangas.put(manga);

      if (chaps == null || chaps.isEmpty) return;

      // loadSync() was called before the transaction; the set is still valid
      // here because we haven't written to chapters yet.
      final existingChapters = manga.chapters.toList();
      final existingByUrl = <String, Chapter>{
        for (final c in existingChapters)
          if (c.url?.isNotEmpty == true) c.url!.trim(): c,
      };

      // Build a chapterNumber -> isRead map so that when a new scanlator covers
      // a chapter the user has already read, the new entry is pre-marked read.
      // The value is true if ANY existing chapter at that number is read.
      final recognition = ChapterRecognition();
      final readByNumber = <int, bool>{};
      for (final c in existingChapters) {
        if (c.name == null) continue;
        final num = recognition.parseChapterNumber(manga.name ?? '', c.name!);
        if (num > 0) {
          readByNumber[num] =
              (readByNumber[num] ?? false) || (c.isRead ?? false);
        }
      }

      final newChapters = <Chapter>[];

      for (final chap in chaps) {
        final url = chap.url?.trim();
        if (url == null || url.isEmpty) continue;
        final existing = existingByUrl[url];

        if (existing == null) {
          // Determine whether this chapter number has already been read under
          // a different scanlator, so we don't show it as unread to the user.
          final chapNum = chap.name != null
              ? recognition.parseChapterNumber(manga.name!, chap.name!)
              : 0;
          final alreadyRead = chapNum > 0 && (readByNumber[chapNum] ?? false);

          final newChapter = Chapter(
            name: chap.name!,
            url: url,
            dateUpload: chap.dateUpload == null
                ? now.toString()
                : chap.dateUpload.toString(),
            scanlator: chap.scanlator ?? '',
            mangaId: savedMangaId,
            updatedAt: now,
            isFiller: chap.isFiller,
            thumbnailUrl: chap.thumbnailUrl,
            description: chap.description,
            downloadSize: chap.downloadSize,
            duration: chap.duration,
          )..manga.value = manga;

          // Carry over read state if another scanlator's version was read.
          if (alreadyRead) {
            newChapter.isRead = alreadyRead;
            newChapter.lastPageRead = "1";
          }

          newChapters.add(newChapter);
        } else {
          // Existing chapter - refresh metadata only.
          existing
            ..name = chap.name
            ..scanlator = chap.scanlator
            ..updatedAt = now
            ..isFiller = chap.isFiller
            ..thumbnailUrl = chap.thumbnailUrl
            ..description = chap.description
            ..downloadSize = chap.downloadSize
            ..duration = chap.duration;
          await isar.chapters.put(existing);
        }
      }

      // Insert new chapters oldest-first (API typically returns newest-first).
      if (newChapters.isNotEmpty) {
        final hasExisting = existingChapters.isNotEmpty;
        var newUpdateCount = 0;
        for (final chap in newChapters.reversed) {
          await isar.chapters.put(chap);
          await chap.manga.save();

          // Only create an Update entry for genuinely new (unread) chapters,
          // so that pre-read cross-scanlator chapters don't spam the updates feed.
          if (hasExisting && !(chap.isRead ?? false)) {
            final update = Update(
              mangaId: savedMangaId,
              chapterName: chap.name,
              date: now.toString(),
              updatedAt: now,
            )..chapter.value = chap;
            await isar.updates.put(update);
            await update.chapter.save();
            newUpdateCount++;
          }
        }
        unseenUpdatesToAdd = newUpdateCount;
      }

      // Drop orphans no longer on the source (pref on; keep fully downloaded).
      final deletedChapterIds = <int>{};
      if (removeMissing) {
        final sourceUrls = sourceUrlSet(chaps.map((c) => c.url));
        final syncNotifier = ref.read(synchingProvider(syncId: 1).notifier);
        for (final chapter in existingChapters) {
          final id = chapter.id;
          if (id == null) continue;
          final download = await isar.downloads.get(id);
          if (!shouldDeleteOrphan(
            isOrphan: isOrphanChapterUrl(chapter.url, sourceUrls),
            isFullyDownloaded: download?.isDownload == true,
            removeMissingEnabled: true,
            sourceListNonEmpty: sourceUrls.isNotEmpty,
          )) {
            continue;
          }
          await _deleteOrphanChapterCascade(
            chapter: chapter,
            download: download,
            syncNotifier: syncNotifier,
          );
          deletedChapterIds.add(id);
        }
      }

      // Calculate fetch interval:
      // median of gaps between recent distinct chapter dates, clamped [1, 28].
      final remainingExisting = [
        for (final c in existingChapters)
          if (c.id == null || !deletedChapterIds.contains(c.id)) c,
      ];
      final allChapters = [...remainingExisting, ...newChapters];
      if (allChapters.isNotEmpty) {
        final interval = FetchInterval.calculateInterval(allChapters);
        manga
          ..id = savedMangaId
          ..smartUpdateDays = interval;
        await isar.mangas.put(manga);
      }
    });

    if (unseenUpdatesToAdd > 0) {
      incrementUnseenUpdatesCount(manga.itemType, unseenUpdatesToAdd);
    }
  } catch (e, s) {
    if (showToast) {
      botToast('$e\n$s');
    } else {
      rethrow;
    }
  }
}

/// Updates + history + incomplete download + chapter; mirrors `_removeImport`
/// cascade for a single chapter. History is removed so Continue/history cannot
/// point at a deleted chapter id. On-disk download files are left untouched
/// (only fully downloaded orphans are kept, and those skip this path).
Future<void> _deleteOrphanChapterCascade({
  required Chapter chapter,
  required Download? download,
  required Synching syncNotifier,
}) async {
  final id = chapter.id!;

  final updates = await isar.updates
      .filter()
      .mangaIdEqualTo(chapter.mangaId)
      .chapterNameEqualTo(chapter.name)
      .findAll();
  for (final update in updates) {
    await isar.updates.delete(update.id!);
    syncNotifier.addChangedPart(ActionType.removeUpdate, update.id, "{}", false);
  }

  final histories = await isar.historys
      .filter()
      .chapterIdEqualTo(id)
      .findAll();
  for (final history in histories) {
    await isar.historys.delete(history.id!);
    syncNotifier.addChangedPart(
      ActionType.removeHistory,
      history.id,
      "{}",
      false,
    );
  }

  if (download != null) {
    await isar.downloads.delete(id);
  }

  await isar.chapters.delete(id);
  syncNotifier.addChangedPart(ActionType.removeChapter, id, "{}", false);
}
