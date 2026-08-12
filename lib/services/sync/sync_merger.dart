import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:mangayomi/eval/model/source_preference.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/category.dart';
import 'package:mangayomi/models/chapter.dart';
import 'package:mangayomi/models/history.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/feed_saved_search.dart';
import 'package:mangayomi/models/saved_search.dart';
import 'package:mangayomi/models/settings.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/models/track.dart';
import 'package:mangayomi/models/update.dart';
import 'package:mangayomi/modules/more/settings/appearance/providers/blend_level_state_provider.dart';
import 'package:mangayomi/modules/more/settings/appearance/providers/flex_scheme_color_state_provider.dart';
import 'package:mangayomi/modules/more/settings/appearance/providers/pure_black_dark_mode_state_provider.dart';
import 'package:mangayomi/modules/more/settings/appearance/providers/theme_mode_state_provider.dart';
import 'package:mangayomi/modules/more/settings/browse/providers/browse_state_provider.dart';
import 'package:mangayomi/providers/l10n_providers.dart';
import 'package:mangayomi/services/sync/device_local_settings.dart';
import 'package:mangayomi/services/sync/library_category_sort_sync.dart';
import 'package:mangayomi/services/sync/sync_entity_keys.dart';
import 'package:mangayomi/services/sync/sync_snapshot.dart';
import 'package:mangayomi/services/sync/sync_tombstone.dart';

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
    return [stripDeviceLocalSettings(_copySettings(remote.first))];
  }
  if (remote.isEmpty) {
    return [_copySettings(local.first)];
  }
  final pickRemote =
      _isRemoteNewer(local.first.updatedAt, remote.first.updatedAt);
  final merged = _copySettings(pickRemote ? remote.first : local.first);
  return [preserveDeviceLocalSettings(merged, local.first)];
}

String _sourcePreferenceKey(SourcePreference preference) =>
    '${preference.sourceId}|${normalizeSyncKeyPart(preference.key)}';

String _sourcePreferenceStringValueKey(SourcePreferenceStringValue value) =>
    '${value.sourceId}|${normalizeSyncKeyPart(value.key)}';

SourcePreference _copySourcePreference(SourcePreference preference) =>
    SourcePreference.fromJson(preference.toJson());

SourcePreferenceStringValue _copySourcePreferenceStringValue(
  SourcePreferenceStringValue value,
) => SourcePreferenceStringValue.fromJson(value.toJson());

List<SourcePreference> _mergeExtensionsPreferences(
  List<SourcePreference> local,
  List<SourcePreference> remote,
) {
  final merged = <String, SourcePreference>{};
  for (final preference in local) {
    merged[_sourcePreferenceKey(preference)] = _copySourcePreference(preference);
  }
  for (final preference in remote) {
    merged[_sourcePreferenceKey(preference)] = _copySourcePreference(preference);
  }
  return merged.values.toList();
}

List<SourcePreferenceStringValue> _mergeExtensionsPreferenceStringValues(
  List<SourcePreferenceStringValue> local,
  List<SourcePreferenceStringValue> remote,
) {
  final merged = <String, SourcePreferenceStringValue>{};
  for (final value in local) {
    merged[_sourcePreferenceStringValueKey(value)] =
        _copySourcePreferenceStringValue(value);
  }
  for (final value in remote) {
    merged[_sourcePreferenceStringValueKey(value)] =
        _copySourcePreferenceStringValue(value);
  }
  return merged.values.toList();
}

Source _copySource(Source source) {
  final copy = Source.fromJson(source.toJson());
  copy.itemType = source.itemType;
  return copy;
}

List<Source> _mergeExtensions(List<Source> local, List<Source> remote) {
  final merged = <String, Source>{};
  for (final source in local) {
    merged[extensionSyncKey(source)] = _copySource(source);
  }
  for (final source in remote) {
    final key = extensionSyncKey(source);
    final existing = merged[key];
    if (existing == null) {
      merged[key] = _copySource(source);
      continue;
    }
    if (_isRemoteNewer(existing.updatedAt, source.updatedAt)) {
      merged[key] = _copySource(source);
    }
  }
  return merged.values.toList();
}

