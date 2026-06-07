import 'package:isar_community/isar.dart';
import 'package:mangayomi/models/feed_saved_search.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/saved_search.dart';
import 'package:mangayomi/services/feed/feed_repository.dart';
import 'package:mangayomi/services/feed/saved_search_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feed_state_provider.g.dart';

@riverpod
Stream<List<FeedSavedSearch>> feedGlobalStream(
  Ref ref, {
  required ItemType itemType,
}) {
  return FeedRepository.instance.watchGlobal(itemType: itemType);
}

@riverpod
Stream<List<FeedSavedSearch>> feedBySourceStream(
  Ref ref, {
  required int sourceId,
  required ItemType itemType,
}) {
  return FeedRepository.instance.watchBySourceId(
    sourceId: sourceId,
    itemType: itemType,
  );
}

@riverpod
Future<int> feedGlobalCount(Ref ref, {required ItemType itemType}) {
  return FeedRepository.instance.countGlobal(itemType: itemType);
}

@riverpod
Future<int> feedBySourceCount(
  Ref ref, {
  required int sourceId,
  required ItemType itemType,
}) {
  return FeedRepository.instance.countBySourceId(
    sourceId: sourceId,
    itemType: itemType,
  );
}

@riverpod
Future<bool> hasTooManyGlobalFeeds(Ref ref, {required ItemType itemType}) async {
  final count = await FeedRepository.instance.countGlobal(itemType: itemType);
  return count >= maxFeedItems;
}

@riverpod
Stream<List<SavedSearch>> savedSearchBySourceStream(
  Ref ref, {
  required int sourceId,
  required ItemType itemType,
}) {
  return SavedSearchRepository.instance.watchBySourceId(
    sourceId: sourceId,
    itemType: itemType,
  );
}

@riverpod
Future<void> deleteFeedItem(Ref ref, {required int feedId}) {
  return FeedRepository.instance.delete(feedId);
}

@riverpod
Future<Id> insertFeedItem(Ref ref, {required FeedSavedSearch feed}) {
  return FeedRepository.instance.insert(feed);
}

@riverpod
Future<FeedReorderResult> reorderFeedItem(
  Ref ref, {
  required FeedSavedSearch feed,
  required int newIndex,
  required bool global,
}) {
  return FeedRepository.instance.reorder(
    feed: feed,
    newIndex: newIndex,
    global: global,
  );
}

@riverpod
Future<Id> insertSavedSearch(Ref ref, {required SavedSearch savedSearch}) {
  return SavedSearchRepository.instance.insert(savedSearch);
}

@riverpod
Future<void> deleteSavedSearch(Ref ref, {required int savedSearchId}) {
  return SavedSearchRepository.instance.delete(savedSearchId);
}
