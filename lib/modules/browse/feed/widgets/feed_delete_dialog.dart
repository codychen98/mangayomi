import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/feed_saved_search.dart';
import 'package:mangayomi/modules/browse/feed/providers/feed_state_provider.dart';
import 'package:mangayomi/providers/l10n_providers.dart';

Future<void> showFeedDeleteDialog({
  required BuildContext context,
  required WidgetRef ref,
  required FeedSavedSearch feed,
  required String title,
}) {
  final l10n = l10nLocalizations(context)!;
  final sourceName =
      isar.sources.getSync(feed.sourceId)?.name ?? l10n.unknown;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.delete),
      content: Text(l10n.remove_from_feed(title, sourceName)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () async {
            if (feed.id != null) {
              await ref.read(deleteFeedItemProvider(feedId: feed.id!).future);
            }
            if (dialogContext.mounted) {
              Navigator.pop(dialogContext);
            }
          },
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
}
