import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mangayomi/models/category.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/modules/more/categories/providers/isar_providers.dart';
import 'package:mangayomi/modules/more/settings/library/providers/library_update_settings_provider.dart';
import 'package:mangayomi/modules/more/settings/library/widgets/update_categories_dialog.dart';
import 'package:mangayomi/modules/more/settings/reader/providers/reader_state_provider.dart';
import 'package:mangayomi/providers/l10n_providers.dart';
import 'package:mangayomi/services/library_update_category_filter.dart';
import 'package:mangayomi/services/library_update_preferences_service.dart';
import 'package:mangayomi/utils/extensions/build_context_extensions.dart';
import 'package:mangayomi/utils/item_type_filters.dart';
import 'package:mangayomi/utils/item_type_localization.dart';

class LibrarySettingsScreen extends ConsumerWidget {
  const LibrarySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = l10nLocalizations(context)!;
    final hideItems = ref.watch(hideItemsStateProvider);
    final visibleTypes = hiddenItemTypes(hideItems);
    final preferences = ref.watch(libraryUpdatePreferencesProvider).value ??
        getLibraryUpdatePreferences();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.library)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              l10n.library_update_settings,
              style: TextStyle(fontSize: 13, color: context.primaryColor),
            ),
          ),
          SwitchListTile(
            value: preferences.showUpdatesTabBadge,
            title: Text(l10n.show_updates_tab_badge),
            onChanged: setShowUpdatesTabBadge,
          ),
          ...visibleTypes.map((itemType) {
            final categoriesAsync = ref.watch(
              getMangaCategorieStreamProvider(itemType: itemType),
            );
            return categoriesAsync.when(
              data: (categories) => _UpdateCategoriesTile(
                itemType: itemType,
                label: itemType.localized(l10n),
                categories: categories,
                include: includeCategoryIdsFor(itemType, preferences),
                exclude: excludeCategoryIdsFor(itemType, preferences),
              ),
              loading: () => ListTile(
                title: Text(itemType.localized(l10n)),
                subtitle: Text(l10n.loading_ellipsis),
              ),
              error: (error, _) => ListTile(
                title: Text(itemType.localized(l10n)),
                subtitle: Text(error.toString()),
              ),
            );
          }),
          ListTile(
            title: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: context.secondaryColor),
                ],
              ),
            ),
            subtitle: Text(
              l10n.library_update_categories_hint,
              style: TextStyle(fontSize: 11, color: context.secondaryColor),
            ),
          ),
          ListTile(
            title: Text(l10n.edit_categories),
            subtitle: Text(
              l10n.manage_library_categories,
              style: TextStyle(fontSize: 11, color: context.secondaryColor),
            ),
            onTap: () => context.push('/categories', extra: (false, 0)),
          ),
        ],
      ),
    );
  }
}

class _UpdateCategoriesTile extends StatelessWidget {
  final ItemType itemType;
  final String label;
  final List<Category> categories;
  final List<int> include;
  final List<int> exclude;

  const _UpdateCategoriesTile({
    required this.itemType,
    required this.label,
    required this.categories,
    required this.include,
    required this.exclude,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = l10nLocalizations(context)!;
    final subtitle = buildUpdateCategoriesLabel(
      allCategories: categories,
      included: include,
      excluded: exclude,
      allLabel: l10n.all,
      noneLabel: l10n.none,
      includeLabel: l10n.include,
      excludeLabel: l10n.exclude,
    );

    return ListTile(
      title: Text(l10n.update_categories_for(label)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 11, color: context.secondaryColor),
      ),
      onTap: categories.isEmpty
          ? null
          : () async {
              final result = await showUpdateCategoriesDialog(
                context: context,
                categories: categories,
                initialIncluded: include,
                initialExcluded: exclude,
              );
              if (result == null || !context.mounted) return;
              setUpdateCategories(
                itemType: itemType,
                include: result.included,
                exclude: result.excluded,
              );
            },
    );
  }
}
