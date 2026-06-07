import 'package:mangayomi/l10n/generated/app_localizations.dart';
import 'package:mangayomi/models/feed_saved_search.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/services/feed/feed_constants.dart';
import 'package:mangayomi/services/feed/saved_search_repository.dart';

String localizeFeedItemTitle(String title, AppLocalizations l10n) {
  switch (title) {
    case 'Latest':
      return l10n.latest;
    case 'Popular':
      return l10n.popular;
    default:
      return title;
  }
}

Future<String> resolveFeedItemTitle(FeedSavedSearch feed) async {
  if (feed.savedSearchId == null) {
    return 'Latest';
  }
  final savedSearch = await SavedSearchRepository.instance.getById(
    feed.savedSearchId!,
  );
  if (isFeedPopularSavedSearch(savedSearch)) {
    return 'Popular';
  }
  return savedSearch?.name ?? '';
}

String feedOrderListTitle({
  required String sourceName,
  required String feedTitle,
}) {
  return '$sourceName - $feedTitle';
}

String? feedOrderListSubtitle(Source? source) {
  final lang = source?.lang;
  if (lang == null || lang.isEmpty) {
    return null;
  }
  return lang;
}
