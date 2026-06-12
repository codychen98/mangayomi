import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/category.dart';
import 'package:mangayomi/models/chapter.dart';
import 'package:mangayomi/models/history.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/settings.dart';
import 'package:mangayomi/models/track.dart';
import 'package:mangayomi/models/update.dart';
import 'package:mangayomi/modules/more/settings/appearance/providers/blend_level_state_provider.dart';
import 'package:mangayomi/modules/more/settings/appearance/providers/flex_scheme_color_state_provider.dart';
import 'package:mangayomi/modules/more/settings/appearance/providers/pure_black_dark_mode_state_provider.dart';
import 'package:mangayomi/modules/more/settings/appearance/providers/theme_mode_state_provider.dart';
import 'package:mangayomi/modules/more/settings/browse/providers/browse_state_provider.dart';
import 'package:mangayomi/providers/l10n_providers.dart';
import 'package:mangayomi/services/sync/sync_snapshot.dart';

String normalizeSyncKeyPart(String? value) => (value ?? '').trim().toLowerCase();

/// Composite library key: itemType + source + link + name.
String mangaSyncKey(Manga manga) =>
    '${manga.itemType.index}|${normalizeSyncKeyPart(manga.source)}|'
    '${normalizeSyncKeyPart(manga.link)}|${normalizeSyncKeyPart(manga.name)}';

/// Composite category key: forItemType + name.
String categorySyncKey(Category category) =>
    '${category.forItemType.index}|${normalizeSyncKeyPart(category.name)}';

/// Composite chapter key: parent library key + url + name.
String chapterSyncKey(String parentMangaKey, Chapter chapter) =>
    '$parentMangaKey|${normalizeSyncKeyPart(chapter.url)}|'
    '${normalizeSyncKeyPart(chapter.name)}';

/// Composite track key: itemType + syncId + mediaId + parent library key.
String trackSyncKey(Track track, String parentMangaKey) =>
    '${track.itemType.index}|${track.syncId}|${track.mediaId}|$parentMangaKey';

/// Composite history key: itemType + parent library key + chapter url + name.
String historySyncKey(
  History history,
  String parentMangaKey,
  String chapterUrl,
  String chapterName,
) =>
    '${history.itemType.index}|$parentMangaKey|'
    '${normalizeSyncKeyPart(chapterUrl)}|${normalizeSyncKeyPart(chapterName)}';

/// Composite update key: parent library key + chapter name.
String updateSyncKey(String parentMangaKey, String? chapterName) =>
    '$parentMangaKey|${normalizeSyncKeyPart(chapterName)}';

bool _isRemoteNewer(int? localUpdatedAt, int? remoteUpdatedAt) =>
    (remoteUpdatedAt ?? 0) >= (localUpdatedAt ?? 0);

Manga _copyManga(Manga manga) => Manga.fromJson(manga.toJson());

Category _copyCategory(Category category) =>
    Category.fromJson(category.toJson());

Chapter _copyChapter(Chapter chapter) => Chapter.fromJson(chapter.toJson());

Track _copyTrack(Track track) => Track.fromJson(track.toJson());

History _copyHistory(History history) => History.fromJson(history.toJson());

Update _copyUpdate(Update update) => Update.fromJson(update.toJson());

Settings _copySettings(Settings settings) => Settings.fromJson(settings.toJson());

Map<int, String> _mangaIdToSyncKey(List<Manga> manga) {
  return {
    for (final entry in manga)
      if (entry.id != null) entry.id!: mangaSyncKey(entry),
  };
}

Map<int, String> _categoryIdToSyncKey(List<Category> categories) {
  return {
    for (final entry in categories)
      if (entry.id != null) entry.id!: categorySyncKey(entry),
  };
}

Map<int, Chapter> _chaptersById(List<Chapter> chapters) {
  return {
    for (final chapter in chapters)
      if (chapter.id != null) chapter.id!: chapter,
  };
}

List<int>? _remapCategoryIds(
  List<int>? categoryIds,
  Map<int, String> sourceIdToKey,
  Map<String, Category> mergedCategoriesByKey,
) {
  if (categoryIds == null) {
    return null;
  }
  return categoryIds
      .map((id) => sourceIdToKey[id])
      .whereType<String>()
      .map((key) => mergedCategoriesByKey[key]?.id)
      .whereType<int>()
      .toList();
}

Manga _mergeMangaEntry({
  required Manga local,
  required Manga remote,
  required Map<int, String> localCategoryIdToKey,
  required Map<int, String> remoteCategoryIdToKey,
  required Map<String, Category> mergedCategoriesByKey,
}) {
  final pickRemote = _isRemoteNewer(local.updatedAt, remote.updatedAt);
  final source = pickRemote ? remote : local;
  final sourceCategoryIdToKey =
      pickRemote ? remoteCategoryIdToKey : localCategoryIdToKey;
  final winner = _copyManga(source);
  winner.categories = _remapCategoryIds(
    source.categories,
    sourceCategoryIdToKey,
    mergedCategoriesByKey,
  );
  return winner;
}

