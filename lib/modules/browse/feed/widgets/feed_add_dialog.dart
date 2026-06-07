import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/modules/browse/feed/widgets/feed_add_search_dialog.dart';
import 'package:mangayomi/modules/more/settings/browse/providers/browse_state_provider.dart';
import 'package:mangayomi/providers/l10n_providers.dart';
import 'package:mangayomi/utils/cached_network.dart';
import 'package:mangayomi/utils/item_type_localization.dart';
import 'package:mangayomi/utils/language.dart';

Future<void> showFeedAddDialog({
  required BuildContext context,
  required WidgetRef ref,
  required ItemType itemType,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => _FeedAddDialog(itemType: itemType),
  );
}

class _FeedAddDialog extends ConsumerStatefulWidget {
  final ItemType itemType;

  const _FeedAddDialog({required this.itemType});

  @override
  ConsumerState<_FeedAddDialog> createState() => _FeedAddDialogState();
}

class _FeedAddDialogState extends ConsumerState<_FeedAddDialog> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nLocalizations(context)!;
    final showNSFW = ref.watch(showNSFWStateProvider);

    return AlertDialog(
      title: Text(l10n.add_to_feed_for_type(widget.itemType.localized(l10n))),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.search,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
              onChanged: (value) => setState(() => _query = value.trim()),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<Source>>(
                stream: isar.sources
                    .filter()
                    .idIsNotNull()
                    .and()
                    .isAddedEqualTo(true)
                    .and()
                    .isActiveEqualTo(true)
                    .and()
                    .itemTypeEqualTo(widget.itemType)
                    .watch(fireImmediately: true),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final sources = snapshot.data!
                      .where((source) => showNSFW || !(source.isNsfw ?? false))
                      .where(
                        (source) =>
                            _query.isEmpty ||
                            (source.name?.toLowerCase().contains(
                                  _query.toLowerCase(),
                                ) ??
                                false),
                      )
                      .toList()
                    ..sort(
                      (a, b) => (a.name ?? '').compareTo(b.name ?? ''),
                    );

                  if (sources.isEmpty) {
                    return Center(child: Text(l10n.no_sources_installed));
                  }

                  return ListView.builder(
                    itemCount: sources.length,
                    itemBuilder: (context, index) {
                      final source = sources[index];
                      return ListTile(
                        leading: _sourceIcon(source),
                        title: Text(source.name ?? l10n.unknown),
                        subtitle: Text(
                          completeLanguageName(source.lang!.toLowerCase()),
                          style: const TextStyle(fontSize: 11),
                        ),
                        onTap: () => _onSourceSelected(context, source),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }

  Widget _sourceIcon(Source source) {
    return SizedBox(
      width: 36,
      height: 36,
      child: source.iconUrl == null || source.iconUrl!.isEmpty
          ? const Icon(Icons.extension_rounded)
          : ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: cachedNetworkImage(
                imageUrl: source.iconUrl!,
                fit: BoxFit.contain,
                width: 36,
                height: 36,
                errorWidget: const Icon(Icons.extension_rounded),
                useCustomNetworkImage: false,
              ),
            ),
    );
  }

  Future<void> _onSourceSelected(BuildContext context, Source source) async {
    final savedSearches = await isar.savedSearchs
        .filter()
        .sourceIdEqualTo(source.id!)
        .and()
        .itemTypeEqualTo(widget.itemType)
        .findAll();

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (searchContext) => FeedAddSearchDialog(
        source: source,
        itemType: widget.itemType,
        savedSearches: savedSearches,
      ),
    );
  }
}
