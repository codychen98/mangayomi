import 'package:flutter/material.dart';
import 'package:mangayomi/models/category.dart';
import 'package:mangayomi/providers/l10n_providers.dart';

enum _TriState { unchecked, included, excluded }

Future<({List<int> included, List<int> excluded})?> showUpdateCategoriesDialog({
  required BuildContext context,
  required List<Category> categories,
  required List<int> initialIncluded,
  required List<int> initialExcluded,
}) {
  final includedSet = initialIncluded.toSet();
  final excludedSet = initialExcluded.toSet();
  final states = categories
      .map((category) {
        if (includedSet.contains(category.id)) {
          return _TriState.included;
        }
        if (excludedSet.contains(category.id)) {
          return _TriState.excluded;
        }
        return _TriState.unchecked;
      })
      .toList();

  return showDialog<({List<int> included, List<int> excluded})>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          final l10n = l10nLocalizations(context)!;
          return AlertDialog(
            title: Text(l10n.update_categories),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.update_categories_details,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(categories.length, (index) {
                      final category = categories[index];
                      final state = states[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          switch (state) {
                            _TriState.unchecked => Icons.check_box_outline_blank,
                            _TriState.included => Icons.check_box,
                            _TriState.excluded => Icons.indeterminate_check_box,
                          },
                          color: state == _TriState.unchecked
                              ? null
                              : Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(category.name ?? ''),
                        onTap: () {
                          setState(() {
                            states[index] = switch (state) {
                              _TriState.unchecked => _TriState.included,
                              _TriState.included => _TriState.excluded,
                              _TriState.excluded => _TriState.unchecked,
                            };
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  final included = <int>[];
                  final excluded = <int>[];
                  for (var i = 0; i < categories.length; i++) {
                    final id = categories[i].id;
                    if (id == null) continue;
                    switch (states[i]) {
                      case _TriState.included:
                        included.add(id);
                      case _TriState.excluded:
                        excluded.add(id);
                      case _TriState.unchecked:
                        break;
                    }
                  }
                  Navigator.of(dialogContext).pop((
                    included: included,
                    excluded: excluded,
                  ));
                },
                child: Text(l10n.ok),
              ),
            ],
          );
        },
      );
    },
  );
}

String buildUpdateCategoriesLabel({
  required List<Category> allCategories,
  required List<int> included,
  required List<int> excluded,
  required String allLabel,
  required String noneLabel,
  required String includeLabel,
  required String excludeLabel,
}) {
  final includedCategories = included
      .map((id) => allCategories.where((c) => c.id == id).firstOrNull)
      .nonNulls
      .toList();
  final excludedCategories = excluded
      .map((id) => allCategories.where((c) => c.id == id).firstOrNull)
      .nonNulls
      .toList();
  final allExcluded = excludedCategories.length == allCategories.length;

  final includedText = switch (true) {
    _ when includedCategories.isNotEmpty &&
        includedCategories.length != allCategories.length =>
      includedCategories.map((c) => c.name).join(', '),
    _ when includedCategories.length == allCategories.length => allLabel,
    _ when allExcluded => noneLabel,
    _ => allLabel,
  };

  final excludedText = switch (true) {
    _ when excludedCategories.isEmpty => noneLabel,
    _ when allExcluded => allLabel,
    _ => excludedCategories.map((c) => c.name).join(', '),
  };

  return '$includeLabel: $includedText\n$excludeLabel: $excludedText';
}