List<Category> _mergeCategories(
  List<Category> local,
  List<Category> remote,
) {
  final merged = <String, Category>{};
  for (final category in local) {
    merged[categorySyncKey(category)] = _copyCategory(category);
  }
  for (final category in remote) {
    final key = categorySyncKey(category);
    final existing = merged[key];
    if (existing == null) {
      merged[key] = _copyCategory(category);
      continue;
    }
    if (_isRemoteNewer(existing.updatedAt, category.updatedAt)) {
      merged[key] = _copyCategory(category);
    }
  }
  return merged.values.toList();
}

List<Manga> _mergeManga(
  List<Manga> local,
  List<Manga> remote,
  List<Category> localCategories,
  List<Category> remoteCategories,
  List<Category> mergedCategories,
) {
  final mergedCategoriesByKey = {
    for (final category in mergedCategories) categorySyncKey(category): category,
  };
  final localCategoryIdToKey = _categoryIdToSyncKey(localCategories);
  final remoteCategoryIdToKey = _categoryIdToSyncKey(remoteCategories);

  final merged = <String, Manga>{};
  for (final manga in local) {
    final copy = _copyManga(manga);
    copy.categories = _remapCategoryIds(
      copy.categories,
      localCategoryIdToKey,
      mergedCategoriesByKey,
    );
    merged[mangaSyncKey(manga)] = copy;
  }
  for (final manga in remote) {
    final key = mangaSyncKey(manga);
    final existing = merged[key];
    if (existing == null) {
      final copy = _copyManga(manga);
      copy.categories = _remapCategoryIds(
        copy.categories,
        remoteCategoryIdToKey,
        mergedCategoriesByKey,
      );
      merged[key] = copy;
      continue;
    }
    merged[key] = _mergeMangaEntry(
      local: local.firstWhere((e) => mangaSyncKey(e) == key),
      remote: manga,
      localCategoryIdToKey: localCategoryIdToKey,
      remoteCategoryIdToKey: remoteCategoryIdToKey,
      mergedCategoriesByKey: mergedCategoriesByKey,
    );
  }

  return merged.values.toList();
}

List<Chapter> _mergeChapters(
  List<Chapter> local,
  List<Chapter> remote,
  List<Manga> localManga,
  List<Manga> remoteManga,
  List<Manga> mergedManga,
) {
  final localMangaKeys = _mangaIdToSyncKey(localManga);
  final remoteMangaKeys = _mangaIdToSyncKey(remoteManga);
  final mergedMangaByKey = {
    for (final manga in mergedManga) mangaSyncKey(manga): manga,
  };

  final merged = <String, Chapter>{};

  void addChapters(
    List<Chapter> chapters,
    Map<int, String> mangaIdToKey,
    bool isRemote,
  ) {
    for (final chapter in chapters) {
      final parentKey = mangaIdToKey[chapter.mangaId];
      if (parentKey == null) {
        continue;
      }
      final key = chapterSyncKey(parentKey, chapter);
      final existing = merged[key];
      if (existing == null) {
        final copy = _copyChapter(chapter);
        copy.mangaId = mergedMangaByKey[parentKey]?.id;
        merged[key] = copy;
        continue;
      }
      final shouldReplace = isRemote
          ? _isRemoteNewer(existing.updatedAt, chapter.updatedAt)
          : !_isRemoteNewer(existing.updatedAt, chapter.updatedAt);
      if (shouldReplace) {
        final copy = _copyChapter(chapter);
        copy.mangaId = mergedMangaByKey[parentKey]?.id;
        merged[key] = copy;
      }
    }
  }

  addChapters(local, localMangaKeys, false);
  addChapters(remote, remoteMangaKeys, true);
  return merged.values.toList();
}

