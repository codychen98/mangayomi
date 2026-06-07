import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/modules/more/settings/browse/providers/browse_state_provider.dart';
import 'package:mangayomi/modules/more/settings/reader/providers/reader_state_provider.dart';
import 'package:mangayomi/providers/l10n_providers.dart';
import 'package:mangayomi/providers/storage_provider.dart';
import 'package:mangayomi/modules/browse/extension/extension_screen.dart';
import 'package:mangayomi/modules/browse/feed/feed_screen.dart';
import 'package:mangayomi/modules/browse/feed/providers/bulk_favorite_provider.dart';
import 'package:mangayomi/modules/browse/feed/widgets/feed_add_dialog.dart';
import 'package:mangayomi/modules/browse/feed/widgets/feed_bulk_bottom_bar.dart';
import 'package:mangayomi/modules/browse/sources/sources_screen.dart';
import 'package:mangayomi/modules/library/widgets/search_text_form_field.dart';
import 'package:mangayomi/services/fetch_sources_list.dart';
import 'package:mangayomi/utils/item_type_localization.dart';

class BrowseScreen extends ConsumerStatefulWidget {
  const BrowseScreen({super.key});

  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

enum BrowseTabKind { feed, sources, extensions }

class BrowseTab {
  final ItemType type;
  final BrowseTabKind kind;