List<SavedSearch> _mergeSavedSearches(
  List<SavedSearch> local,
  List<SavedSearch> remote,
) {
  final merged = <String, SavedSearch>{};
  for (final search in local) {
    merged[savedSearchSyncKey(search)] = SavedSearch.fromJson(search.toJson());
  }
  for (final search in remote) {
    final key = savedSearchSyncKey(search);
    final existing = merged[key];
    if (existing == null) {
      merged[key] = SavedSearch.fromJson(search.toJson());
      continue;
    }
    if (_isRemoteNewer(existing.updatedAt, search.updatedAt)) {
      merged[key] = SavedSearch.fromJson(search.toJson());
    }
  }
  return merged.values.toList();
}

List<FeedSavedSearch> _mergeFeedSavedSearches({
  required List<FeedSavedSearch> local,
  required List<FeedSavedSearch> remote,
  required List<SavedSearch> localSavedSearches,
  required List<SavedSearch> remoteSavedSearches,
}) {
  final localIdToKey = savedSearchIdToSyncKey(localSavedSearches);
  final remoteIdToKey = savedSearchIdToSyncKey(remoteSavedSearches);
  final merged = <String, FeedSavedSearch>{};

  void addFeeds(
    List<FeedSavedSearch> feeds,
    Map<int, String> idToKey, {
    required bool isRemote,
  }) {
    for (final feed in feeds) {
      final key = feedSavedSearchSyncKey(feed, idToKey);
      final existing = merged[key];
      final copy = FeedSavedSearch.fromJson(feed.toJson());
      if (existing == null) {
        merged[key] = copy;
        continue;
      }
      final shouldReplace = isRemote
          ? _isRemoteNewer(existing.updatedAt, feed.updatedAt)
          : !_isRemoteNewer(existing.updatedAt, feed.updatedAt);
      if (shouldReplace) {
        merged[key] = copy;
      }
    }
  }

  addFeeds(local, localIdToKey, isRemote: false);
  addFeeds(remote, remoteIdToKey, isRemote: true);
  return merged.values.toList();
}

List<SyncTombstone> _mergeTombstones(
  List<SyncTombstone> local,
  List<SyncTombstone> remote,
) {
  final merged = <String, SyncTombstone>{};
  for (final tombstone in [...local, ...remote]) {
    final composite = '${tombstone.entity.index}|${tombstone.key}';
    final existing = merged[composite];
    if (existing == null || tombstone.deletedAt >= existing.deletedAt) {
      merged[composite] = tombstone;
    }
  }
  return merged.values.toList();
}

bool _isTombstoned({
  required SyncTombstoneEntity entity,
  required String key,
  required List<SyncTombstone> tombstones,
  required int? itemUpdatedAt,
}) {
  for (final tombstone in tombstones) {
    if (tombstone.entity == entity &&
        tombstone.key == key &&
        tombstone.deletedAt >= (itemUpdatedAt ?? 0)) {
      return true;
    }
  }
  return false;
}

List<Source> _filterExtensionsByTombstones(
  List<Source> extensions,
  List<SyncTombstone> tombstones,
) {
  return extensions
      .where(
        (extension) => !_isTombstoned(
          entity: SyncTombstoneEntity.extension,
          key: extensionSyncKey(extension),
          tombstones: tombstones,
          itemUpdatedAt: extension.updatedAt,
        ),
      )
      .toList();
}

List<SavedSearch> _filterSavedSearchesByTombstones(
  List<SavedSearch> savedSearches,
  List<SyncTombstone> tombstones,
) {
  return savedSearches
      .where(
        (search) => !_isTombstoned(
          entity: SyncTombstoneEntity.savedSearch,
          key: savedSearchSyncKey(search),
          tombstones: tombstones,
          itemUpdatedAt: search.updatedAt,
        ),
      )
      .toList();
}

