import 'package:mangayomi/eval/model/source_preference.dart';
import 'package:mangayomi/models/feed_saved_search.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/saved_search.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/services/sync/sync_merger.dart';

String extensionSyncKey(Source source) => '${source.id}';

String savedSearchSyncKey(SavedSearch savedSearch) =>
    '${savedSearch.sourceId}|${savedSearch.itemType.index}|'
    '${normalizeSyncKeyPart(savedSearch.name)}|'
    '${normalizeSyncKeyPart(savedSearch.query)}|'
    '${normalizeSyncKeyPart(savedSearch.filtersJson)}';

String feedSavedSearchSyncKey(
  FeedSavedSearch feed,
  Map<int, String> savedSearchIdToKey,
) {
  final savedSearchKey = feed.savedSearchId == null
      ? 'latest'
      : savedSearchIdToKey[feed.savedSearchId] ?? 'latest';
  return '${feed.sourceId}|${feed.itemType.index}|${feed.global}|$savedSearchKey';
}

Map<int, String> savedSearchIdToSyncKey(List<SavedSearch> savedSearches) {
  return {
    for (final savedSearch in savedSearches)
      if (savedSearch.id != null) savedSearch.id!: savedSearchSyncKey(savedSearch),
  };
}
