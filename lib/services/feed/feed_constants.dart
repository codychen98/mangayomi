import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/saved_search.dart';
import 'package:mangayomi/services/feed/saved_search_repository.dart';

const String kFeedPopularMarker = '__feed_popular__';

bool isFeedPopularSavedSearch(SavedSearch? savedSearch) {
  return savedSearch?.name == kFeedPopularMarker;
}

Future<int> getOrCreatePopularSavedSearchId({
  required int sourceId,
  required ItemType itemType,
}) {
  return SavedSearchRepository.instance.insert(
    SavedSearch(
      sourceId: sourceId,
      itemType: itemType,
      name: kFeedPopularMarker,
      query: null,
      filtersJson: '{"builtin":"popular"}',
    ),
  );
}
