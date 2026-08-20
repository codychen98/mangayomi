import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/utils/log/logger.dart';

/// Library titles that flipped Miruro -> Anikoto in the 19:09 startup log.
const librarySourceWatchIds = <int>{8, 13, 22};

void logSyncWrite(String message) {
  AppLogger.log('[SYNC-WRITE] $message');
}

String formatMangaSourceRow(Manga? manga) {
  if (manga == null) return 'missing';
  return 'id=${manga.id} title=${manga.name} stored=${manga.source} '
      'sourceId=${manga.sourceId}';
}

void logWatchedMangaSnapshot(String phase) {
  final rows = librarySourceWatchIds
      .map((id) => formatMangaSourceRow(isar.mangas.getSync(id)))
      .join(' | ');
  logSyncWrite('$phase $rows');
}
