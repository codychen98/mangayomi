import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:mangayomi/eval/model/m_manga.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/changed.dart';
import 'package:mangayomi/models/chapter.dart';
import 'package:mangayomi/models/history.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/models/update.dart';
import 'package:mangayomi/modules/mass_migration/models/mass_migration_models.dart';
import 'package:mangayomi/modules/manga/detail/providers/isar_providers.dart';
import 'package:mangayomi/modules/more/settings/sync/providers/sync_providers.dart';
import 'package:mangayomi/services/get_detail.dart';
import 'package:mangayomi/services/search.dart';
import 'package:mangayomi/utils/extensions/string_extensions.dart';

Future<void> migrateLibraryItem({
  required WidgetRef ref,
  required Manga oldManga,
  required MManga selectedManga,
  required MManga preview,
  required Source destinationSource,
}) async {
  final migrationSnapshot = _captureMigrationSnapshot(
    ref: ref,
    oldManga: oldManga,
  );
  _rewriteMigratedItemMetadata(
    oldManga: oldManga,
    selectedManga: selectedManga,
    preview: preview,
    destinationSource: destinationSource,
  );
  _syncMigratedMangaFromPreview(
    oldManga: oldManga,
    preview: preview,
    destinationSource: destinationSource,
  );
  _restoreMigrationProgress(oldManga: oldManga, snapshot: migrationSnapshot);
  ref.invalidate(getMangaDetailStreamProvider(mangaId: oldManga.id!));
}

class _MigrationSnapshot {
  const _MigrationSnapshot({
    required this.chaptersProgress,
    this.historyChapter,
    this.historyDate,
  });

  final List<Chapter> chaptersProgress;
  final String? historyChapter;
  final String? historyDate;
}

_MigrationSnapshot _captureMigrationSnapshot({
  required WidgetRef ref,
  required Manga oldManga,
}) {
  String? historyChapter;
  String? historyDate;
  final chaptersProgress = <Chapter>[];

  isar.writeTxnSync(() {
    final histories = isar.historys
        .filter()
        .mangaIdEqualTo(oldManga.id)
        .sortByDate()
        .findAllSync();
    historyChapter = extractMigrationChapterNumber(
      histories.lastOrNull?.chapter.value?.name ?? '',
    );
    historyDate = histories.lastOrNull?.date;
    for (final history in histories) {
      isar.historys.deleteSync(history.id!);
      ref
          .read(synchingProvider(syncId: 1).notifier)
          .addChangedPart(ActionType.removeHistory, history.id, '{}', false);
    }
    for (final chapter in oldManga.chapters) {
      chaptersProgress.add(chapter);
      isar.updates
          .filter()
          .mangaIdEqualTo(chapter.mangaId)
          .chapterNameEqualTo(chapter.name)
          .deleteAllSync();
      isar.chapters.deleteSync(chapter.id!);
      ref
          .read(synchingProvider(syncId: 1).notifier)
          .addChangedPart(ActionType.removeChapter, chapter.id, '{}', false);
    }
  });

  return _MigrationSnapshot(
    chaptersProgress: chaptersProgress,
    historyChapter: historyChapter,
    historyDate: historyDate,
  );
}

void _rewriteMigratedItemMetadata({
  required Manga oldManga,
  required MManga selectedManga,
  required MManga preview,
  required Source destinationSource,
}) {
  isar.writeTxnSync(() {
    oldManga.name = selectedManga.name;
    oldManga.link = selectedManga.link;
    oldManga.imageUrl = selectedManga.imageUrl;
    oldManga.lang = destinationSource.lang;
    oldManga.source = destinationSource.name;
    oldManga.sourceId = destinationSource.id;
    oldManga.artist = preview.artist;
    oldManga.author = preview.author;
    oldManga.status = preview.status ?? oldManga.status;
    oldManga.description = preview.description;
    oldManga.genre = preview.genre;
    oldManga.updatedAt = DateTime.now().millisecondsSinceEpoch;
    isar.mangas.putSync(oldManga);
  });
}

