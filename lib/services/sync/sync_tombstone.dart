import 'dart:convert';
import 'dart:io';

import 'package:mangayomi/utils/portable_paths.dart';
import 'package:path_provider/path_provider.dart';

/// Append only: indices are persisted in the WebDAV file and local store.
enum SyncTombstoneEntity { extension, savedSearch, feed, chapter }

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
    final parsed = SyncTombstone.tryFromJson(json);
    if (parsed == null) {
      throw FormatException('Unknown tombstone entity: ${json['entity']}');
    }
    return parsed;
  }

  /// Returns null for entity indices this build does not know about so a
  /// newer peer's file does not break decoding.
  static SyncTombstone? tryFromJson(Map<String, dynamic> json) {
    final index = json['entity'] as int? ?? 0;
    if (index < 0 || index >= SyncTombstoneEntity.values.length) {
      return null;
    }
    return SyncTombstone(
      entity: SyncTombstoneEntity.values[index],
      key: json['key'] as String? ?? '',
      deletedAt: json['deletedAt'] as int? ?? 0,
    );
  }

  String get compositeKey => '${entity.index}|$key';

  Map<String, dynamic> toJson() => {
    'entity': entity.index,
    'key': key,
    'deletedAt': deletedAt,
  };
}

/// Parses a JSON list of tombstones, skipping entries with unknown entities.
List<SyncTombstone> parseSyncTombstoneList(Object? raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map(
        (entry) => SyncTombstone.tryFromJson(Map<String, dynamic>.from(entry)),
      )
      .whereType<SyncTombstone>()
      .toList();
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
      return parseSyncTombstoneList(jsonDecode(await file.readAsString()));
    } catch (_) {
      return const [];
    }
  }

  static Future<void> record(SyncTombstone tombstone) {
    return recordAll([tombstone]);
  }

  /// Records several tombstones with a single read/write of the store file.
  static Future<void> recordAll(List<SyncTombstone> tombstones) async {
    if (tombstones.isEmpty) return;
    try {
      final existing = await loadAll();
      final merged = <String, SyncTombstone>{
        for (final entry in existing) entry.compositeKey: entry,
        for (final entry in tombstones) entry.compositeKey: entry,
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
          .where((entry) => !keys.contains(entry.compositeKey))
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

  /// Records chapter/episode deletions so WebDAV merge stops re-adding them.
  /// [keys] come from `chapterTombstoneKey` in `sync_entity_keys.dart`.
  static Future<void> recordChaptersDeleted(Iterable<String> keys) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return recordAll([
      for (final key in keys)
        SyncTombstone(
          entity: SyncTombstoneEntity.chapter,
          key: key,
          deletedAt: now,
        ),
    ]);
  }
}
