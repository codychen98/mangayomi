import 'package:isar_community/isar.dart';
import 'package:mangayomi/eval/model/m_manga.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/source.dart';

class MassMigrationSourceGroup {
  const MassMigrationSourceGroup({
    required this.sourceName,
    required this.itemType,
    required this.items,
    this.source,
    this.lang,
    this.sourceId,
    this.fromLibrarySelection = false,
  });

  final String sourceName;
  final Source? source;
  final String? lang;
  final int? sourceId;
  final ItemType itemType;
  final List<Manga> items;
  final bool fromLibrarySelection;

  int get count => items.length;
}

class MassMigrationSearchResult {
  const MassMigrationSearchResult({
    required this.queries,
    required this.candidates,
    this.selected,
    this.usedQuery,
  });

  final List<String> queries;
  final List<MManga> candidates;
  final MManga? selected;
  final String? usedQuery;

  bool get hasMatch => selected != null;
}

class MassMigrationResolvedItem {
  const MassMigrationResolvedItem({
    required this.sourceItem,
    required this.searchResult,
    this.selectedCandidate,
    this.destinationPreview,
    this.errorMessage,
    this.shouldMigrate = false,
  });

  final Manga sourceItem;
  final MassMigrationSearchResult searchResult;
  final MManga? selectedCandidate;
  final MManga? destinationPreview;
  final String? errorMessage;
  final bool shouldMigrate;

  bool get hasMatch => selectedCandidate != null;
  bool get canMigrate =>
      selectedCandidate != null &&
      destinationPreview != null &&
      (errorMessage == null || errorMessage!.isEmpty);

  MassMigrationResolvedItem copyWith({
    MManga? selectedCandidate,
    MManga? destinationPreview,
    String? errorMessage,
    bool? shouldMigrate,
    bool keepSelectedCandidate = true,
    bool keepDestinationPreview = true,
    bool keepErrorMessage = true,
  }) {
    return MassMigrationResolvedItem(
      sourceItem: sourceItem,
      searchResult: searchResult,
      selectedCandidate: keepSelectedCandidate
          ? selectedCandidate ?? this.selectedCandidate
          : selectedCandidate,
      destinationPreview: keepDestinationPreview
          ? destinationPreview ?? this.destinationPreview
          : destinationPreview,
      errorMessage: keepErrorMessage
          ? errorMessage ?? this.errorMessage
          : errorMessage,
      shouldMigrate: shouldMigrate ?? this.shouldMigrate,
    );
  }
}

/// Builds a migration group from Library multi-select IDs (anime favorites only).
MassMigrationSourceGroup? buildMassMigrationGroupFromSelectedIds(
  Iterable<int> mangaIds,
) {
  final items = mangaIds
      .map((id) => isar.mangas.getSync(id))
      .whereType<Manga>()
      .where(
        (manga) =>
            manga.itemType == ItemType.anime &&
            (manga.favorite ?? false) &&
            (manga.source ?? '').trim().isNotEmpty,
      )
      .toList();

  if (items.isEmpty) return null;

  final sortedItems = [...items]
    ..sort(
      (left, right) => (left.name ?? '').toLowerCase().compareTo(
        (right.name ?? '').toLowerCase(),
      ),
    );

  final distinctSources = sortedItems
      .map((manga) => '${manga.source?.trim()}|${manga.lang ?? ''}')
      .toSet();
  final first = sortedItems.first;
  final isSingleSource = distinctSources.length == 1;
  final source = isSingleSource
      ? (first.sourceId != null
            ? isar.sources.getSync(first.sourceId!)
            : isar.sources
                  .filter()
                  .nameEqualTo(first.source)
                  .langEqualTo(first.lang)
                  .findFirstSync())
      : null;

  return MassMigrationSourceGroup(
    sourceName: isSingleSource
        ? (first.source ?? '').trim()
        : 'Selected (${sortedItems.length})',
    source: source,
    lang: isSingleSource ? first.lang : null,
    sourceId: isSingleSource ? first.sourceId : null,
    itemType: ItemType.anime,
    items: sortedItems,
    fromLibrarySelection: true,
  );
}

List<MassMigrationSourceGroup> buildMassMigrationSourceGroups({
  required ItemType itemType,
  Manga? prioritizedManga,
}) {
  final libraryItems = isar.mangas
      .filter()
      .favoriteEqualTo(true)
      .itemTypeEqualTo(itemType)
      .findAllSync();

  final grouped = <String, List<Manga>>{};
  for (final manga in libraryItems) {
    final sourceName = (manga.source ?? '').trim();
    if (sourceName.isEmpty) continue;
    grouped.putIfAbsent(sourceName, () => []).add(manga);
  }

  final groups = grouped.entries.map((entry) {
    final items = [...entry.value]
      ..sort(
        (left, right) => (left.name ?? '').toLowerCase().compareTo(
          (right.name ?? '').toLowerCase(),
        ),
      );
    final first = items.first;
    final source = first.sourceId != null
        ? isar.sources.getSync(first.sourceId!)
        : isar.sources
              .filter()
              .nameEqualTo(first.source)
              .langEqualTo(first.lang)
              .findFirstSync();
    return MassMigrationSourceGroup(
      sourceName: entry.key,
      source: source,
      lang: first.lang,
      sourceId: first.sourceId,
      itemType: itemType,
      items: items,
    );
  }).toList();

  groups.sort((left, right) {
    final prioritizedSource = prioritizedManga?.source?.trim().toLowerCase();
    final leftPriority = left.sourceName.toLowerCase() == prioritizedSource;
    final rightPriority = right.sourceName.toLowerCase() == prioritizedSource;
    if (leftPriority != rightPriority) {
      return leftPriority ? -1 : 1;
    }
    final nameCompare = left.sourceName.toLowerCase().compareTo(
      right.sourceName.toLowerCase(),
    );
    if (nameCompare != 0) return nameCompare;
    return right.count.compareTo(left.count);
  });

  return groups;
}

List<Source> buildMassMigrationDestinationSources({
  required MassMigrationSourceGroup sourceGroup,
}) {
  final sources = isar.sources
      .filter()
      .isAddedEqualTo(true)
      .itemTypeEqualTo(sourceGroup.itemType)
      .findAllSync()
      .where((source) {
        if (source.sourceCode == null) return false;
        if (sourceGroup.fromLibrarySelection &&
            sourceGroup.sourceId == null &&
            sourceGroup.lang == null) {
          return true;
        }
        if (sourceGroup.sourceId != null) {
          return source.id != sourceGroup.sourceId;
        }
        return !(source.name == sourceGroup.sourceName &&
            source.lang == sourceGroup.lang);
      })
      .toList();

  sources.sort((left, right) {
    final nameCompare = (left.name ?? '').toLowerCase().compareTo(
      (right.name ?? '').toLowerCase(),
    );
    if (nameCompare != 0) return nameCompare;
    return (left.lang ?? '').toLowerCase().compareTo(
      (right.lang ?? '').toLowerCase(),
    );
  });
  return sources;
}
