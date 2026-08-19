import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/utils/log/logger.dart';
import 'package:mangayomi/utils/utils.dart';

/// Label for library tabs/badges: live [Sources.name] when present, else stored.
String resolveLibrarySourceName({
  required bool isLocalArchive,
  required String? storedSource,
  required String? liveSourceName,
}) {
  if (isLocalArchive) return 'Local';
  final live = liveSourceName?.trim();
  if (live != null && live.isNotEmpty) return live;
  return storedSource ?? '';
}

Source? liveSourceForId(int? sourceId) {
  if (sourceId == null) return null;
  return isar.sources.getSync(sourceId);
}

String? _lastLibrarySourceSignature;

void resetLibrarySourceSnapshotLog() {
  _lastLibrarySourceSignature = null;
}

/// Compact snapshot for cold-start diagnosis. Deduped by stored/live/id signature.
void logLibrarySourceSnapshot({
  required String reason,
  required ItemType itemType,
  required List<Manga> favorites,
  required String groupsSummary,
}) {
  final rows = <String>[];
  for (final manga in favorites) {
    if (manga.isLocalArchive == true) continue;
    final live = liveSourceForId(manga.sourceId);
    final selected = getSource(
      manga.lang ?? '',
      manga.source ?? '',
      manga.sourceId,
    );
    final stored = manga.source ?? '';
    final liveName = live?.name ?? '';
    final selectedName = selected?.name ?? '';
    final flags = <String>[
      if (stored.isNotEmpty &&
          liveName.isNotEmpty &&
          stored.toLowerCase() != liveName.toLowerCase())
        'STORED_NE_LIVE',
      if (stored.isNotEmpty &&
          selectedName.isNotEmpty &&
          stored.toLowerCase() != selectedName.toLowerCase())
        'GETSOURCE_NE_STORED',
      if (live == null && manga.sourceId != null) 'LIVE_MISSING',
      if (live != null && (live.sourceCode == null || live.sourceCode!.isEmpty))
        'NO_SOURCE_CODE',
    ];
    rows.add(
      'id=${manga.id} title=${manga.name} stored=$stored sourceId=${manga.sourceId} '
      'live=${liveName.isEmpty ? "null" : liveName} '
      'getSource=${selectedName.isEmpty ? "null" : selectedName}'
      '${flags.isEmpty ? '' : ' flags=${flags.join(",")}'}',
    );
  }

  final signature = '${itemType.name}|$groupsSummary|${rows.join(';')}';
  if (signature == _lastLibrarySourceSignature) return;
  _lastLibrarySourceSignature = signature;

  const cap = 60;
  final truncated = rows.length > cap;
  final shown = truncated ? rows.sublist(0, cap) : rows;
  AppLogger.log(
    '[LIB-SOURCE] reason=$reason itemType=${itemType.name} '
    'favorites=${favorites.length} groups=$groupsSummary',
  );
  for (final row in shown) {
    AppLogger.log('[LIB-SOURCE] $row');
  }
  if (truncated) {
    AppLogger.log('[LIB-SOURCE] truncated remaining=${rows.length - cap}');
  }
}
