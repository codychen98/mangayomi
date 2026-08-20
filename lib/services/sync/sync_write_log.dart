import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/utils/log/logger.dart';

/// Library titles that flipped Miruro -> Anikoto in the 19:09 startup log.
const librarySourceWatchIds = <int>{8, 13, 22};

/// Normalized titles for those rows (pre- and post-migration names).
const librarySourceWatchTitles = <String>{
  'ao no hako',
  'blue box',
  'boku no hero academia final season',
  'my hero academia final season',
  'dandadan 2nd season',
  'dan da dan season 2',
};

void logSyncWrite(String message) {
  AppLogger.log('[SYNC-WRITE] $message');
}

String normalizeMangaTitleForLog(String? name) =>
    (name ?? '').trim().toLowerCase();

/// Same composite key shape as [mangaSyncKey] (kept local to avoid import cycles).
String mangaSyncKeyForLog(Manga manga) =>
    '${manga.itemType.index}|${(manga.source ?? '').trim().toLowerCase()}|'
    '${(manga.link ?? '').trim().toLowerCase()}|'
    '${normalizeMangaTitleForLog(manga.name)}';

String formatMangaSourceRow(Manga? manga) {
  if (manga == null) return 'missing';
  return 'id=${manga.id} title=${manga.name} stored=${manga.source} '
      'sourceId=${manga.sourceId} updatedAt=${manga.updatedAt} '
      'key=${mangaSyncKeyForLog(manga)}';
}

bool mangaMatchesWatchList(Manga manga) {
  if (manga.id != null && librarySourceWatchIds.contains(manga.id)) {
    return true;
  }
  return librarySourceWatchTitles.contains(
    normalizeMangaTitleForLog(manga.name),
  );
}

void logWatchedMangaSnapshot(String phase) {
  final rows = librarySourceWatchIds
      .map((id) => formatMangaSourceRow(isar.mangas.getSync(id)))
      .join(' | ');
  logSyncWrite('$phase $rows');
}

/// Logs every snapshot entry that matches watch ids or watch titles.
void logSnapshotMangaWatch(String phase, List<Manga> manga) {
  final matches = manga.where(mangaMatchesWatchList).toList();
  if (matches.isEmpty) {
    logSyncWrite('$phase watchMatches=0 total=${manga.length}');
    return;
  }
  logSyncWrite('$phase watchMatches=${matches.length} total=${manga.length}');
  for (final entry in matches) {
    logSyncWrite('$phase ${formatMangaSourceRow(entry)}');
  }
}

/// Logs Isar ids that appear more than once in a snapshot manga list.
void logDuplicateMangaIds(String phase, List<Manga> manga) {
  final byId = <int, List<Manga>>{};
  for (final entry in manga) {
    final id = entry.id;
    if (id == null) continue;
    byId.putIfAbsent(id, () => <Manga>[]).add(entry);
  }
  final dupes = byId.entries.where((e) => e.value.length > 1).toList();
  if (dupes.isEmpty) {
    logSyncWrite('$phase duplicateIds=0');
    return;
  }
  logSyncWrite('$phase duplicateIds=${dupes.length}');
  for (final entry in dupes) {
    final rows = entry.value.map(formatMangaSourceRow).join(' || ');
    logSyncWrite('$phase duplicateId=${entry.key} count=${entry.value.length} $rows');
  }
}

/// Counts anime favorites by source name in a snapshot (compact summary).
void logSnapshotSourceCounts(String phase, List<Manga> manga) {
  var miruro = 0;
  var anikoto = 0;
  var other = 0;
  for (final entry in manga) {
    if (entry.favorite != true) continue;
    if (entry.itemType != ItemType.anime) continue;
    final source = (entry.source ?? '').toLowerCase();
    if (source.contains('miruro')) {
      miruro++;
    } else if (source.contains('anikoto')) {
      anikoto++;
    } else {
      other++;
    }
  }
  logSyncWrite(
    '$phase animeFavorites miruro=$miruro anikoto=$anikoto other=$other',
  );
}
