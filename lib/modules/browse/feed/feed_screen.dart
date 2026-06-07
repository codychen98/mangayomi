import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/modules/browse/feed/providers/bulk_favorite_provider.dart';
import 'package:mangayomi/modules/browse/feed/providers/feed_provider.dart';
import 'package:mangayomi/modules/browse/feed/providers/feed_state_provider.dart';
import 'package:mangayomi/modules/browse/feed/widgets/feed_item_row.dart';
import 'package:mangayomi/providers/l10n_providers.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class FeedScreen extends ConsumerWidget {
  final ItemType itemType;
  final FeedBulkScope? selectionScope;

  const FeedScreen({
    super.key,
    required this.itemType,
    this.selectionScope,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = l10nLocalizations(context)!;
    final feedStream = ref.watch(feedGlobalStreamProvider(itemType: itemType));

    return feedStream.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (feeds) {
        if (feeds.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                l10n.feed_tab_empty,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(refreshFeedRowsProvider(itemType: itemType).future),
          child: SuperListView.builder(
            padding: const EdgeInsets.only(top: 10),
            itemCount: feeds.length,
            extentPrecalculationPolicy: SuperPrecalculationPolicy(),
            itemBuilder: (context, index) {
              final feed = feeds[index];
              if (feed.id == null) {
                return const SizedBox.shrink();
              }
              return FeedItemRow(
                key: ValueKey(feed.id),
                feedId: feed.id!,
                itemType: itemType,
                selectionScope: selectionScope,
              );
            },
          ),
        );
      },
    );
  }
}
