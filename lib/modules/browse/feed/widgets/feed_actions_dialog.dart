import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/category.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/modules/browse/feed/providers/bulk_favorite_provider.dart';
import 'package:mangayomi/modules/widgets/category_selection_dialog.dart';
import 'package:mangayomi/providers/l10n_providers.dart';

Future<void> showFeedBulkFavoriteFlow({
  required BuildContext context,
  required WidgetRef ref,
  required FeedBulkScope scope,
}) async {
  final selection = ref.read(feedBulkSelectionProvider(scope));
  if (selection.isEmpty) return;

  ref.read(feedBulkFavoriteRunningProvider(scope).notifier).setRunning(true);

  final loadingLabel = l10nLocalizations(context)!.loading_ellipsis;
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(loadingLabel)),
          ],
        ),
      ),
    ),
  );

  final resolveResult = await resolveFeedSelectionEntries(
    selection.values.toList(),
  );

  if (context.mounted) {
    Navigator.pop(context);
  }

  ref.read(feedBulkFavoriteRunningProvider(scope).notifier).setRunning(false);

  if (!context.mounted) return;

  if (resolveResult.mangas.isEmpty) {
    _showFeedBulkErrors(context, resolveResult.errors);
    return;
  }

  final hasCategories = isar.categorys
      .filter()
      .idIsNotNull()
      .and()
      .forItemTypeEqualTo(scope.itemType)
      .isNotEmptySync();

  if (hasCategories) {
    showCategorySelectionDialog(
      context: context,
      ref: ref,
      itemType: scope.itemType,
      bulkMangas: resolveResult.mangas,
      setFavoriteOnBulk: true,
      onBulkApplied: () {
        ref.read(feedBulkSelectionProvider(scope).notifier).clear();
        ref.read(feedBulkSelectionModeProvider(scope).notifier).setMode(false);
      },
    );
  } else {
    isar.writeTxnSync(() {
      final dateNow = DateTime.now().millisecondsSinceEpoch;
      for (final manga in resolveResult.mangas) {
        manga
          ..favorite = true
          ..dateAdded = manga.dateAdded ?? dateNow
          ..updatedAt = dateNow;
        isar.mangas.putSync(manga);
      }
    });
    ref.read(feedBulkSelectionProvider(scope).notifier).clear();
    ref.read(feedBulkSelectionModeProvider(scope).notifier).setMode(false);
  }

  if (resolveResult.errors.isNotEmpty && context.mounted) {
    _showFeedBulkErrors(context, resolveResult.errors);
  }
}

void _showFeedBulkErrors(BuildContext context, List<String> errors) {
  final l10n = l10nLocalizations(context)!;
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.error_label),
      content: SingleChildScrollView(
        child: Text(errors.join('\n')),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(l10n.ok),
        ),
      ],
    ),
  );
}
