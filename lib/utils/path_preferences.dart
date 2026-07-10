import 'dart:convert';
import 'dart:io';

import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/settings.dart';
import 'package:mangayomi/utils/portable_paths.dart';
import 'package:path_provider/path_provider.dart';

/// Persists device-local storage paths outside the Isar DB so portable
/// rebuilds can restore them even if the database is reset.
class PathPreferences {
  static const _fileName = 'path_preferences.json';

  static Future<File> get _file async {
    final dir = PortablePaths.isEnabled
        ? await PortablePaths.supportDirectory()
        : await getApplicationSupportDirectory();
    return File('${dir.path}/$_fileName');
  }

  static Future<void> save({
    String? downloadLocation,
    String? autoBackupLocation,
  }) async {
    try {
      final file = await _file;
      Map<String, dynamic> json = {};
      if (await file.exists()) {
        json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      }
      if (downloadLocation != null) {
        json['downloadLocation'] = downloadLocation;
      }
      if (autoBackupLocation != null) {
        json['autoBackupLocation'] = autoBackupLocation;
      }
      await file.writeAsString(jsonEncode(json));
    } catch (_) {
      // Best-effort persistence
    }
  }

  static Future<void> restoreIntoIsarIfNeeded() async {
    try {
      final file = await _file;
      final settings = isar.settings.getSync(227);
      if (settings == null) return;

      if (!await file.exists()) {
        final download = settings.downloadLocation ?? '';
        final backup = settings.autoBackupLocation ?? '';
        if (download.isNotEmpty || backup.isNotEmpty) {
          await save(
            downloadLocation: download,
            autoBackupLocation: backup,
          );
        }
        return;
      }

      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final savedDownload = json['downloadLocation'] as String?;
      final savedBackup = json['autoBackupLocation'] as String?;

      final currentDownload = settings.downloadLocation ?? '';
      final currentBackup = settings.autoBackupLocation ?? '';
      final needsDownload =
          currentDownload.isEmpty && (savedDownload?.isNotEmpty ?? false);
      final needsBackup =
          currentBackup.isEmpty && (savedBackup?.isNotEmpty ?? false);
      if (!needsDownload && !needsBackup) return;

      isar.writeTxnSync(() {
        final latest = isar.settings.getSync(227);
        if (latest == null) return;
        isar.settings.putSync(
          latest
            ..downloadLocation = needsDownload ? savedDownload : latest.downloadLocation
            ..autoBackupLocation = needsBackup ? savedBackup : latest.autoBackupLocation
            ..updatedAt = DateTime.now().millisecondsSinceEpoch,
        );
      });
    } catch (_) {
      // Ignore corrupted or missing file
    }
  }
}
