import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangayomi/models/feed_saved_search.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/saved_search.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/modules/browse/feed/providers/feed_state_provider.dart';
import 'package:mangayomi/providers/l10n_providers.dart';
import 'package:mangayomi/services/feed/feed_repository.dart';
import 'package:mangayomi/services/feed/saved_search_filters.dart';

Future<String?> showSaveSavedSearchDialog({
  required BuildContext context,
  String? initialName,
}) {
  final l10n = l10nLocalizations(context)!;
  final controller = TextEditingController(text: initialName ?? '');

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.save_search),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          labelText: l10n.name,
          hintText: l10n.saved_search_name_hint,
        ),
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            Navigator.pop(context, value.trim());
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            final name = controller.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(context, name);
          },
          child: Text(l10n.save),
        ),
      ],
    ),
  );
}

Future<bool> showDeleteSavedSearchDialog({
  required BuildContext context,
  required String name,
}) {
  final l10n = l10nLocalizations(context)!;

  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.delete_saved_search),
      content: Text(l10n.delete_saved_search_confirm(name)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.delete),
        ),
      ],
    ),
  ).then((value) => value ?? false);
}

enum SavedSearchAction { addToFeed, delete }

Future<SavedSearchAction?> showSavedSearchActionsDialog({
  required BuildContext context,
}) {
  final l10n = l10nLocalizations(context)!;

  return showDialog<SavedSearchAction>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.saved_search),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.rss_feed_outlined),
            title: Text(l10n.add_to_feed),
            onTap: () => Navigator.pop(context, SavedSearchAction.addToFeed),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(l10n.delete),
            onTap: () => Navigator.pop(context, SavedSearchAction.delete),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ],
    ),
  );
}

Future<void> saveCurrentSearch({
  required BuildContext context,
  required WidgetRef ref,
  required Source source,
  required String name,
  required String query,
  required List<dynamic> filters,
}) async {
  final filtersJson = serializeSavedSearchFilters(filters);
  await ref.read(
    insertSavedSearchProvider(
      savedSearch: SavedSearch(
        sourceId: source.id!,
        itemType: source.itemType,
        name: name,
        query: query.isEmpty ? null : query,
        filtersJson: filtersJson,
      ),
    ).future,
  );
  if (context.mounted) {
    BotToast.showText(text: l10nLocalizations(context)!.saved_search_toast(name));
  }
}

Future<void> addSavedSearchToGlobalFeed({
  required BuildContext context,
  required WidgetRef ref,
  required SavedSearch savedSearch,
}) async {
  final tooMany = await ref.read(
    hasTooManyGlobalFeedsProvider(itemType: savedSearch.itemType).future,
  );
  if (tooMany) {
    BotToast.showText(
      text: l10nLocalizations(context)!.too_many_in_feed(maxFeedItems),
    );
    return;
  }

  if (savedSearch.id == null) return;

  await ref.read(
    insertFeedItemProvider(
      feed: FeedSavedSearch(
        sourceId: savedSearch.sourceId,
        itemType: savedSearch.itemType,
        savedSearchId: savedSearch.id,
        global: true,
      ),
    ).future,
  );

  if (context.mounted) {
    BotToast.showText(
      text: l10nLocalizations(context)!.added_to_feed_toast(savedSearch.name),
    );
  }
}

Future<void> handleSavedSearchLongPress({
  required BuildContext context,
  required WidgetRef ref,
  required SavedSearch savedSearch,
}) async {
  final action = await showSavedSearchActionsDialog(context: context);
  if (action == null || !context.mounted) return;

  switch (action) {
    case SavedSearchAction.addToFeed:
      await addSavedSearchToGlobalFeed(
        context: context,
        ref: ref,
        savedSearch: savedSearch,
      );
    case SavedSearchAction.delete:
      final confirmed = await showDeleteSavedSearchDialog(
        context: context,
        name: savedSearch.name,
      );
      if (!confirmed || savedSearch.id == null) return;
      await ref.read(
        deleteSavedSearchProvider(savedSearchId: savedSearch.id!).future,
      );
      if (context.mounted) {
        BotToast.showText(
          text: l10nLocalizations(context)!.deleted_saved_search_toast(
            savedSearch.name,
          ),
        );
      }
  }
}