List<FeedSavedSearch> _filterFeedsByTombstones(
  List<FeedSavedSearch> feeds,
  List<SavedSearch> savedSearches,
  List<SyncTombstone> tombstones,
) {
  final idToKey = savedSearchIdToSyncKey(savedSearches);
  return feeds
      .where(
        (feed) => !_isTombstoned(
          entity: SyncTombstoneEntity.feed,
          key: feedSavedSearchSyncKey(feed, idToKey),
          tombstones: tombstones,
          itemUpdatedAt: feed.updatedAt,
        ),
      )
      .toList();
}

List<FeedSavedSearch> _remapFeedSavedSearchIds(
  List<FeedSavedSearch> feeds,
  List<SavedSearch> mergedSavedSearches,
  List<SavedSearch> sourceSavedSearches,
) {
  final sourceIdToKey = savedSearchIdToSyncKey(sourceSavedSearches);
  final keyToMergedId = <String, int>{
    for (final search in mergedSavedSearches)
      if (search.id != null) savedSearchSyncKey(search): search.id!,
  };

  return feeds.map((feed) {
    final copy = FeedSavedSearch.fromJson(feed.toJson());
    if (feed.savedSearchId == null) {
      copy.savedSearchId = null;
      return copy;
    }
    final key = sourceIdToKey[feed.savedSearchId];
    copy.savedSearchId = key == null ? null : keyToMergedId[key];
    return copy;
  }).toList();
}

void _uninstallExtensionLocally(int sourceId) {
  final source = isar.sources.getSync(sourceId);
  if (source == null) {
    return;
  }

  final preferenceIds = isar.sourcePreferences
      .filter()
      .sourceIdEqualTo(sourceId)
      .findAllSync()
      .map((e) => e.id!)
      .toList();
  final preferenceStringIds = isar.sourcePreferenceStringValues
      .filter()
      .sourceIdEqualTo(sourceId)
      .findAllSync()
      .map((e) => e.id)
      .toList();

  if (source.isObsolete ?? false) {
    isar.sources.deleteSync(sourceId);
  } else {
    isar.sources.putSync(
      source
        ..sourceCode = ''
        ..isAdded = false
        ..isPinned = false
        ..updatedAt = DateTime.now().millisecondsSinceEpoch,
    );
  }
  if (preferenceIds.isNotEmpty) {
    isar.sourcePreferences.deleteAllSync(preferenceIds);
  }
  if (preferenceStringIds.isNotEmpty) {
    isar.sourcePreferenceStringValues.deleteAllSync(preferenceStringIds);
  }
}

void _deleteSavedSearchLocally(String key) {
  final search = isar.savedSearchs
      .filter()
      .idIsNotNull()
      .findAllSync()
      .where((entry) => savedSearchSyncKey(entry) == key)
      .firstOrNull;
  if (search?.id == null) {
    return;
  }
  final feedIds = isar.feedSavedSearchs
      .filter()
      .savedSearchIdEqualTo(search!.id!)
      .findAllSync()
      .map((feed) => feed.id)
      .whereType<int>()
      .toList();
  if (feedIds.isNotEmpty) {
    isar.feedSavedSearchs.deleteAllSync(feedIds);
  }
  isar.savedSearchs.deleteSync(search.id!);
}

void _deleteFeedLocally(String key, List<SavedSearch> savedSearches) {
  final idToKey = savedSearchIdToSyncKey(savedSearches);
  final feed = isar.feedSavedSearchs
      .filter()
      .idIsNotNull()
      .findAllSync()
      .where(
        (entry) => feedSavedSearchSyncKey(entry, idToKey) == key,
      )
      .firstOrNull;
  if (feed?.id != null) {
    isar.feedSavedSearchs.deleteSync(feed!.id!);
  }
}

