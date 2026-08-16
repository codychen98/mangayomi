import 'package:flutter/material.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/settings.dart';
import 'package:mangayomi/modules/library/library_source_group.dart';
import 'package:mangayomi/modules/library/widgets/library_app_bar.dart';

/// Library scaffold with TabBar / TabBarView grouped by source.
class LibrarySourceTabsView extends StatefulWidget {
  final ItemType itemType;
  final List<Manga> favorites;
  final Settings settings;
  final bool showNumbersOfItems;
  final bool isNotFiltering;
  final int numberOfItems;
  final List<Manga> entries;
  final bool isSearch;
  final bool ignoreFiltersOnSearch;
  final TextEditingController textEditingController;
  final VoidCallback onSearchToggle;
  final VoidCallback onSearchClear;
  final ValueChanged<bool> onIgnoreFiltersChanged;
  final TickerProvider vsync;
  final Widget Function(LibrarySourceGroup sourceGroup) bodyForSource;
  final Widget Function(LibrarySourceGroup sourceGroup) badgeForSource;
  final Widget Function() flatBody;

  const LibrarySourceTabsView({
    super.key,
    required this.itemType,
    required this.favorites,
    required this.settings,
    required this.showNumbersOfItems,
    required this.isNotFiltering,
    required this.numberOfItems,
    required this.entries,
    required this.isSearch,
    required this.ignoreFiltersOnSearch,
    required this.textEditingController,
    required this.onSearchToggle,
    required this.onSearchClear,
    required this.onIgnoreFiltersChanged,
    required this.vsync,
    required this.bodyForSource,
    required this.badgeForSource,
    required this.flatBody,
  });

  @override
  State<LibrarySourceTabsView> createState() => _LibrarySourceTabsViewState();
}

class _LibrarySourceTabsViewState extends State<LibrarySourceTabsView>
    with TickerProviderStateMixin {
  TabController? _tabController;
  int _tabIndex = 0;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _syncTabController(int tabCount) {
    if (tabCount <= 0) {
      _tabController?.dispose();
      _tabController = null;
      _tabIndex = 0;
      return;
    }
    if (_tabController == null || _tabController!.length != tabCount) {
      var newIndex = _tabIndex;
      if (newIndex >= tabCount) newIndex = tabCount - 1;
      _tabController?.dispose();
      _tabController = TabController(
        length: tabCount,
        vsync: this,
        initialIndex: newIndex,
      );
      _tabIndex = newIndex;
      _tabController!.addListener(() {
        if (!mounted) return;
        setState(() => _tabIndex = _tabController!.index);
      });
    }
  }

  LibraryAppBar _appBar() {
    return LibraryAppBar(
      itemType: widget.itemType,
      isNotFiltering: widget.isNotFiltering,
      showNumbersOfItems: widget.showNumbersOfItems,
      numberOfItems: widget.numberOfItems,
      entries: widget.entries,
      isCategory: false,
      categoryId: null,
      settings: widget.settings,
      isSearch: widget.isSearch,
      ignoreFiltersOnSearch: widget.ignoreFiltersOnSearch,
      textEditingController: widget.textEditingController,
      onSearchToggle: widget.onSearchToggle,
      onSearchClear: widget.onSearchClear,
      onIgnoreFiltersChanged: widget.onIgnoreFiltersChanged,
      vsync: widget.vsync,
    );
  }

  @override
  Widget build(BuildContext context) {
    final groups = distinctLibrarySourceGroups(widget.favorites);
    if (groups.isEmpty) {
      _syncTabController(0);
      return Scaffold(appBar: _appBar(), body: widget.flatBody());
    }

    _syncTabController(groups.length);

    return Scaffold(
      appBar: _appBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            isScrollable: true,
            controller: _tabController,
            tabs: [
              for (final group in groups)
                Row(
                  children: [
                    Tab(text: group.label),
                    if (widget.showNumbersOfItems) ...[
                      const SizedBox(width: 4),
                      widget.badgeForSource(group),
                    ],
                  ],
                ),
            ],
          ),
          Flexible(
            child: TabBarView(
              controller: _tabController,
              children: [
                for (final group in groups) widget.bodyForSource(group),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