List<Track> _mergeTracks(
  List<Track> local,
  List<Track> remote,
  List<Manga> localManga,
  List<Manga> remoteManga,
  List<Manga> mergedManga,
) {
  final localMangaKeys = _mangaIdToSyncKey(localManga);
  final remoteMangaKeys = _mangaIdToSyncKey(remoteManga);
  final mergedMangaByKey = {
    for (final manga in mergedManga) mangaSyncKey(manga): manga,
  };

  final merged = <String, Track>{};

  void addTracks(
    List<Track> tracks,
    Map<int, String> mangaIdToKey,
    bool isRemote,
  ) {
    for (final track in tracks) {
      final parentKey = mangaIdToKey[track.mangaId];
      if (parentKey == null) {
        continue;
      }
      final key = trackSyncKey(track, parentKey);
      final existing = merged[key];
      if (existing == null) {
        final copy = _copyTrack(track);
        copy.mangaId = mergedMangaByKey[parentKey]?.id;
        merged[key] = copy;
        continue;
      }
      final shouldReplace = isRemote
          ? _isRemoteNewer(existing.updatedAt, track.updatedAt)
          : !_isRemoteNewer(existing.updatedAt, track.updatedAt);
      if (shouldReplace) {
        final copy = _copyTrack(track);
        copy.mangaId = mergedMangaByKey[parentKey]?.id;
        merged[key] = copy;
      }
    }
  }

  addTracks(local, localMangaKeys, false);
  addTracks(remote, remoteMangaKeys, true);
  return merged.values.toList();
}

List<History> _mergeHistories(
  List<History> local,
  List<History> remote,
  List<Manga> localManga,
  List<Manga> remoteManga,
  List<Manga> mergedManga,
  List<Chapter> localChapters,
  List<Chapter> remoteChapters,
  List<Chapter> mergedChapters,
) {
  final localMangaKeys = _mangaIdToSyncKey(localManga);
  final remoteMangaKeys = _mangaIdToSyncKey(remoteManga);
  final mergedMangaByKey = {
    for (final manga in mergedManga) mangaSyncKey(manga): manga,
  };
  final localChaptersById = _chaptersById(localChapters);
  final remoteChaptersById = _chaptersById(remoteChapters);
  final mergedMangaById = {
    for (final manga in mergedManga)
      if (manga.id != null) manga.id!: manga,
  };
  final mergedChaptersByKey = <String, Chapter>{};
  for (final chapter in mergedChapters) {
    final parent = mergedMangaById[chapter.mangaId];
    if (parent == null) {
      continue;
    }
    mergedChaptersByKey[chapterSyncKey(mangaSyncKey(parent), chapter)] = chapter;
  }

  final merged = <String, History>{};

  void addHistories(
    List<History> histories,
    Map<int, String> mangaIdToKey,
    Map<int, Chapter> chaptersById,
    bool isRemote,
  ) {
    for (final history in histories) {
      final parentKey = mangaIdToKey[history.mangaId];
      final chapter = chaptersById[history.chapterId];
      if (parentKey == null || chapter == null) {
        continue;
      }
      final key = historySyncKey(
        history,
        parentKey,
        chapter.url ?? '',
        chapter.name ?? '',
      );
      final existing = merged[key];
      if (existing == null) {
        final copy = _copyHistory(history);
        copy.mangaId = mergedMangaByKey[parentKey]?.id;
        copy.chapterId =
            mergedChaptersByKey[chapterSyncKey(parentKey, chapter)]?.id;
        merged[key] = copy;
        continue;
      }
      final shouldReplace = isRemote
          ? _isRemoteNewer(existing.updatedAt, history.updatedAt)
          : !_isRemoteNewer(existing.updatedAt, history.updatedAt);
      if (shouldReplace) {
        final copy = _copyHistory(history);
        copy.mangaId = mergedMangaByKey[parentKey]?.id;
        copy.chapterId =
            mergedChaptersByKey[chapterSyncKey(parentKey, chapter)]?.id;
        merged[key] = copy;
      }
    }
  }

  addHistories(local, localMangaKeys, localChaptersById, false);
  addHistories(remote, remoteMangaKeys, remoteChaptersById, true);
  return merged.values.toList();
}

List<Update> _mergeUpdates(
  List<Update> local,
  List<Update> remote,
  List<Manga> localManga,
  List<Manga> remoteManga,
  List<Manga> mergedManga,
) {
  final localMangaKeys = _mangaIdToSyncKey(localManga);
  final remoteMangaKeys = _mangaIdToSyncKey(remoteManga);
  final mergedMangaByKey = {
    for (final manga in mergedManga) mangaSyncKey(manga): manga,
  };

  final merged = <String, Update>{};

  void addUpdates(
    List<Update> updates,
    Map<int, String> mangaIdToKey,
    bool isRemote,
  ) {
    for (final update in updates) {
      final parentKey = mangaIdToKey[update.mangaId];
      if (parentKey == null) {
        continue;
      }
      final key = updateSyncKey(parentKey, update.chapterName);
      final existing = merged[key];
      if (existing == null) {
        final copy = _copyUpdate(update);
        copy.mangaId = mergedMangaByKey[parentKey]?.id;
        merged[key] = copy;
        continue;
      }
      final shouldReplace = isRemote
          ? _isRemoteNewer(existing.updatedAt, update.updatedAt)
          : !_isRemoteNewer(existing.updatedAt, update.updatedAt);
      if (shouldReplace) {
        final copy = _copyUpdate(update);
        copy.mangaId = mergedMangaByKey[parentKey]?.id;
        merged[key] = copy;
      }
    }
  }

  addUpdates(local, localMangaKeys, false);
  addUpdates(remote, remoteMangaKeys, true);
  return merged.values.toList();
}

