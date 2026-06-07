import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/modules/browse/feed/providers/feed_state_provider.dart';
import 'package:mangayomi/modules/browse/feed/providers/bulk_favorite_provider.dart';
import 'package:mangayomi/modules/browse/feed/widgets/feed_bulk_bottom_bar.dart';
import 'package:mangayomi/modules/browse/feed/widgets/feed_item_row.dart';
import 'package:mangayomi/modules/browse/source_feed/source_feed_provider.dart';
import 'package:mangayomi/modules/browse/source_feed/widgets/source_feed_add_search_dialog.dart';
import 'package:mangayomi/modules/library/widgets/search_text_form_field.dart';
import 'package:mangayomi/modules/manga/home/manga_home_screen.dart';
import 'package:mangayomi/modules/manga/home/widget/filter_widget.dart';
import 'package:mangayomi/modules/more/providers/incognito_mode_state_provider.dart';
import 'package:mangayomi/providers/l10n_providers.dart';
import 'package:mangayomi/services/get_filter_list.dart';
import 'package:mangayomi/utils/platform_utils.dart';
import 'package:mangayomi/services/get_source_baseurl.dart';
import 'package:mangayomi/utils/extensions/build_context_extensions.dart';
import 'package:mangayomi/utils/global_style.dart';
import 'package:mangayomi/utils/item_type_localization.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class SourceFeedScreen extends ConsumerStatefulWidget {
  final Source source;

  const SourceFeedScreen({super.key, required this.source});

  @override
  ConsumerState<SourceFeedScreen> createState() => _SourceFeedScreenState();
}

class _SourceFeedScreenState extends ConsumerState<SourceFeedScreen> {
  late Source _source = widget.source;
  bool _isSearch = false;
  final _searchController = TextEditingController();
  bool _defaultsReady = false;

  bool get _isLocal => _source.name == 'local' && _source.lang == '';

  @override
  void initState() {
    super.initState();
    _initDefaults();
  }

