import 'package:flutter/material.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/providers/l10n_providers.dart';
import 'package:mangayomi/utils/extensions/build_context_extensions.dart';

/// Tappable link shown during library search to open global extension search.
class LibraryGlobalSearchLink extends StatelessWidget {
  final String query;
  final ItemType itemType;

  const LibraryGlobalSearchLink({
    super.key,
    required this.query,
    required this.itemType,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = l10nLocalizations(context)!;

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        child: InkWell(
          onTap: () => context.push('/globalSearch', extra: (query, itemType)),
          child: Text(
            l10n.search_globally(query),
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }
}