  const BrowseTab(this.type, this.kind);
}

class _BrowseScreenState extends ConsumerState<BrowseScreen>
    with TickerProviderStateMixin {
  late final hideItems = ref.read(hideItemsStateProvider);
  final _textEditingController = TextEditingController();
  TabController? _tabBarController;

  List<BrowseTab> _buildTabList({
    required bool hideFeedTab,
    required bool feedTabInFront,
  }) {
    final types = <ItemType>[
      if (!hideItems.contains("/MangaLibrary")) ItemType.manga,
      if (!hideItems.contains("/AnimeLibrary")) ItemType.anime,
      if (!hideItems.contains("/NovelLibrary")) ItemType.novel,
    ];

    final tabs = <BrowseTab>[];
    for (final type in types) {
      if (feedTabInFront && !hideFeedTab) {
        tabs.add(BrowseTab(type, BrowseTabKind.feed));
      }
      tabs.add(BrowseTab(type, BrowseTabKind.sources));
      if (!feedTabInFront && !hideFeedTab) {
        tabs.add(BrowseTab(type, BrowseTabKind.feed));
      }
    }
    for (final type in types) {
      tabs.add(BrowseTab(type, BrowseTabKind.extensions));
    }
    return tabs;
  }

  void _onTabChanged() {
    _chekPermission();
    setState(() {
      _textEditingController.clear();
      _isSearch = false;
    });
  }

  int _pendingTabLength = 0;

  void _replaceTabController(int length) {
    if (length <= 0) return;
    final previousIndex = _tabBarController?.index ?? 0;
    _tabBarController?.removeListener(_onTabChanged);
    _tabBarController?.dispose();
    _tabBarController = TabController(
      length: length,
      vsync: this,
      initialIndex: previousIndex.clamp(0, length - 1),
    )..addListener(_onTabChanged);
    _pendingTabLength = length;
  }

  void _scheduleTabControllerSync(int length) {
    if (length <= 0) return;
    if (_tabBarController?.length == length) {
      _pendingTabLength = length;
      return;
    }
    if (_pendingTabLength == length) return;
    _pendingTabLength = length;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _pendingTabLength != length) return;
      _replaceTabController(length);
      setState(() {});
    });
  }

  Future<void> _chekPermission() async {
    await StorageProvider().requestPermission();
  }

  @override
  void dispose() {
    _tabBarController?.removeListener(_onTabChanged);
    _tabBarController?.dispose();
    _textEditingController.dispose();
    super.dispose();
  }

  bool _isSearch = false;
  @override
  Widget build(BuildContext context) {
    final hideFeedTab = ref.watch(hideFeedTabStateProvider);
    final feedTabInFront = ref.watch(feedTabInFrontStateProvider);
    final tabList = _buildTabList(
      hideFeedTab: hideFeedTab,
      feedTabInFront: feedTabInFront,
    );

    if (tabList.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_tabBarController == null) {
      _replaceTabController(tabList.length);
    } else {
      _scheduleTabControllerSync(tabList.length);
    }

    final controller = _tabBarController;
    if (controller == null || controller.length != tabList.length) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final currentTab = tabList[controller.index];
    final isExtensionTab = currentTab.kind == BrowseTabKind.extensions;
    final isFeedTab = currentTab.kind == BrowseTabKind.feed;
    final feedBulkScope = isFeedTab
        ? FeedBulkScope(itemType: currentTab.type)
        : null;
    final feedSelectionMode = feedBulkScope == null
        ? false
        : ref.watch(feedBulkSelectionModeProvider(feedBulkScope));
    final feedSelectionCount = feedBulkScope == null
        ? 0
        : ref.watch(feedBulkSelectionProvider(feedBulkScope)).length;
    final feedBulkRunning = feedBulkScope == null
        ? false
        : ref.watch(feedBulkFavoriteRunningProvider(feedBulkScope));

    final l10n = l10nLocalizations(context)!;
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: feedSelectionMode
              ? Text(feedSelectionCount.toString())
              : Text(
                  l10n.browse,
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
          actions: [
            _isSearch
                ? SeachFormTextField(
                    onChanged: (value) {
                      setState(() {});
                    },
                    onSuffixPressed: () {
                      _textEditingController.clear();
                    },
                    onPressed: () {
                      setState(() {
                        _isSearch = false;
                      });
                      _textEditingController.clear();
                    },
                    controller: _textEditingController,
                  )
                : Row(
                    children: [
                      if (isFeedTab) ...[
                        if (feedSelectionMode)
                          IconButton(
                            onPressed: () {
                              ref
                                  .read(
                                    feedBulkSelectionModeProvider(
                                      feedBulkScope!,
                                    ).notifier,
                                  )
                                  .setMode(false);
                            },
                            icon: Icon(
                              Icons.clear,
                              color: Theme.of(context).hintColor,
                            ),
                          )
                        else ...[
                          IconButton(
                            onPressed: feedBulkRunning
                                ? null
                                : () {
                                    ref
                                        .read(
                                          feedBulkSelectionModeProvider(
                                            feedBulkScope!,
                                          ).notifier,
                                        )
                                        .toggle();
                                  },
                            icon: feedBulkRunning
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
                            tooltip: l10n.action_sort_feed,
                            onPressed: () {
                              context.push('/feedOrder', extra: currentTab.type);
                            },
                            icon: Icon(
                              Icons.sort,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              showFeedAddDialog(
                                context: context,
                                ref: ref,
                                itemType: currentTab.type,
                              );
                            },
                            icon: Icon(
                              Icons.add_outlined,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ],
                      if (isExtensionTab)
                        IconButton(
                          onPressed: () {
                            context.push('/createExtension');
                          },
                          icon: Icon(
                            Icons.add_outlined,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      if (!isFeedTab)
                        IconButton(
                          splashRadius: 20,
                          onPressed: () {
                            if (isExtensionTab) {
                              setState(() {
                                _isSearch = true;
                              });
                            } else {
                              context.push(
                                '/globalSearch',
                                extra: (null, currentTab.type),
                              );
                            }
                          },
                          icon: Icon(
                            !isExtensionTab
                                ? Icons.travel_explore_rounded
                                : Icons.search_rounded,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                    ],
                  ),
            if (!isFeedTab)
              IconButton(
                splashRadius: 20,
                onPressed: () {
                  context.push(
                    isExtensionTab ? '/ExtensionLang' : '/sourceFilter',
                    extra: currentTab.type,
                  );
                },
                icon: Icon(
                  !isExtensionTab
                      ? Icons.filter_list_sharp
                      : Icons.translate_rounded,
                  color: Theme.of(context).hintColor,
                ),
              ),
          ],
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.label,
            isScrollable: true,
            controller: controller,
            tabs: tabList.map((tab) {
              final type = tab.type;
              final isExt = tab.kind == BrowseTabKind.extensions;
              final isFeed = tab.kind == BrowseTabKind.feed;

              return Tab(
                child: Row(
                  children: [
                    Text(
                      isFeed
                          ? type.localizedFeed(l10n)
                          : isExt
                          ? type.localizedExtensions(l10n)
                          : type.localizedSources(l10n),
                    ),
                    if (isExt) ...[
                      const SizedBox(width: 8),
                      _extensionUpdateNumbers(ref, type),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        bottomNavigationBar: feedBulkScope == null
            ? null
            : FeedBulkBottomBar(scope: feedBulkScope),
        body: TabBarView(
          controller: controller,
          children: tabList.map((tab) {
            if (tab.kind == BrowseTabKind.feed) {
              return FeedScreen(
                itemType: tab.type,
                selectionScope: FeedBulkScope(itemType: tab.type),
              );
            }
            if (tab.kind == BrowseTabKind.sources) {
              return SourcesScreen(
                itemType: tab.type,
                tabs: tabList,
                tabIndex: (index) => controller.animateTo(index),
              );
            }
            return ExtensionScreen(
              query: _textEditingController.text,
              itemType: tab.type,
            );
          }).toList(),
        ),
    );
  }
}

Widget _extensionUpdateNumbers(WidgetRef ref, ItemType itemType) {
  return StreamBuilder(
    stream: isar.sources
        .filter()
        .idIsNotNull()
        .and()
        .isActiveEqualTo(true)
        .itemTypeEqualTo(itemType)
        .watch(fireImmediately: true),
    builder: (context, snapshot) {
      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
        final entries = snapshot.data!
            .where(
              (element) =>
                  compareVersions(element.version!, element.versionLast!) < 0,
            )
            .toList();
        return entries.isEmpty
            ? SizedBox.shrink()
            : Badge(
                backgroundColor: Theme.of(context).focusColor,
                label: Text(
                  entries.length.toString(),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall!.color,
                  ),
                ),
              );
      }
      return Container();
    },
  );
}