List<LibraryCategorySortEntry> _mergeLibraryCategorySorts(
  List<LibraryCategorySortEntry> local,
  List<LibraryCategorySortEntry> remote,
) {
  final merged = <String, LibraryCategorySortEntry>{};
  for (final entry in local) {
    merged[entry.categoryKey] = LibraryCategorySortEntry.fromJson(entry.toJson());
  }
  for (final entry in remote) {
    final existing = merged[entry.categoryKey];
    if (existing == null) {
      merged[entry.categoryKey] =
          LibraryCategorySortEntry.fromJson(entry.toJson());
      continue;
    }
    if (_isRemoteNewer(existing.updatedAt, entry.updatedAt)) {
      merged[entry.categoryKey] =
          LibraryCategorySortEntry.fromJson(entry.toJson());
    }
  }
  return merged.values.toList();
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
  final mergedExtensionsPreferences = _mergeExtensionsPreferences(
    local.extensionsPreferences,
    remote.extensionsPreferences,
  );
  final mergedExtensionsPreferenceStringValues =
      _mergeExtensionsPreferenceStringValues(
    local.extensionsPreferenceStringValues,
    remote.extensionsPreferenceStringValues,
  );
  final mergedTombstones = _mergeTombstones(local.tombstones, remote.tombstones);
  final mergedSavedSearches = _filterSavedSearchesByTombstones(
    _mergeSavedSearches(local.savedSearches, remote.savedSearches),
    mergedTombstones,
  );
  final mergedExtensions = _filterExtensionsByTombstones(
    _mergeExtensions(local.extensions, remote.extensions),
    mergedTombstones,
  );
  final mergedFeedSavedSearches = _filterFeedsByTombstones(
    _mergeFeedSavedSearches(
      local: local.feedSavedSearches,
      remote: remote.feedSavedSearches,
      localSavedSearches: local.savedSearches,
      remoteSavedSearches: remote.savedSearches,
    ),
    mergedSavedSearches,
    mergedTombstones,
  );
  final mergedLibraryCategorySorts = _mergeLibraryCategorySorts(
    local.libraryCategorySorts,
    remote.libraryCategorySorts,
  );

  return SyncSnapshot(
    version: SyncSnapshot.snapshotVersion,
    manga: mergedManga,
    categories: mergedCategories,
    chapters: mergedChapters,
    tracks: mergedTracks,
    history: mergedHistory,
    updates: mergedUpdates,
    settings: mergedSettings,
    extensionsPreferences: mergedExtensionsPreferences,
    extensionsPreferenceStringValues: mergedExtensionsPreferenceStringValues,
    extensions: mergedExtensions,
    savedSearches: mergedSavedSearches,
    feedSavedSearches: mergedFeedSavedSearches,
    tombstones: mergedTombstones,
    libraryCategorySorts: mergedLibraryCategorySorts,
  );
}

