import 'package:isar_community/isar.dart';
import 'package:mangayomi/models/manga.dart';

/// Collapses [manga] so each real Isar [Manga.id] appears at most once.
///
/// Winner per id: highest [Manga.updatedAt]; ties prefer a non-null
/// [Manga.sourceId], then the lexicographically greater sync identity key
/// (`itemType|source|link|name`, same shape as [mangaSyncKey]).
/// Entries with a null id or [Isar.autoIncrement] are kept as-is (not
/// collapsed together). Output order follows first appearance of each id
/// (and each non-collapsible row).
List<Manga> collapseMangaById(List<Manga> manga) {
  final winnersById = <int, Manga>{};
  final order = <Object>[];

  for (final entry in manga) {
    final id = entry.id;
    if (!_hasCollapsibleId(id)) {
      order.add(entry);
      continue;
    }

    final existing = winnersById[id];
    if (existing == null) {
      winnersById[id!] = entry;
      order.add(id);
      continue;
    }

    if (_isBetterCollapseCandidate(entry, existing)) {
      winnersById[id!] = entry;
    }
  }

  return [
    for (final item in order)
      if (item is Manga) item else winnersById[item as int]!,
  ];
}

bool _hasCollapsibleId(Id? id) => id != null && id != Isar.autoIncrement;

bool _isBetterCollapseCandidate(Manga candidate, Manga current) {
  final candidateUpdated = candidate.updatedAt ?? 0;
  final currentUpdated = current.updatedAt ?? 0;
  if (candidateUpdated != currentUpdated) {
    return candidateUpdated > currentUpdated;
  }

  final candidateHasSourceId = candidate.sourceId != null;
  final currentHasSourceId = current.sourceId != null;
  if (candidateHasSourceId != currentHasSourceId) {
    return candidateHasSourceId;
  }

  return _mangaCollapseTieBreakKey(candidate)
          .compareTo(_mangaCollapseTieBreakKey(current)) >
      0;
}

/// Matches [mangaSyncKey] without importing sync_merger (avoids cycles).
String _mangaCollapseTieBreakKey(Manga manga) {
  String norm(String? value) => (value ?? '').trim().toLowerCase();
  return '${manga.itemType.index}|${norm(manga.source)}|'
      '${norm(manga.link)}|${norm(manga.name)}';
}