void _syncMigratedMangaFromPreview({
  required Manga oldManga,
  required MManga preview,
  required Source destinationSource,
}) {
  final genre =
      preview.genre
          ?.map((entry) => entry.toString().trim())
          .where((entry) => entry.isNotEmpty)
          .toSet()
          .toList() ??
      [];

  final previewImageUrl = preview.imageUrl.trimmedOrDefault(oldManga.imageUrl);
  oldManga
    ..imageUrl = previewImageUrl == null
        ? null
        : previewImageUrl.startsWith('http')
        ? previewImageUrl
        : '${destinationSource.baseUrl ?? ''}/${previewImageUrl.getUrlWithoutDomain}'
    ..name = preview.name.trimmedOrDefault(oldManga.name)
    ..genre = genre.isEmpty ? oldManga.genre ?? [] : genre
    ..author = preview.author.trimmedOrDefault(oldManga.author) ?? ''
    ..artist = preview.artist.trimmedOrDefault(oldManga.artist) ?? ''
    ..status = preview.status == Status.unknown
        ? oldManga.status
        : preview.status ?? Status.unknown
    ..description =
        preview.description.trimmedOrDefault(oldManga.description) ?? ''
    ..link = preview.link.trimmedOrDefault(oldManga.link)
    ..source = destinationSource.name
    ..lang = destinationSource.lang
    ..itemType = destinationSource.itemType
    ..lastUpdate = DateTime.now().millisecondsSinceEpoch
    ..updatedAt = DateTime.now().millisecondsSinceEpoch;

  isar.writeTxnSync(() {
    final mangaId = isar.mangas.putSync(oldManga);
    final previewChapters = preview.chapters ?? const [];
    final chapters = previewChapters
        .map(
          (previewChapter) => Chapter(
            name: previewChapter.name ?? '',
            url: previewChapter.url?.trim() ?? '',
            dateUpload: previewChapter.dateUpload == null
                ? DateTime.now().millisecondsSinceEpoch.toString()
                : previewChapter.dateUpload.toString(),
            scanlator: previewChapter.scanlator ?? '',
            mangaId: mangaId,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
            isFiller: previewChapter.isFiller,
            thumbnailUrl: previewChapter.thumbnailUrl,
            description: previewChapter.description,
            downloadSize: previewChapter.downloadSize,
            duration: previewChapter.duration,
          )..manga.value = oldManga,
        )
        .toList();
    for (final chapter in chapters.reversed) {
      isar.chapters.putSync(chapter);
      chapter.manga.saveSync();
    }
  });
}

void _restoreMigrationProgress({
  required Manga oldManga,
  required _MigrationSnapshot snapshot,
}) {
  isar.writeTxnSync(() {
    for (final oldChapter in snapshot.chaptersProgress) {
      final chapter = isar.chapters
          .filter()
          .mangaIdEqualTo(oldManga.id)
          .nameContains(
            extractMigrationChapterNumber(oldChapter.name ?? '') ?? '.....',
            caseSensitive: false,
          )
          .findFirstSync();
      if (chapter != null) {
        chapter.isBookmarked = oldChapter.isBookmarked;
        chapter.lastPageRead = oldChapter.lastPageRead;
        chapter.isRead = oldChapter.isRead;
        isar.chapters.putSync(chapter);
      }
    }

    final historyChapter = isar.chapters
        .filter()
        .mangaIdEqualTo(oldManga.id)
        .nameContains(snapshot.historyChapter ?? '.....', caseSensitive: false)
        .findFirstSync();
    if (historyChapter != null) {
      isar.historys.putSync(
        History(
          mangaId: oldManga.id,
          date:
              snapshot.historyDate ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          itemType: oldManga.itemType,
          chapterId: historyChapter.id,
        )..chapter.value = historyChapter,
      );
    }
  });
}