  Future<void> _initDefaults() async {
    if (_source.id == null) return;
    await ref.read(
      ensureSourceFeedDefaultsProvider(
        sourceId: _source.id!,
        itemType: _source.itemType,
      ).future,
    );
    if (mounted) {
      setState(() => _defaultsReady = true);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilterSheet() async {
    if (_isLocal) return;
    final l10n = context.l10n;
    final filterList = getFilterList(source: _source);
    if (filterList.isEmpty) return;

    var filters = List<dynamic>.from(filterList);
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          filters = getFilterList(source: _source);
                        });
                      },
                      child: Text(l10n.reset),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primaryColor,
                      ),
                      onPressed: () => Navigator.pop(context, 'filter'),
                      child: Text(
                        l10n.filter,
                        style: TextStyle(
                          color: Theme.of(context).scaffoldBackgroundColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: FilterWidget(
                  filterList: filters,
                  onChanged: (values) {
                    setModalState(() => filters = values);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );

    if (result != 'filter' || !mounted) return;

    await Navigator.push(
      context,
      isApple
          ? CupertinoPageRoute(
              builder: (_) => MangaHomeScreen(
                source: _source,
                openWithFilter: true,
                initialFilters: filters,
              ),
            )
          : MaterialPageRoute(
              builder: (_) => MangaHomeScreen(
                source: _source,
                openWithFilter: true,
                initialFilters: filters,
              ),
            ),
    );
  }

  void _markSourceUsed() {
    if (_isLocal || _source.id == null) return;
    final sources = isar.sources
        .filter()
        .idIsNotNull()
        .and()
        .itemTypeEqualTo(_source.itemType)
        .findAllSync();
    isar.writeTxnSync(() {
      for (final src in sources) {
        isar.sources.putSync(
          src
            ..lastUsed = src.id == _source.id
            ..updatedAt = DateTime.now().millisecondsSinceEpoch,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _markSourceUsed();

    final l10n = context.l10n;
    final incognitoMode = ref.watch(incognitoModeStateProvider);

    if (_source.id == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.unknown)),
      );
    }

    final feedStream = ref.watch(
      feedBySourceStreamProvider(
        sourceId: _source.id!,
        itemType: _source.itemType,
      ),
    );
    final bulkScope = FeedBulkScope(
      itemType: _source.itemType,
      sourceId: _source.id,
    );
    final selectionMode = ref.watch(feedBulkSelectionModeProvider(bulkScope));
    final selectionCount =
        ref.watch(feedBulkSelectionProvider(bulkScope)).length;
    final bulkRunning = ref.watch(feedBulkFavoriteRunningProvider(bulkScope));

    return Scaffold(
      appBar: AppBar(
        title: _isSearch
            ? null
            : selectionMode
            ? Text(selectionCount.toString())
            : Text(
                !_isLocal
                    ? _source.name ?? l10n.unknown
                    : '${l10n.local_source} ${_source.itemType.localized(l10n)}',
              ),
        actions: [
          if (_isSearch)
            SeachFormTextField(
              onFieldSubmitted: (query) {
                if (!mounted) return;
                Navigator.push(
                  context,
                  isApple
                      ? CupertinoPageRoute(
                          builder: (_) => MangaHomeScreen(
                            source: _source,
                            isSearch: true,
                            query: query,
                          ),
                        )
                      : MaterialPageRoute(
                          builder: (_) => MangaHomeScreen(
                            source: _source,
                            isSearch: true,
                            query: query,
                          ),
                        ),
                );
                setState(() {
                  _isSearch = false;
                  _searchController.clear();
                });
              },
              onChanged: (_) {},
              onSuffixPressed: () => _searchController.clear(),
              onPressed: () {
                setState(() {
                  _isSearch = false;
                  _searchController.clear();
                });
              },
              controller: _searchController,
            )
          else ...[
            if (selectionMode)
              IconButton(
                onPressed: () {
                  ref
                      .read(feedBulkSelectionModeProvider(bulkScope).notifier)
                      .setMode(false);
                },
                icon: Icon(Icons.clear, color: Theme.of(context).hintColor),
              )
            else ...[
              IconButton(
                splashRadius: 20,
                onPressed: bulkRunning
                    ? null
                    : () {
                        ref
                            .read(
                              feedBulkSelectionModeProvider(bulkScope).notifier,
                            )
                            .toggle();
                      },
                icon: bulkRunning
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).hintColor,
                        ),
                      )
                    : Icon(
                        Icons.checklist_outlined,
                        color: Theme.of(context).hintColor,
                      ),
              ),
              IconButton(
                splashRadius: 20,
                onPressed: () => setState(() => _isSearch = true),
                icon: Icon(Icons.search, color: Theme.of(context).hintColor),
              ),
            IconButton(
              splashRadius: 20,
              onPressed: () {
                ref
                    .read(incognitoModeStateProvider.notifier)
                    .setIncognitoMode(!incognitoMode);
              },
              icon: Icon(
                CupertinoIcons.eyeglasses,
                color: incognitoMode
                    ? context.primaryColor
                    : Theme.of(context).hintColor,
              ),
            ),
            if (!_isLocal)
              PopupMenuButton<int>(
                popUpAnimationStyle: popupAnimationStyle,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 0,
                    child: Text(l10n.open_in_browser),
                  ),
                  PopupMenuItem(
                    value: 1,
                    child: Text(l10n.settings),
                  ),
                ],
                onSelected: (value) async {
                  if (value == 0) {
                    final baseUrl = ref.read(
                      sourceBaseUrlProvider(source: _source),
                    );
                    context.push(
                      '/mangawebview',
                      extra: {
                        'url': baseUrl,
                        'sourceId': _source.id.toString(),
                        'title': '',
                      },
                    );
                  } else {
                    final res = await context.push(
                      '/extension_detail',
                      extra: _source,
                    );
                    if (res != null && mounted) {
                      setState(() => _source = res as Source);
                    }
                  }
                },
              ),
            IconButton(
              tooltip: l10n.action_sort_feed,
              onPressed: () {
                context.push('/sourceFeedOrder', extra: _source);
              },
              icon: Icon(Icons.sort, color: Theme.of(context).hintColor),
            ),
            IconButton(
              onPressed: () {
                showSourceFeedAddDialog(
                  context: context,
                  ref: ref,
                  source: _source,
                );
              },
              icon: Icon(Icons.add_outlined, color: Theme.of(context).hintColor),
            ),
            ],
          ],
        ],
      ),
      bottomNavigationBar: FeedBulkBottomBar(scope: bulkScope),
      floatingActionButton: _isLocal
          ? null
          : FloatingActionButton(
              onPressed: _openFilterSheet,
              child: const Icon(Icons.filter_list_outlined),
            ),
      body: !_defaultsReady
          ? const Center(child: CircularProgressIndicator())
          : feedStream.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(error.toString())),
              data: (feeds) {
                if (feeds.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l10n.source_feed_tab_empty,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(
                    refreshSourceFeedRowsProvider(
                      sourceId: _source.id!,
                      itemType: _source.itemType,
                    ).future,
                  ),
                  child: SuperListView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: feeds.length,
                    extentPrecalculationPolicy: SuperPrecalculationPolicy(),
                    itemBuilder: (context, index) {
                      final feed = feeds[index];
                      if (feed.id == null) {
                        return const SizedBox.shrink();
                      }
                      return FeedItemRow(
                        key: ValueKey(feed.id),
                        feedId: feed.id!,
                        itemType: _source.itemType,
                        showSourceInHeader: false,
                        selectionScope: bulkScope,
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
