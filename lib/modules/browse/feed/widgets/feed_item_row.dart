import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';
import 'package:mangayomi/eval/model/m_manga.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/modules/browse/feed/providers/feed_provider.dart';
import 'package:mangayomi/modules/browse/feed/providers/bulk_favorite_provider.dart';
import 'package:mangayomi/modules/browse/feed/widgets/feed_delete_dialog.dart';
import 'package:mangayomi/modules/manga/home/manga_home_screen.dart';
import 'package:mangayomi/modules/widgets/manga_image_card_widget.dart';
import 'package:mangayomi/providers/l10n_providers.dart';
import 'package:mangayomi/services/feed/feed_constants.dart';
import 'package:mangayomi/services/feed/feed_labels.dart';
import 'package:mangayomi/services/feed/saved_search_filters.dart';
import 'package:mangayomi/services/feed/saved_search_repository.dart';
import 'package:mangayomi/utils/language.dart';
import 'package:mangayomi/utils/platform_utils.dart';
import 'package:mangayomi/utils/super_precalculation_policy.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class FeedItemRow extends ConsumerWidget {
  final int feedId;
  final ItemType itemType;
  final bool showSourceInHeader;
  final FeedBulkScope? selectionScope;

  const FeedItemRow({
    super.key,
    required this.feedId,
    required this.itemType,
    this.showSourceInHeader = true,
    this.selectionScope,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = l10nLocalizations(context)!;
    final rowAsync = ref.watch(feedRowProvider(feedId));

    return rowAsync.when(
      loading: () => const SizedBox(
        height: 260,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => SizedBox(
        height: 80,
        child: Center(child: Text(error.toString())),
      ),
      data: (row) => SizedBox(
        height: 260,
        child: Column(
          children: [
            ListTile(
              dense: true,
              onTap: () => _onHeaderTap(context, row),
              onLongPress: () => showFeedDeleteDialog(
                context: context,
                ref: ref,
                feed: row.feed,
                title: row.title,
              ),
              title: Text(
                showSourceInHeader
                    ? '${row.source.name} - ${localizeFeedItemTitle(row.title, l10n)}'
                    : localizeFeedItemTitle(row.title, l10n),
              ),
              subtitle: Text(
                completeLanguageName(row.source.lang?.toLowerCase() ?? ''),
                style: const TextStyle(fontSize: 10),
              ),
              trailing: const Icon(Icons.arrow_forward_sharp),
            ),
            Flexible(
              child: Builder(
                builder: (context) {
                  if (row.error != null) {
                    return Center(child: Text(row.error!));
                  }
                  if (row.mangas.isEmpty) {
                    return Center(child: Text(l10n.no_result));
                  }
                  return SuperListView.builder(
                    extentPrecalculationPolicy: SuperPrecalculationPolicy(),
                    scrollDirection: Axis.horizontal,
                    itemCount: row.mangas.length,
                    itemBuilder: (context, index) {
                      final manga = row.mangas[index];
                      return Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: _FeedMangaCard(
                          manga: manga,
                          source: row.source,
                          itemType: itemType,
                          selectionScope: selectionScope,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onHeaderTap(BuildContext context, FeedRowState row) {
    final savedSearchId = row.feed.savedSearchId;
    if (savedSearchId == null) {
      context.push('/mangaHome', extra: (row.source, true));
      return;
    }

    SavedSearchRepository.instance.getById(savedSearchId).then((savedSearch) {
      if (!context.mounted) return;
      if (isFeedPopularSavedSearch(savedSearch)) {
        context.push('/mangaHome', extra: (row.source, false));
        return;
      }
      if (savedSearch == null) {
        context.push('/mangaHome', extra: (row.source, false));
        return;
      }

      final filters = deserializeSavedSearchFilters(savedSearch.filtersJson);
      final query = savedSearch.query ?? '';
      final hasFilters = filters.isNotEmpty;
      final hasQuery = query.isNotEmpty;

      Navigator.push(
        context,
        isApple
            ? CupertinoPageRoute(
                builder: (_) => MangaHomeScreen(
                  source: row.source,
                  openWithFilter: hasFilters,
                  initialFilters: hasFilters ? filters : null,
                  query: query,
                  isSearch: hasQuery,
                ),
              )
            : MaterialPageRoute(
                builder: (_) => MangaHomeScreen(
                  source: row.source,
                  openWithFilter: hasFilters,
                  initialFilters: hasFilters ? filters : null,
                  query: query,
                  isSearch: hasQuery,
                ),
              ),
      );
    });
  }
}

class _FeedMangaCard extends ConsumerWidget {
  final MManga manga;
  final Source source;
  final ItemType itemType;
  final FeedBulkScope? selectionScope;

  const _FeedMangaCard({
    required this.manga,
    required this.source,
    required this.itemType,
    this.selectionScope,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = selectionScope;
    final selectionMode = scope == null
        ? false
        : ref.watch(feedBulkSelectionModeProvider(scope));
    final selection = scope == null
        ? const <String, FeedSelectionEntry>{}
        : ref.watch(feedBulkSelectionProvider(scope));
    final entry = scope == null || source.id == null
        ? null
        : feedSelectionEntry(
            manga: manga,
            sourceId: source.id!,
            sourceName: source.name!,
            sourceLang: source.lang!,
            itemType: itemType,
          );

    return StreamBuilder<List<Manga>>(
      stream: manga.name == null
          ? Stream.value(<Manga>[])
          : isar.mangas
                .filter()
                .sourceEqualTo(source.name)
                .and()
                .langEqualTo(source.lang)
                .and()
                .nameEqualTo(manga.name!)
                .watch(fireImmediately: true),
      builder: (context, snapshot) {
        final libraryManga = snapshot.hasData && snapshot.data!.isNotEmpty
            ? snapshot.data!.firstWhere(
                (m) => m.sourceId == null || m.sourceId == source.id,
                orElse: () => snapshot.data!.first,
              )
            : null;

        return SizedBox(
          width: 110,
          child: MangaImageCardWidget(
            source: source,
            getMangaDetail: manga,
            isComfortableGrid: true,
            itemType: itemType,
            libraryManga: libraryManga,
            selectionMode: selectionMode,
            isSelected: entry != null && selection.containsKey(entry.key),
            onSelectionToggle: entry == null || scope == null
                ? null
                : () {
                    final notifier = ref.read(
                      feedBulkSelectionProvider(scope).notifier,
                    );
                    if (selectionMode) {
                      notifier.toggle(scope, entry);
                    } else {
                      notifier.enterWith(scope, entry);
                    }
                  },
          ),
        );
      },
    );
  }
}
