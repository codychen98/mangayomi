import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:mangayomi/eval/model/m_manga.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'bulk_favorite_provider.g.dart';

@immutable
class FeedBulkScope {
  const FeedBulkScope({required this.itemType, this.sourceId});

  final ItemType itemType;
  final int? sourceId;

  @override
  bool operator ==(Object other) {
    return other is FeedBulkScope &&
        other.itemType == itemType &&
        other.sourceId == sourceId;
  }

  @override
  int get hashCode => Object.hash(itemType, sourceId);
}

@immutable
class FeedSelectionEntry {
  const FeedSelectionEntry({
    required this.sourceId,
    required this.sourceName,
    required this.sourceLang,
    required this.itemType,
    required this.link,
    required this.manga,
  });

  final int sourceId;
  final String sourceName;
  final String sourceLang;
  final ItemType itemType;
  final String link;
  final MManga manga;

  String get key => '$sourceId|$link';
}

FeedSelectionEntry feedSelectionEntry({
  required MManga manga,
  required int sourceId,
  required String sourceName,
  required String sourceLang,
  required ItemType itemType,
}) {
  final link = manga.link ?? manga.name ?? '';
  return FeedSelectionEntry(
    sourceId: sourceId,
    sourceName: sourceName,
    sourceLang: sourceLang,
    itemType: itemType,
    link: link,
    manga: manga,
  );
}

@riverpod
class FeedBulkSelectionMode extends _$FeedBulkSelectionMode {
  @override
  bool build(FeedBulkScope scope) => false;

  void toggle() {
    final next = !state;
    state = next;
    if (!next) {
      ref.read(feedBulkSelectionProvider(scope).notifier).clear();
    }
  }

  void setMode(bool value) {
    state = value;
    if (!value) {
      ref.read(feedBulkSelectionProvider(scope).notifier).clear();
    }
  }
}

@riverpod
class FeedBulkSelection extends _$FeedBulkSelection {
  @override
  Map<String, FeedSelectionEntry> build(FeedBulkScope scope) => {};

  void select(FeedSelectionEntry entry) {
    state = {...state, entry.key: entry};
  }

  void toggle(FeedBulkScope scope, FeedSelectionEntry entry) {
    final next = Map<String, FeedSelectionEntry>.from(state);
    if (next.containsKey(entry.key)) {
      next.remove(entry.key);
    } else {
      next[entry.key] = entry;
    }
    state = next;
    if (next.isEmpty) {
      ref.read(feedBulkSelectionModeProvider(scope).notifier).setMode(false);
    }
  }

  void enterWith(FeedBulkScope scope, FeedSelectionEntry entry) {
    ref.read(feedBulkSelectionModeProvider(scope).notifier).setMode(true);
    select(entry);
  }

  void clear() => state = {};
}

@riverpod
class FeedBulkFavoriteRunning extends _$FeedBulkFavoriteRunning {
  @override
  bool build(FeedBulkScope scope) => false;

  void setRunning(bool value) => state = value;
}

class FeedBulkFavoriteResult {
  const FeedBulkFavoriteResult({
    required this.mangas,
    required this.errors,
  });

  final List<Manga> mangas;
  final List<String> errors;
}

Future<Manga> findOrCreateMangaFromFeedEntry(FeedSelectionEntry entry) async {
  final getManga = entry.manga;
  final source = entry.sourceName;
  final lang = entry.sourceLang;
  final sourceId = entry.sourceId;
  final itemType = entry.itemType;

  final manga = Manga(
    imageUrl: getManga.imageUrl,
    name: getManga.name!.trim(),
    genre: getManga.genre?.map((e) => e.toString()).toList() ?? [],
    author: getManga.author ?? '',
    status: getManga.status ?? Status.unknown,
    description: getManga.description ?? '',
    link: getManga.link,
    source: source,
    lang: lang,
    lastUpdate: 0,
    itemType: itemType,
    artist: getManga.artist ?? '',
    sourceId: sourceId,
  );

  final empty = await isar.mangas
      .filter()
      .langEqualTo(lang)
      .nameEqualTo(manga.name)
      .sourceEqualTo(manga.source)
      .isEmpty();
  if (empty) {
    await isar.writeTxn(() async {
      await isar.mangas.put(
        manga..updatedAt = DateTime.now().millisecondsSinceEpoch,
      );
    });
  }

  final foundMangas = await isar.mangas
      .filter()
      .langEqualTo(lang)
      .nameEqualTo(manga.name)
      .sourceEqualTo(manga.source)
      .findAll();

  Manga? matchedManga;
  for (final foundManga in foundMangas) {
    if (foundManga.sourceId == null || foundManga.sourceId == sourceId) {
      matchedManga = foundManga;
      break;
    }
  }

  if (matchedManga == null) {
    await isar.writeTxn(() async {
      await isar.mangas.put(
        manga..updatedAt = DateTime.now().millisecondsSinceEpoch,
      );
    });
    matchedManga = manga;
  }

  if (matchedManga.sourceId == null) {
    await isar.writeTxn(() async {
      await isar.mangas.put(matchedManga!..sourceId = sourceId);
    });
  }

  await _ensureMangaSettingsEntry(matchedManga.id!);
  return matchedManga;
}

Future<void> _ensureMangaSettingsEntry(int mangaId) async {
  final settings = await isar.settings.get(227);
  if (settings == null) return;

  final exists =
      settings.sortChapterList?.any((e) => e.mangaId == mangaId) ?? false;
  if (exists) return;

  await isar.writeTxn(() async {
    settings
      ..sortChapterList = [
        ...(settings.sortChapterList ?? []),
        SortChapter()..mangaId = mangaId,
      ]
      ..chapterFilterBookmarkedList = [
        ...(settings.chapterFilterBookmarkedList ?? []),
        ChapterFilterBookmarked()..mangaId = mangaId,
      ]
      ..chapterFilterDownloadedList = [
        ...(settings.chapterFilterDownloadedList ?? []),
        ChapterFilterDownloaded()..mangaId = mangaId,
      ]
      ..chapterFilterUnreadList = [
        ...(settings.chapterFilterUnreadList ?? []),
        ChapterFilterUnread()..mangaId = mangaId,
      ]
      ..updatedAt = DateTime.now().millisecondsSinceEpoch;
    await isar.settings.put(settings);
  });
}

Future<FeedBulkFavoriteResult> resolveFeedSelectionEntries(
  List<FeedSelectionEntry> entries,
) async {
  final mangas = <Manga>[];
  final errors = <String>[];

  for (final entry in entries) {
    try {
      mangas.add(await findOrCreateMangaFromFeedEntry(entry));
    } catch (error) {
      errors.add('${entry.manga.name ?? entry.link}: $error');
    }
  }

  return FeedBulkFavoriteResult(mangas: mangas, errors: errors);
}
