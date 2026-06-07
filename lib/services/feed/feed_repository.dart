import 'package:isar_community/isar.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/feed_saved_search.dart';
import 'package:mangayomi/models/manga.dart';

const int maxFeedItems = 20;

class FeedRepository {
  static const FeedRepository instance = FeedRepository._();
  const FeedRepository._();

  Future<List<FeedSavedSearch>> getGlobal({required ItemType itemType}) {
    return isar.feedSavedSearchs
        .filter()
        .globalEqualTo(true)
        .and()
        .itemTypeEqualTo(itemType)
        .sortByFeedOrder()
        .findAll();
  }

  Stream<List<FeedSavedSearch>> watchGlobal({required ItemType itemType}) {
    return isar.feedSavedSearchs
        .filter()
        .globalEqualTo(true)
        .and()
        .itemTypeEqualTo(itemType)
        .sortByFeedOrder()
        .watch(fireImmediately: true);
  }

  Future<int> countGlobal({required ItemType itemType}) {
    return isar.feedSavedSearchs
        .filter()
        .globalEqualTo(true)
        .and()
        .itemTypeEqualTo(itemType)
        .count();
  }

  Future<List<FeedSavedSearch>> getBySourceId({
    required int sourceId,
    required ItemType itemType,
  }) {
    return isar.feedSavedSearchs
        .filter()
        .sourceIdEqualTo(sourceId)
        .and()
        .globalEqualTo(false)
        .and()
        .itemTypeEqualTo(itemType)
        .sortByFeedOrder()
        .findAll();
  }

  Stream<List<FeedSavedSearch>> watchBySourceId({
    required int sourceId,
    required ItemType itemType,
  }) {
    return isar.feedSavedSearchs
        .filter()
        .sourceIdEqualTo(sourceId)
        .and()
        .globalEqualTo(false)
        .and()
        .itemTypeEqualTo(itemType)
        .sortByFeedOrder()
        .watch(fireImmediately: true);
  }

  Future<int> countBySourceId({
    required int sourceId,
    required ItemType itemType,
  }) {
    return isar.feedSavedSearchs
        .filter()
        .sourceIdEqualTo(sourceId)
        .and()
        .globalEqualTo(false)
        .and()
        .itemTypeEqualTo(itemType)
        .count();
  }

  Future<void> delete(int id) async {
    await isar.writeTxn(() async {
      await isar.feedSavedSearchs.delete(id);
    });
  }

  Future<Id> insert(FeedSavedSearch feed) async {
    return isar.writeTxn(() async {
      final existing = feed.savedSearchId == null
          ? await isar.feedSavedSearchs
                .filter()
                .sourceIdEqualTo(feed.sourceId)
                .and()
                .itemTypeEqualTo(feed.itemType)
                .and()
                .savedSearchIdIsNull()
                .and()
                .globalEqualTo(feed.global)
                .findFirst()
          : await isar.feedSavedSearchs
                .filter()
                .sourceIdEqualTo(feed.sourceId)
                .and()
                .itemTypeEqualTo(feed.itemType)
                .and()
                .savedSearchIdEqualTo(feed.savedSearchId!)
                .and()
                .globalEqualTo(feed.global)
                .findFirst();
      if (existing?.id != null) {
        return existing!.id!;
      }

      final nextOrder = await _nextFeedOrder(
        sourceId: feed.sourceId,
        itemType: feed.itemType,
        global: feed.global,
      );

      return isar.feedSavedSearchs.put(
        FeedSavedSearch(
          sourceId: feed.sourceId,
          itemType: feed.itemType,
          savedSearchId: feed.savedSearchId,
          global: feed.global,
          feedOrder: nextOrder,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    });
  }

  Future<void> insertAll(List<FeedSavedSearch> feeds) async {
    for (final feed in feeds) {
      await insert(feed);
    }
  }

  Future<FeedReorderResult> reorder({
    required FeedSavedSearch feed,
    required int newIndex,
    required bool global,
  }) async {
    return isar.writeTxn(() async {
      final feeds = global
          ? await getGlobal(itemType: feed.itemType)
          : await getBySourceId(
              sourceId: feed.sourceId,
              itemType: feed.itemType,
            );

      final currentIndex = feeds.indexWhere((item) => item.id == feed.id);
      if (currentIndex == -1) {
        return FeedReorderResult.unchanged;
      }

      final reordered = List<FeedSavedSearch>.from(feeds);
      final moved = reordered.removeAt(currentIndex);
      final clampedIndex = newIndex.clamp(0, reordered.length);
      reordered.insert(clampedIndex, moved);

      for (var index = 0; index < reordered.length; index++) {
        final item = reordered[index];
        if (item.feedOrder == index) continue;
        await isar.feedSavedSearchs.put(
          FeedSavedSearch(
            id: item.id,
            sourceId: item.sourceId,
            itemType: item.itemType,
            savedSearchId: item.savedSearchId,
            global: item.global,
            feedOrder: index,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      }

      return FeedReorderResult.success;
    });
  }

  Future<int> _nextFeedOrder({
    required int sourceId,
    required ItemType itemType,
    required bool global,
  }) async {
    final feeds = global
        ? await isar.feedSavedSearchs
              .filter()
              .globalEqualTo(true)
              .and()
              .itemTypeEqualTo(itemType)
              .findAll()
        : await isar.feedSavedSearchs
              .filter()
              .sourceIdEqualTo(sourceId)
              .and()
              .globalEqualTo(false)
              .and()
              .itemTypeEqualTo(itemType)
              .findAll();

    if (feeds.isEmpty) return 0;
    final maxOrder = feeds
        .map((feed) => feed.feedOrder)
        .reduce((a, b) => a > b ? a : b);
    return maxOrder + 1;
  }
}

enum FeedReorderResult { success, unchanged }
