import 'package:isar_community/isar.dart';
import 'package:mangayomi/eval/model/m_manga.dart';
import 'package:mangayomi/eval/model/m_pages.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/feed_saved_search.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/services/feed/feed_constants.dart';
import 'package:mangayomi/modules/more/settings/browse/providers/browse_state_provider.dart';
import 'package:mangayomi/services/feed/feed_library_filter.dart';
import 'package:mangayomi/services/feed/saved_search_filters.dart';
import 'package:mangayomi/services/feed/saved_search_repository.dart';
import 'package:mangayomi/services/get_latest_updates.dart';
import 'package:mangayomi/services/get_popular.dart';
import 'package:mangayomi/services/search.dart';
import 'package:mangayomi/services/supports_latest.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feed_provider.g.dart';

class FeedRowState {
  final FeedSavedSearch feed;
  final Source source;
  final String title;
  final List<MManga> mangas;
  final String? error;

  const FeedRowState({
    required this.feed,
    required this.source,
    required this.title,
    required this.mangas,
    this.error,
  });
}

@riverpod
Future<FeedRowState> feedRow(Ref ref, int feedId) async {
  final hideInLibrary = ref.watch(hideInLibraryFeedItemsStateProvider);
  final feed = await isar.feedSavedSearchs.get(feedId);
  if (feed == null) {
    throw StateError('Feed item $feedId not found');
  }

  final source = await isar.sources.get(feed.sourceId);
  if (source == null) {
    return FeedRowState(
      feed: feed,
      source: Source(itemType: feed.itemType),
      title: '',
      mangas: const [],
      error: 'Source not found',
    );
  }

  try {
    final result = await _fetchFeedRow(
      ref,
      feed: feed,
      source: source,
      hideInLibrary: hideInLibrary,
    );
    return result;
  } catch (e) {
    return FeedRowState(
      feed: feed,
      source: source,
      title: await _resolveTitle(feed, source),
      mangas: const [],
      error: e.toString(),
    );
  }
}

Future<FeedRowState> _fetchFeedRow(
  Ref ref, {
  required FeedSavedSearch feed,
  required Source source,
  required bool hideInLibrary,
}) async {
  final title = await _resolveTitle(feed, source);
  MPages? pages;

  if (feed.savedSearchId == null) {
    final supportsLatest = source.name == 'local' && source.lang == ''
        ? true
        : ref.read(supportsLatestProvider(source: source));
    if (supportsLatest) {
      pages = await ref.read(
        getLatestUpdatesProvider(source: source, page: 1).future,
      );
    }
    if (pages == null || pages.list.isEmpty) {
      pages = await ref.read(
        getPopularProvider(source: source, page: 1).future,
      );
    }
  } else {
    final savedSearch = await SavedSearchRepository.instance.getById(
      feed.savedSearchId!,
    );
    if (isFeedPopularSavedSearch(savedSearch)) {
      pages = await ref.read(
        getPopularProvider(source: source, page: 1).future,
      );
    } else if (savedSearch != null) {
      final filterList = deserializeSavedSearchFilters(savedSearch.filtersJson);
      pages = await ref.read(
        searchProvider(
          source: source,
          query: savedSearch.query ?? '',
          page: 1,
          filterList: filterList,
        ).future,
      );
    }
  }

  return FeedRowState(
    feed: feed,
    source: source,
    title: title,
    mangas: _filterFeedMangas(
      source: source,
      mangas: pages?.list ?? const [],
      hideInLibrary: hideInLibrary,
    ),
    error: null,
  );
}

List<MManga> _filterFeedMangas({
  required Source source,
  required List<MManga> mangas,
  required bool hideInLibrary,
}) {
  if (source.id == null) {
    return mangas;
  }
  return filterLibraryItemsFromFeed(
    mangas: mangas,
    sourceId: source.id!,
    hideInLibrary: hideInLibrary,
  );
}

Future<String> _resolveTitle(FeedSavedSearch feed, Source source) async {
  if (feed.savedSearchId == null) {
    return 'Latest';
  }
  final savedSearch = await SavedSearchRepository.instance.getById(
    feed.savedSearchId!,
  );
  if (isFeedPopularSavedSearch(savedSearch)) {
    return 'Popular';
  }
  return savedSearch?.name ?? source.name ?? '';
}

@riverpod
Future<void> refreshFeedRows(Ref ref, {required ItemType itemType}) async {
  final feeds = await isar.feedSavedSearchs
      .filter()
      .globalEqualTo(true)
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
