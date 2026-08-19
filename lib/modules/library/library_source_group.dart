import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/modules/library/library_source_name.dart';

/// Identity of a library source tab / filter (immutable).
class LibrarySourceGroup {
  final int? sourceId;
  final String source;
  final String lang;
  final bool isLocal;

  const LibrarySourceGroup({
    this.sourceId,
    required this.source,
    required this.lang,
    required this.isLocal,
  });

  factory LibrarySourceGroup.fromManga(Manga manga) {
    if (manga.isLocalArchive == true) {
      return const LibrarySourceGroup(
        sourceId: null,
        source: 'Local',
        lang: '',
        isLocal: true,
      );
    }
    final live = liveSourceForId(manga.sourceId);
    return LibrarySourceGroup(
      sourceId: manga.sourceId,
      source: resolveLibrarySourceName(
        isLocalArchive: false,
        storedSource: manga.source,
        liveSourceName: live?.name,
      ),
      lang: manga.lang ?? '',
      isLocal: false,
    );
  }

  /// Stable map/tab key: local, prefer [sourceId], else source + lang.
  String get groupKey {
    if (isLocal) return 'local';
    if (sourceId != null) return 'id:$sourceId';
    return 'src:$source|${lang.toLowerCase()}';
  }

  /// Tab / badge label: `Local`, `Name`, or `Name (LANG)`.
  String get label {
    if (isLocal) return 'Local';
    final trimmedLang = lang.trim();
    if (trimmedLang.isEmpty) return source;
    return '$source (${trimmedLang.toUpperCase()})';
  }

  /// Cover/list chip: `Local`; with language badge on → name only; else [label].
  String coverBadgeLabel({required bool languageBadgeVisible}) {
    if (isLocal) return 'Local';
    if (languageBadgeVisible && source.isNotEmpty) return source;
    return label;
  }

  bool matches(Manga manga) {
    if (isLocal) return manga.isLocalArchive == true;
    if (manga.isLocalArchive == true) return false;
    if (sourceId != null) return manga.sourceId == sourceId;
    return manga.sourceId == null &&
        (manga.source ?? '') == source &&
        (manga.lang ?? '') == lang;
  }

  @override
  bool operator ==(Object other) {
    return other is LibrarySourceGroup &&
        other.isLocal == isLocal &&
        other.sourceId == sourceId &&
        other.source == source &&
        other.lang == lang;
  }

  @override
  int get hashCode => Object.hash(isLocal, sourceId, source, lang);
}

/// Distinct source groups from favorites, sorted by label (case-insensitive).
List<LibrarySourceGroup> distinctLibrarySourceGroups(List<Manga> favorites) {
  final byKey = <String, LibrarySourceGroup>{};
  for (final manga in favorites) {
    final group = LibrarySourceGroup.fromManga(manga);
    byKey.putIfAbsent(group.groupKey, () => group);
  }
  final groups = byKey.values.toList()
    ..sort(
      (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
    );
  return List<LibrarySourceGroup>.unmodifiable(groups);
}
