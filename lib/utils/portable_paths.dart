import 'dart:io';

import 'package:path/path.dart' as p;

/// Windows portable builds keep all profile data next to [mangayomi.exe].
///
/// Detection (in order):
/// 1. `portable.marker` file beside the executable (CI portable zips ship this)
/// 2. `MANGAYOMI_PORTABLE=1` environment variable
class PortablePaths {
  static const markerFileName = 'portable.marker';

  static bool? _enabled;

  static bool get isEnabled {
    _enabled ??= _detect();
    return _enabled!;
  }

  static bool _detect() {
    if (!Platform.isWindows) return false;

    final env = Platform.environment['MANGAYOMI_PORTABLE']?.toLowerCase();
    if (env == '1' || env == 'true' || env == 'yes') return true;

    try {
      final exeDir = p.dirname(Platform.resolvedExecutable);
      return File(p.join(exeDir, markerFileName)).existsSync();
    } catch (_) {
      return false;
    }
  }

  static String? get _exeDirectory {
    try {
      return p.dirname(Platform.resolvedExecutable);
    } catch (_) {
      return null;
    }
  }

  /// Root for all portable profile data. Flutter's own `data/` folder is separate.
  static String get dataRoot {
    final exeDir = _exeDirectory;
    if (exeDir == null) {
      throw StateError('Cannot resolve mangayomi.exe directory for portable mode');
    }
    return p.join(exeDir, 'userdata');
  }

  static String get documentsPath => dataRoot;

  static String get supportPath => p.join(dataRoot, 'support');

  static String get cachePath => p.join(dataRoot, 'cache');

  static Future<Directory> documentsDirectory() async {
    final dir = Directory(documentsPath);
    await dir.create(recursive: true);
    return dir;
  }

  static Future<Directory> supportDirectory() async {
    final dir = Directory(supportPath);
    await dir.create(recursive: true);
    return dir;
  }

  static Future<Directory> cacheDirectory() async {
    final dir = Directory(cachePath);
    await dir.create(recursive: true);
    return dir;
  }
}
