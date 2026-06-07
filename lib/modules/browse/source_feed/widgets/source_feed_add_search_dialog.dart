import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/modules/browse/feed/widgets/feed_add_search_dialog.dart';

Future<void> showSourceFeedAddDialog({
  required BuildContext context,
  required WidgetRef ref,
  required Source source,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => _SourceFeedAddDialog(source: source),
  );
}

class _SourceFeedAddDialog extends StatelessWidget {
  final Source source;

  const _SourceFeedAddDialog({required this.source});

  @override
  Widget build(BuildContext context) {
    final savedSearches = isar.savedSearchs
        .filter()
        .sourceIdEqualTo(source.id!)
        .and()
        .itemTypeEqualTo(source.itemType)
        .findAllSync();

    return FeedAddSearchDialog(
      source: source,
      itemType: source.itemType,
      savedSearches: savedSearches,
      global: false,
      popCount: 1,
    );
  }
}
