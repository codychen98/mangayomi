import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:mangayomi/models/feed_saved_search.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/saved_search.dart';
const int maxFeedItems = 20;

enum FeedReorderResult { success, unchanged }

void main() {
  late Isar isar;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('feed_repo_test');
    isar = await Isar.open(
      [SavedSearchSchema, FeedSavedSearchSchema],
      directory: tempDir.path,
      name: 'feed_test',
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('countGlobal is scoped by itemType', () async {
    await _insertFeed(
      isar,
      FeedSavedSearch(sourceId: 1, itemType: ItemType.manga, global: true),
    );
    await _insertFeed(
      isar,
      FeedSavedSearch(sourceId: 2, itemType: ItemType.anime, global: true),
    );

    expect(await _countGlobal(isar, ItemType.manga), 1);
    expect(await _countGlobal(isar, ItemType.anime), 1);
    expect(await _countGlobal(isar, ItemType.novel), 0);
  });

  test('countGlobal reaches maxFeedItems', () async {
    for (var i = 0; i < maxFeedItems; i++) {
      await _insertFeed(
        isar,
        FeedSavedSearch(
          sourceId: i + 1,
          itemType: ItemType.manga,
          global: true,
        ),
      );
    }

    expect(await _countGlobal(isar, ItemType.manga), maxFeedItems);
  });

  test('reorder persists new feedOrder values', () async {
    final firstId = await _insertFeed(
      isar,
      FeedSavedSearch(sourceId: 1, itemType: ItemType.manga, global: true),
    );
    final secondId = await _insertFeed(
      isar,
      FeedSavedSearch(sourceId: 2, itemType: ItemType.manga, global: true),
    );
    final thirdId = await _insertFeed(
      isar,
      FeedSavedSearch(sourceId: 3, itemType: ItemType.manga, global: true),
    );

    final feeds = await _getGlobal(isar, ItemType.manga);
    final moved = feeds.firstWhere((feed) => feed.id == thirdId);

    final result = await _reorder(isar, feed: moved, newIndex: 0);
    expect(result, FeedReorderResult.success);

    final reordered = await _getGlobal(isar, ItemType.manga);
    expect(reordered.map((feed) => feed.id), [thirdId, firstId, secondId]);
    expect(reordered.map((feed) => feed.feedOrder), [0, 1, 2]);
  });

  test('insert deduplicates identical feed entries', () async {
    final feed = FeedSavedSearch(
      sourceId: 10,
      itemType: ItemType.anime,
      global: true,
    );

    final firstId = await _insertFeed(isar, feed);
    final secondId = await _insertFeed(isar, feed);

    expect(firstId, secondId);
    expect(await _countGlobal(isar, ItemType.anime), 1);
  });
}

Future<int> _countGlobal(Isar isar, ItemType itemType) {
  return isar.feedSavedSearchs
      .filter()
      .globalEqualTo(true)
      .and()
      .itemTypeEqualTo(itemType)
      .count();
}

Future<List<FeedSavedSearch>> _getGlobal(Isar isar, ItemType itemType) {
  return isar.feedSavedSearchs
      .filter()
      .globalEqualTo(true)
      .and()
      .itemTypeEqualTo(itemType)
      .sortByFeedOrder()
      .findAll();
}

Future<Id> _insertFeed(Isar isar, FeedSavedSearch feed) async {
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

    final feeds = await isar.feedSavedSearchs
        .filter()
        .globalEqualTo(feed.global)
        .and()
        .itemTypeEqualTo(feed.itemType)
        .findAll();
    final nextOrder = feeds.isEmpty
        ? 0
        : feeds.map((f) => f.feedOrder).reduce((a, b) => a > b ? a : b) + 1;

    return isar.feedSavedSearchs.put(
      FeedSavedSearch(
        sourceId: feed.sourceId,
        itemType: feed.itemType,
        savedSearchId: feed.savedSearchId,
        global: feed.global,
        feedOrder: nextOrder,
      ),
    );
  });
}

Future<FeedReorderResult> _reorder(
  Isar isar, {
  required FeedSavedSearch feed,
  required int newIndex,
}) async {
  return isar.writeTxn(() async {
    final feeds = await _getGlobal(isar, feed.itemType);
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
        ),
      );
    }

    return FeedReorderResult.success;
  });
}
