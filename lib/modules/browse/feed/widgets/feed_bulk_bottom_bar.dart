import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangayomi/modules/browse/feed/providers/bulk_favorite_provider.dart';
import 'package:mangayomi/modules/browse/feed/widgets/feed_actions_dialog.dart';
import 'package:mangayomi/modules/widgets/bottom_select_bar.dart';

class FeedBulkBottomBar extends ConsumerWidget {
  final FeedBulkScope scope;

  const FeedBulkBottomBar({super.key, required this.scope});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionMode = ref.watch(feedBulkSelectionModeProvider(scope));
    final selection = ref.watch(feedBulkSelectionProvider(scope));
    final isRunning = ref.watch(feedBulkFavoriteRunningProvider(scope));
    final color = Theme.of(context).textTheme.bodyLarge!.color!;

    return BottomSelectBar(
      isVisible: selectionMode && selection.isNotEmpty,
      actions: [
        BottomSelectButton(
          icon: isRunning
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: color),
                )
              : Icon(Icons.favorite_border_rounded, color: color),
          onPressed: isRunning || selection.isEmpty
              ? () {}
              : () => showFeedBulkFavoriteFlow(
                  context: context,
                  ref: ref,
                  scope: scope,
                ),
        ),
        BottomSelectButton(
          icon: Icon(Icons.clear, color: color),
          onPressed: () {
            ref.read(feedBulkSelectionProvider(scope).notifier).clear();
            ref.read(feedBulkSelectionModeProvider(scope).notifier).setMode(false);
          },
        ),
      ],
    );
  }
}
