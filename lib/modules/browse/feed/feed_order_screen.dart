import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/feed_saved_search.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/modules/browse/feed/providers/feed_state_provider.dart';
import 'package:mangayomi/modules/browse/feed/widgets/feed_delete_dialog.dart';
import 'package:mangayomi/providers/l10n_providers.dart';
import 'package:mangayomi/services/feed/feed_labels.dart';
import 'package:mangayomi/utils/item_type_localization.dart';
import 'package:mangayomi/utils/language.dart';

class FeedOrderScreen extends ConsumerWidget {
  final ItemType itemType;

  const FeedOrderScreen({super.key, required this.itemType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = l10nLocalizations(context)!;
    final feedStream = ref.watch(feedGlobalStreamProvider(itemType: itemType));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reorder_feed_for_type(itemType.localized(l10n))),
      ),
      body: feedStream.when(
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

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ReorderableListView.builder(
              buildDefaultDragHandles: false,
              itemCount: feeds.length,
              itemBuilder: (context, index) {
                final feed = feeds[index];
                if (feed.id == null) {
                  return SizedBox(key: ValueKey('feed_empty_$index'));
                }
                return _FeedOrderTile(
                  key: ValueKey(feed.id),
                  feed: feed,
                  index: index,
                  ref: ref,
                  l10nUnknown: l10n.unknown,
                );
              },
              onReorder: (oldIndex, newIndex) async {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final feed = feeds[oldIndex];
                await ref.read(
                  reorderFeedItemProvider(
                    feed: feed,
                    newIndex: newIndex,
                    global: true,
                  ).future,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _FeedOrderTile extends StatelessWidget {
  final FeedSavedSearch feed;
  final int index;
  final WidgetRef ref;
  final String l10nUnknown;

  const _FeedOrderTile({
    super.key,
    required this.feed,
    required this.index,
    required this.ref,
    required this.l10nUnknown,
  });

  @override
  Widget build(BuildContext context) {
    final source = isar.sources.getSync(feed.sourceId);
    final sourceName = source?.name ?? l10nUnknown;

    return Row(
      children: [
        ReorderableDragStartListener(
          index: index,
          child: const Icon(Icons.drag_handle),
        ),
        Expanded(
          child: FutureBuilder<String>(
            future: resolveFeedItemTitle(feed),
            builder: (context, snapshot) {
              final feedTitle = localizeFeedItemTitle(
                snapshot.data ?? '...',
                l10nLocalizations(context)!,
              );
              final subtitleLang = feedOrderListSubtitle(source);
              return ListTile(
                dense: true,
                title: Text(
                  feedOrderListTitle(
                    sourceName: sourceName,
                    feedTitle: feedTitle,
                  ),
                ),
                subtitle: subtitleLang == null
                    ? null
                    : Text(
                        completeLanguageName(subtitleLang.toLowerCase()),
                        style: const TextStyle(fontSize: 10),
                      ),
              );
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            final title = await resolveFeedItemTitle(feed);
            if (!context.mounted) return;
            await showFeedDeleteDialog(
              context: context,
              ref: ref,
              feed: feed,
              title: title,
            );
          },
        ),
      ],
    );
  }
}
