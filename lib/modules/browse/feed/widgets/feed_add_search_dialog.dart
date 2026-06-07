import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangayomi/models/feed_saved_search.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/saved_search.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/modules/browse/feed/providers/feed_state_provider.dart';
import 'package:mangayomi/providers/l10n_providers.dart';
import 'package:mangayomi/services/feed/feed_constants.dart';
import 'package:mangayomi/services/feed/feed_repository.dart';

enum FeedAddMode { latest, popular, savedSearch }

class FeedAddSearchDialog extends ConsumerWidget {
  final Source source;
  final ItemType itemType;
  final List<SavedSearch> savedSearches;
  final bool global;
  final int popCount;

  const FeedAddSearchDialog({
    super.key,
    required this.source,
    required this.itemType,
    required this.savedSearches,
    this.global = true,
    this.popCount = 2,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = l10nLocalizations(context)!;
    final userSavedSearches = savedSearches
        .where((search) => !isFeedPopularSavedSearch(search))
        .toList();

    return AlertDialog(
      title: Text(source.name ?? l10n.unknown),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.new_releases_outlined),
              title: Text(l10n.latest),
              onTap: () => _addFeed(
                context,
                ref,
                mode: FeedAddMode.latest,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.favorite_outline),
              title: Text(l10n.popular),
              onTap: () => _addFeed(
                context,
                ref,
                mode: FeedAddMode.popular,
              ),
            ),
            if (userSavedSearches.isNotEmpty) ...[
              const Divider(),
              for (final savedSearch in userSavedSearches)
                ListTile(
                  leading: const Icon(Icons.bookmark_outline),
                  title: Text(savedSearch.name),
                  onTap: () => _addFeed(
                    context,
                    ref,
                    mode: FeedAddMode.savedSearch,
                    savedSearch: savedSearch,
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }

  Future<void> _addFeed(
    BuildContext context,
    WidgetRef ref, {
    required FeedAddMode mode,
    SavedSearch? savedSearch,
  }) async {
    final l10n = l10nLocalizations(context)!;
    final tooMany = global
        ? await ref.read(
            hasTooManyGlobalFeedsProvider(itemType: itemType).future,
          )
        : (await ref.read(
                feedBySourceCountProvider(
                  sourceId: source.id!,
                  itemType: itemType,
                ).future,
              )) >=
            maxFeedItems;
    if (tooMany) {
      BotToast.showText(text: l10n.too_many_in_feed(maxFeedItems));
      return;
    }

    int? savedSearchId;
    switch (mode) {
      case FeedAddMode.latest:
        savedSearchId = null;
      case FeedAddMode.popular:
        savedSearchId = await getOrCreatePopularSavedSearchId(
          sourceId: source.id!,
          itemType: itemType,
        );
      case FeedAddMode.savedSearch:
        savedSearchId = savedSearch?.id;
    }

    await ref.read(
      insertFeedItemProvider(
        feed: FeedSavedSearch(
          sourceId: source.id!,
          itemType: itemType,
          savedSearchId: savedSearchId,
          global: global,
        ),
      ).future,
    );

    if (context.mounted) {
      for (var i = 0; i < popCount; i++) {
        Navigator.pop(context);
      }
    }
  }
}