Future<MassMigrationSearchResult> findBestMassMigrationMatch({
  required WidgetRef ref,
  required Manga manga,
  required Source destinationSource,
}) async {
  // Match single-anime migrate: search the exact library title and keep the
  // source's first result (source ranking), without alternate queries/re-rank.
  final query = (manga.name ?? manga.author ?? '').trim();
  final queries = query.isEmpty ? const <String>[] : <String>[query];

  if (query.isEmpty) {
    return const MassMigrationSearchResult(queries: [], candidates: []);
  }

  final pages = await ref.read(
    searchProvider(
      source: destinationSource,
      page: 1,
      query: query,
      filterList: const [],
    ).future,
  );
  final candidates = pages?.list ?? const <MManga>[];
  if (candidates.isEmpty) {
    return MassMigrationSearchResult(queries: queries, candidates: const []);
  }

  return MassMigrationSearchResult(
    queries: queries,
    usedQuery: query,
    candidates: candidates,
    selected: candidates.first,
  );
}

Future<MassMigrationResolvedItem> resolveMassMigrationItem({
  required WidgetRef ref,
  required Manga manga,
  required Source destinationSource,
}) async {
  try {
    final searchResult = await _resolveSearchResult(
      ref: ref,
      manga: manga,
      destinationSource: destinationSource,
    );
    return await _resolveMatchedPreview(
      ref: ref,
      manga: manga,
      destinationSource: destinationSource,
      searchResult: searchResult,
    );
  } catch (error) {
    return _buildErroredResolvedItem(
      sourceItem: manga,
      errorMessage: error.toString(),
    );
  }
}

Future<MassMigrationSearchResult> _resolveSearchResult({
  required WidgetRef ref,
  required Manga manga,
  required Source destinationSource,
}) {
  return findBestMassMigrationMatch(
    ref: ref,
    manga: manga,
    destinationSource: destinationSource,
  );
}

Future<MassMigrationResolvedItem> _resolveMatchedPreview({
  required WidgetRef ref,
  required Manga manga,
  required Source destinationSource,
  required MassMigrationSearchResult searchResult,
}) async {
  final selectedCandidate = searchResult.selected;
  if (selectedCandidate == null) {
    return MassMigrationResolvedItem(
      sourceItem: manga,
      searchResult: searchResult,
    );
  }

  final titleMismatch = massMigrationTitlesDiffer(
    manga.name,
    selectedCandidate.name,
  );

  try {
    final preview = await ref.read(
      getDetailProvider(
        url: selectedCandidate.link!,
        source: destinationSource,
      ).future,
    );
    return MassMigrationResolvedItem(
      sourceItem: manga,
      searchResult: searchResult,
      selectedCandidate: selectedCandidate,
      destinationPreview: preview,
      shouldMigrate: true,
      titleMismatch: titleMismatch,
    );
  } catch (error) {
    return MassMigrationResolvedItem(
      sourceItem: manga,
      searchResult: searchResult,
      selectedCandidate: selectedCandidate,
      errorMessage: error.toString(),
      titleMismatch: titleMismatch,
    );
  }
}

MassMigrationResolvedItem _buildErroredResolvedItem({
  required Manga sourceItem,
  required String errorMessage,
}) {
  return MassMigrationResolvedItem(
    sourceItem: sourceItem,
    searchResult: MassMigrationSearchResult(
      queries: buildMassMigrationQueries(sourceItem),
      candidates: const [],
    ),
    errorMessage: errorMessage,
  );
}

List<String> buildMassMigrationQueries(Manga manga) {
  final query = (manga.name ?? manga.author ?? '').trim();
  return query.isEmpty ? const [] : [query];
}

String? extractMigrationChapterNumber(String chapterName) {
  return RegExp(
        r'\s*(\d+\.\d+)\s*',
        multiLine: true,
      ).firstMatch(chapterName)?.group(0) ??
      RegExp(r'\s*(\d+)\s*', multiLine: true).firstMatch(chapterName)?.group(0);
}
