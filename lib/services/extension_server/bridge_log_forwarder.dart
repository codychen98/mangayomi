import 'dart:async';

import 'package:m_extension_server/m_extension_server.dart';
import 'package:mangayomi/services/extension_server/bridge_log_line.dart';
import 'package:mangayomi/utils/log/logger.dart';

/// Polls the desktop ApkBridge launcher for stdout/stderr and writes
/// `[BRIDGE]` lines into [AppLogger].
class BridgeLogForwarder {
  BridgeLogForwarder._();

  static final BridgeLogForwarder instance = BridgeLogForwarder._();

  static const _pollInterval = Duration(seconds: 1);

  Timer? _timer;
  bool _draining = false;
  bool _loggedDrainError = false;

  /// Starts a 1 s poll loop. No-op if already running.
  void start() {
    if (_timer != null) {
      return;
    }
    _loggedDrainError = false;
    _timer = Timer.periodic(_pollInterval, (_) {
      unawaited(_onTick());
    });
  }

  /// Drains once more, then cancels the poller.
  Future<void> stop() async {
    final timer = _timer;
    _timer = null;
    timer?.cancel();
    await _drainOnce();
  }

  Future<void> _onTick() async {
    if (_draining) {
      return;
    }
    _draining = true;
    try {
      await _drainOnce();
    } finally {
      _draining = false;
    }
  }

  Future<void> _drainOnce() async {
    try {
      final lines = await MExtensionServer().drainServerLogs();
      for (final raw in lines) {
        final parsed = BridgeLogLine.parse(raw);
        if (parsed == null) {
          continue;
        }
        AppLogger.log(
          '[BRIDGE] ${parsed.message}',
          logLevel: parsed.level,
        );
      }
    } catch (e) {
      if (!_loggedDrainError) {
        _loggedDrainError = true;
        AppLogger.log(
          '[BRIDGE] drainServerLogs failed: $e',
          logLevel: LogLevel.warning,
        );
      }
    }
  }
}