List<Settings> _mergeSettings(
  List<Settings> local,
  List<Settings> remote,
) {
  if (local.isEmpty && remote.isEmpty) {
    return const [];
  }
  if (local.isEmpty) {
    return [_copySettings(remote.first)];
  }
  if (remote.isEmpty) {
    return [_copySettings(local.first)];
  }
  final pickRemote =
      _isRemoteNewer(local.first.updatedAt, remote.first.updatedAt);
  return [_copySettings(pickRemote ? remote.first : local.first)];
}

/// Merges [local] and [remote] snapshots using composite keys and [updatedAt].
SyncSnapshot mergeSyncSnapshots(SyncSnapshot local, SyncSnapshot remote) {
  final mergedCategories = _mergeCategories(local.categories, remote.categories);
  final mergedManga = _mergeManga(
    local.manga,
    remote.manga,
    local.categories,
    remote.categories,
    mergedCategories,
  );
  final mergedChapters = _mergeChapters(
    local.chapters,
    remote.chapters,
    local.manga,
    remote.manga,
    mergedManga,
  );
  final mergedTracks = _mergeTracks(
    local.tracks,
    remote.tracks,
    local.manga,
    remote.manga,
    mergedManga,
  );
  final mergedHistory = _mergeHistories(
    local.history,
    remote.history,
    local.manga,
    remote.manga,
    mergedManga,
    local.chapters,
    remote.chapters,
    mergedChapters,
  );
  final mergedUpdates = _mergeUpdates(
    local.updates,
    remote.updates,
    local.manga,
    remote.manga,
    mergedManga,
  );
  final mergedSettings = _mergeSettings(local.settings, remote.settings);

  return SyncSnapshot(
    version: SyncSnapshot.snapshotVersion,
    manga: mergedManga,
    categories: mergedCategories,
    chapters: mergedChapters,
    tracks: mergedTracks,
    history: mergedHistory,
    updates: mergedUpdates,
    settings: mergedSettings,
  );
}

/// Applies a merged snapshot to Isar (full replace for synced entity types).
Future<void> applySyncSnapshotToDatabase(SyncSnapshot merged, Ref ref) async {
  await isar.writeTxn(() async {
    isar.categorys.clearSync();
    if (merged.categories.isNotEmpty) {
      await isar.categorys.putAll(merged.categories);
    }

    isar.mangas.clearSync();
    if (merged.manga.isNotEmpty) {
      await isar.mangas.putAll(merged.manga);
    }

    isar.chapters.clearSync();
    for (final chapter in merged.chapters) {
      final manga = await isar.mangas.get(chapter.mangaId!);
      if (manga != null) {
        await isar.chapters.put(chapter..manga.value = manga);
        await chapter.manga.save();
      }
    }

    isar.tracks.clearSync();
    if (merged.tracks.isNotEmpty) {
      await isar.tracks.putAll(merged.tracks);
    }

    isar.historys.clearSync();
    for (final history in merged.history) {
      final chapter = await isar.chapters.get(history.chapterId!);
      if (chapter != null) {
        await isar.historys.put(history..chapter.value = chapter);
        await history.chapter.save();
      }
    }

    isar.updates.clearSync();
    for (final update in merged.updates) {
      final chapter = await isar.chapters
          .filter()
          .mangaIdEqualTo(update.mangaId)
          .nameEqualTo(update.chapterName)
          .findFirst();
      if (chapter != null) {
        await isar.updates.put(update..chapter.value = chapter);
        await update.chapter.save();
      }
    }

    if (merged.settings.isNotEmpty) {
      final oldSettings = isar.settings.getSync(227)!;
      final settings = _copySettings(merged.settings.first);
      await isar.settings.put(settings..cookiesList = oldSettings.cookiesList);
      ref.invalidate(followSystemThemeStateProvider);
      ref.invalidate(themeModeStateProvider);
      ref.invalidate(blendLevelStateProvider);
      ref.invalidate(flexSchemeColorStateProvider);
      ref.invalidate(pureBlackDarkModeStateProvider);
      ref.invalidate(l10nLocaleStateProvider);
      ref.invalidate(extensionsRepoStateProvider(ItemType.manga));
      ref.invalidate(extensionsRepoStateProvider(ItemType.anime));
      ref.invalidate(extensionsRepoStateProvider(ItemType.novel));
    }
  });
}
