import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangayomi/models/saved_search.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/modules/browse/feed/providers/feed_state_provider.dart';
import 'package:mangayomi/modules/manga/home/widgets/saved_search_dialogs.dart';
import 'package:mangayomi/services/feed/feed_constants.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class SavedSearchChips extends ConsumerWidget {
  final Source source;
  final int? selectedSavedSearchId;
  final void Function(SavedSearch savedSearch) onTap;
  final VoidCallback? onSelectionCleared;

  const SavedSearchChips({
    super.key,
    required this.source,
    required this.onTap,
    this.selectedSavedSearchId,
    this.onSelectionCleared,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (source.id == null) return const SizedBox.shrink();

    final savedSearchesAsync = ref.watch(
      savedSearchBySourceStreamProvider(
        sourceId: source.id!,
        itemType: source.itemType,
      ),
    );

    return savedSearchesAsync.when(
      data: (savedSearches) {
        final userSearches = savedSearches
            .where((search) => !isFeedPopularSavedSearch(search))
            .toList();
        if (userSearches.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 40,
          child: SuperListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: userSearches.length,
            itemBuilder: (context, index) {
              final savedSearch = userSearches[index];
              final selected = savedSearch.id == selectedSavedSearchId;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onLongPress: () => handleSavedSearchLongPress(
                    context: context,
                    ref: ref,
                    savedSearch: savedSearch,
                  ),
                  child: ActionChip(
                    label: Text(
                      savedSearch.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: selected
                            ? Theme.of(context).colorScheme.onPrimary
                            : null,
                      ),
                    ),
                    backgroundColor: selected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    onPressed: () {
                      if (selected) {
                        onSelectionCleared?.call();
                      } else {
                        onTap(savedSearch);
                      }
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