/// Applies a merged snapshot to Isar (full replace for synced entity types).
Future<void> applySyncSnapshotToDatabase(SyncSnapshot merged, Ref ref) async {
  final applySettings = merged.settings.isNotEmpty;
  final applyExtensionsPreferences =
      merged.extensionsPreferences.isNotEmpty ||
      merged.extensionsPreferenceStringValues.isNotEmpty;
  final applyExtensions =
      merged.extensions.isNotEmpty || merged.tombstones.isNotEmpty;
  final applyFeeds =
      merged.savedSearches.isNotEmpty ||
      merged.feedSavedSearches.isNotEmpty ||
      merged.tombstones.isNotEmpty;

  isar.writeTxnSync(() {
    isar.categorys.clearSync();
    if (merged.categories.isNotEmpty) {
      isar.categorys.putAllSync(merged.categories);
    }

    isar.mangas.clearSync();
    if (merged.manga.isNotEmpty) {
      isar.mangas.putAllSync(merged.manga);
    }

    isar.chapters.clearSync();
    for (final chapter in merged.chapters) {
      final mangaId = chapter.mangaId;
      if (mangaId == null) {
        continue;
      }
      final manga = isar.mangas.getSync(mangaId);
      if (manga != null) {
        isar.chapters.putSync(chapter..manga.value = manga);
        chapter.manga.saveSync();
      }
    }

    isar.tracks.clearSync();
    if (merged.tracks.isNotEmpty) {
      isar.tracks.putAllSync(merged.tracks);
    }

    isar.historys.clearSync();
    for (final history in merged.history) {
      final chapterId = history.chapterId;
      if (chapterId == null) {
        continue;
      }
      final chapter = isar.chapters.getSync(chapterId);
      if (chapter != null) {
        isar.historys.putSync(history..chapter.value = chapter);
        history.chapter.saveSync();
      }
    }

    isar.updates.clearSync();
    for (final update in merged.updates) {
      final chapter = isar.chapters
          .filter()
          .mangaIdEqualTo(update.mangaId)
          .nameEqualTo(update.chapterName)
          .findFirstSync();
      if (chapter != null) {
        isar.updates.putSync(update..chapter.value = chapter);
        update.chapter.saveSync();
      }
    }

    if (applySettings) {
      final oldSettings = isar.settings.getSync(227);
      if (oldSettings != null) {
        final settings = preserveDeviceLocalSettings(
          _copySettings(merged.settings.first),
          oldSettings,
        );
        isar.settings.putSync(settings..cookiesList = oldSettings.cookiesList);
      }
    }

    if (applyExtensionsPreferences) {
      for (final preference in merged.extensionsPreferences) {
        final existing = isar.sourcePreferences
            .filter()
            .sourceIdEqualTo(preference.sourceId)
            .keyEqualTo(preference.key)
            .findFirstSync();
        isar.sourcePreferences.putSync(
          preference..id = existing?.id ?? Isar.autoIncrement,
        );
      }
      for (final value in merged.extensionsPreferenceStringValues) {
        final existing = isar.sourcePreferenceStringValues
            .filter()
            .sourceIdEqualTo(value.sourceId)
            .keyEqualTo(value.key)
            .findFirstSync();
        isar.sourcePreferenceStringValues.putSync(
          value..id = existing?.id ?? Isar.autoIncrement,
        );
      }
    }

    if (applyExtensions) {
      for (final tombstone in merged.tombstones) {
        if (tombstone.entity == SyncTombstoneEntity.extension) {
          _uninstallExtensionLocally(int.parse(tombstone.key));
        }
      }
      for (final extension in merged.extensions) {
        isar.sources.putSync(
          extension..isAdded = true,
        );
      }
    }

    if (applyFeeds) {
      final localSavedSearches = isar.savedSearchs
          .filter()
          .idIsNotNull()
          .findAllSync();
      for (final tombstone in merged.tombstones) {
        if (tombstone.entity == SyncTombstoneEntity.savedSearch) {
          _deleteSavedSearchLocally(tombstone.key);
        }
        if (tombstone.entity == SyncTombstoneEntity.feed) {
          _deleteFeedLocally(tombstone.key, localSavedSearches);
        }
      }

      final persistedSavedSearches = <SavedSearch>[];
      for (final savedSearch in merged.savedSearches) {
        final existing = isar.savedSearchs
            .filter()
            .sourceIdEqualTo(savedSearch.sourceId)
            .and()
            .itemTypeEqualTo(savedSearch.itemType)
            .and()
            .nameEqualTo(savedSearch.name)
            .findAllSync()
            .where((entry) => savedSearchSyncKey(entry) == savedSearchSyncKey(savedSearch))
            .firstOrNull;
        final id = isar.savedSearchs.putSync(
          SavedSearch.fromJson(savedSearch.toJson())
            ..id = existing?.id ?? Isar.autoIncrement,
        );
        persistedSavedSearches.add(
          SavedSearch.fromJson(savedSearch.toJson())..id = id,
        );
      }

      final remappedFeeds = _remapFeedSavedSearchIds(
        merged.feedSavedSearches,
        persistedSavedSearches,
        merged.savedSearches,
      );
      for (final feed in remappedFeeds) {
        final idToKey = savedSearchIdToSyncKey(persistedSavedSearches);
        final existing = isar.feedSavedSearchs
            .filter()
            .idIsNotNull()
            .findAllSync()
            .where(
              (entry) =>
                  feedSavedSearchSyncKey(entry, idToKey) ==
                  feedSavedSearchSyncKey(feed, idToKey),
            )
            .firstOrNull;
        isar.feedSavedSearchs.putSync(
          FeedSavedSearch.fromJson(feed.toJson())
            ..id = existing?.id ?? Isar.autoIncrement,
        );
      }
    }
  });

  if (applySettings || applyExtensions || applyFeeds) {
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

  if (merged.libraryCategorySorts.isNotEmpty) {
    await applyLibraryCategorySorts(merged.libraryCategorySorts);
  }
}
