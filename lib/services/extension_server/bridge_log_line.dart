import 'package:mangayomi/utils/log/logger.dart';

/// Parsed ApkBridge / logback stdout line for forwarding into [AppLogger].
class BridgeLogLine {
  const BridgeLogLine({required this.level, required this.message});

  final LogLevel level;
  final String message;

  static final RegExp _ansiEscape = RegExp(r'\x1B\[[0-9;]*m');
  static final RegExp _logbackLevel = RegExp(
    r'^\d{2}:\d{2}:\d{2}\.\d{3}\s+\[[^\]]*\]\s+'
    r'(TRACE|DEBUG|INFO|WARN|ERROR)\b',
  );

  static const int _maxMessageLength = 2000;

  /// Parses a raw JVM stdout/stderr line.
  ///
  /// Returns `null` for empty / whitespace-only input (after `\r` collapse and
  /// ANSI strip). Otherwise returns a level plus the cleaned message (capped
  /// at 2000 characters).
  static BridgeLogLine? parse(String raw) {
    final cleaned = raw
        .replaceAll('\r', '')
        .replaceAll(_ansiEscape, '');
    if (cleaned.trim().isEmpty) {
      return null;
    }

    final message = cleaned.length <= _maxMessageLength
        ? cleaned
        : cleaned.substring(0, _maxMessageLength);

    return BridgeLogLine(level: _resolveLevel(cleaned), message: message);
  }

  static LogLevel _resolveLevel(String cleaned) {
    final match = _logbackLevel.firstMatch(cleaned);
    if (match != null) {
      return _mapLogbackLevel(match.group(1)!);
    }
    return _inferJvmLineLevel(cleaned);
  }

  static LogLevel _mapLogbackLevel(String token) {
    switch (token) {
      case 'ERROR':
        return LogLevel.error;
      case 'WARN':
        return LogLevel.warning;
      case 'DEBUG':
      case 'TRACE':
        return LogLevel.debug;
      case 'INFO':
      default:
        return LogLevel.info;
    }
  }

  /// JVM lines without a logback level token (stack frames, launcher errors).
  static LogLevel _inferJvmLineLevel(String line) {
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('at ') || line.contains('Exception')) {
      return LogLevel.error;
    }
    return LogLevel.info;
  }
}
