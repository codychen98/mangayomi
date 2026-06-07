import 'package:isar_community/isar.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/feed_saved_search.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/modules/browse/feed/providers/feed_provider.dart';
import 'package:mangayomi/services/feed/feed_constants.dart';
import 'package:mangayomi/services/feed/feed_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'source_feed_provider.g.dart';

@riverpod
Future<void> ensureSourceFeedDefaults(
  Ref ref, {
  required int sourceId,
  required ItemType itemType,
}) async {
  final count = await FeedRepository.instance.countBySourceId(
    sourceId: sourceId,
    itemType: itemType,
  );
  if (count > 0) {
    return;
  }

  await FeedRepository.instance.insert(
    FeedSavedSearch(
      sourceId: sourceId,
      itemType: itemType,
      savedSearchId: null,
      global: false,
    ),
  );

  final popularId = await getOrCreatePopularSavedSearchId(
    sourceId: sourceId,
    itemType: itemType,
  );
  await FeedRepository.instance.insert(
    FeedSavedSearch(
      sourceId: sourceId,
      itemType: itemType,
      savedSearchId: popularId,
      global: false,
    ),
  );
}

@riverpod
Future<void> refreshSourceFeedRows(
  Ref ref, {
  required int sourceId,
  required ItemType itemType,
}) async {
  final feeds = await isar.feedSavedSearchs
      .filter()
      .sourceIdEqualTo(sourceId)
      .and()
      .globalEqualTo(false)
      .and()
      .itemTypeEqualTo(itemType)
      .sortByFeedOrder()
      .findAll();

  for (final feed in feeds) {
    if (feed.id != null) {
      ref.invalidate(feedRowProvider(feed.id!));
    }
  }
}
