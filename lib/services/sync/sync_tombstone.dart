import 'dart:convert';
import 'dart:io';

import 'package:mangayomi/utils/portable_paths.dart';
import 'package:path_provider/path_provider.dart';

enum SyncTombstoneEntity { extension, savedSearch, feed }

class SyncTombstone {
  final SyncTombstoneEntity entity;
  final String key;
  final int deletedAt;

  const SyncTombstone({
    required this.entity,
    required this.key,
    required this.deletedAt,
  });

  factory SyncTombstone.fromJson(Map<String, dynamic> json) {
    return SyncTombstone(
      entity: SyncTombstoneEntity.values[json['entity'] as int? ?? 0],
      key: json['key'] as String? ?? '',
      deletedAt: json['deletedAt'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'entity': entity.index,
    'key': key,
    'deletedAt': deletedAt,
  };
}

/// Records deletions locally so WebDAV sync can propagate removes across devices.
class SyncTombstoneStore {
  static const _fileName = 'sync_tombstones.json';

  static Future<File> get _file async {
    final dir = PortablePaths.isEnabled
        ? await PortablePaths.supportDirectory()
        : await getApplicationSupportDirectory();
    return File('${dir.path}/$_fileName');
  }

  static Future<List<SyncTombstone>> loadAll() async {
    try {
      final file = await _file;
      if (!await file.exists()) return const [];
      final raw = jsonDecode(await file.readAsString());
      if (raw is! List) return const [];
      return raw
          .map((e) => SyncTombstone.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static Future<void> record(SyncTombstone tombstone) async {
    try {
      final existing = await loadAll();
      final merged = <String, SyncTombstone>{
        for (final entry in existing)
          '${entry.entity.index}|${entry.key}': entry,
        '${tombstone.entity.index}|${tombstone.key}': tombstone,
      };
      final file = await _file;
      await file.writeAsString(
        jsonEncode(merged.values.map((e) => e.toJson()).toList()),
      );
    } catch (_) {
      // Best-effort
    }
  }

  static Future<void> clearKeys(Iterable<String> compositeKeys) async {
    if (compositeKeys.isEmpty) return;
    try {
      final keys = compositeKeys.toSet();
      final existing = await loadAll();
      final remaining = existing
          .where(
            (entry) => !keys.contains('${entry.entity.index}|${entry.key}'),
          )
          .toList();
      final file = await _file;
      if (remaining.isEmpty) {
        if (await file.exists()) await file.delete();
        return;
      }
      await file.writeAsString(
        jsonEncode(remaining.map((e) => e.toJson()).toList()),
      );
    } catch (_) {
      // Best-effort
    }
  }

  static Future<void> recordExtensionDeleted(int sourceId) {
    return record(
      SyncTombstone(
        entity: SyncTombstoneEntity.extension,
        key: '$sourceId',
        deletedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  static Future<void> recordSavedSearchDeleted(String key) {
    return record(
      SyncTombstone(
        entity: SyncTombstoneEntity.savedSearch,
        key: key,
        deletedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  static Future<void> recordFeedDeleted(String key) {
    return record(
      SyncTombstone(
        entity: SyncTombstoneEntity.feed,
        key: key,
        deletedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
