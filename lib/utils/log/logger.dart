import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/settings.dart';
import 'package:mangayomi/providers/storage_provider.dart';
import 'package:path/path.dart' as path;

class AppLogger {
  static const isolateLogPrefix = 'AppLog:';

  static File? _logFile;
  static IOSink? _sink;
  static bool _initialized = false;
  static bool _busy = false;

  /// Set in the extension isolate so [log] can forward lines to the root isolate.
  static SendPort? isolateLogPort;

  /// Initialize the logger
  static Future<void> init() async {
    if (_initialized || _busy) return;
    _busy = true;
    try {
      final enabled = (await isar.settings.get(227))?.enableLogs ?? false;
      if (!enabled) return;
      final storage = StorageProvider();
      final directory = await storage.getDefaultDirectory();
      _logFile = File(path.join(directory!.path, 'logs.txt'));

      if (await _logFile!.exists() &&
          await _logFile!.length() > 5 * 1024 * 1024) {
        await _logFile!.delete();
      }

      if (!await _logFile!.exists()) {
        await _logFile!.create(recursive: true);
      }

      _sink = _logFile!.openWrite(mode: FileMode.append);
      _initialized = true;

      log('\n\nLogger initialized\n\n');
    } finally {
      _busy = false;
    }
  }

  static void log(String message, {LogLevel logLevel = LogLevel.info}) {
    final port = isolateLogPort;
    if (port != null) {
      port.send('$isolateLogPrefix${logLevel.toString()}:$message');
      return;
    }
    if (!_initialized || _sink == null) return;

    final now = DateTime.now();
    final timestamp =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year.toString().padLeft(4, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    final logMessage = '[$timestamp][${logLevel.toString()}] $message';
    _sink!.writeln(logMessage);
  }

  /// Returns true when [message] is an isolate-forwarded log line.
  static bool tryHandleIsolateMessage(String message) {
    if (!message.startsWith(isolateLogPrefix)) return false;
    final payload = message.substring(isolateLogPrefix.length);
    final sep = payload.indexOf(':');
    if (sep == -1) {
      log(payload);
      return true;
    }
    final levelName = payload.substring(0, sep);
    final body = payload.substring(sep + 1);
    final level = LogLevel.values.firstWhere(
      (l) => l.toString() == levelName,
      orElse: () => LogLevel.info,
    );
    log(body, logLevel: level);
    return true;
  }

  static Future<void> dispose() async {
    if (!_initialized || _busy) return;
    _busy = true;
    try {
      await _sink?.flush();
      await _sink?.close();
      _sink = null;
      _logFile = null;
      _initialized = false;
    } finally {
      _busy = false;
    }
  }
}

enum LogLevel {
  debug,
  info,
  warning,
  error;

  @override
  String toString() {
    switch (this) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.error:
        return 'ERROR';
    }
  }
}
