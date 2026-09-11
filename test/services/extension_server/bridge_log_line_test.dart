import 'package:flutter_test/flutter_test.dart';
import 'package:mangayomi/services/extension_server/bridge_log_line.dart';
import 'package:mangayomi/utils/log/logger.dart';

void main() {
  group('BridgeLogLine.parse', () {
    test('coloured ERROR line strips ANSI and maps to error', () {
      const raw =
          '21:01:23.456 [main] \x1B[31mERROR\x1B[0m android.util.Log - '
          '[AnikotoTheme]: M3U8 server start failed: bind';
      final parsed = BridgeLogLine.parse(raw);
      expect(parsed, isNotNull);
      expect(parsed!.level, LogLevel.error);
      expect(parsed.message, isNot(contains('\x1B')));
      expect(parsed.message, contains('ERROR'));
      expect(parsed.message, contains('[AnikotoTheme]: M3U8 server start failed'));
    });

    test('plain INFO line maps to info', () {
      const raw =
          '21:01:23.456 [main] INFO  suwayomi.tachidesk.MainKt - '
          'Running MExtensionServer v1.0.5 revision abc';
      final parsed = BridgeLogLine.parse(raw);
      expect(parsed, isNotNull);
      expect(parsed!.level, LogLevel.info);
      expect(
        parsed.message,
        contains('Running MExtensionServer v1.0.5 revision abc'),
      );
    });

    test('stack-trace continuation maps to error', () {
      const raw =
          '\tat eu.kanade.tachiyomi.animesource.online.AnimeHttpSource'
          '.getVideoList(AnimeHttpSource.kt:42)';
      final parsed = BridgeLogLine.parse(raw);
      expect(parsed, isNotNull);
      expect(parsed!.level, LogLevel.error);
      expect(parsed.message.trimLeft(), startsWith('at '));
    });

    test('empty line is skipped', () {
      expect(BridgeLogLine.parse(''), isNull);
      expect(BridgeLogLine.parse('   '), isNull);
      expect(BridgeLogLine.parse('\r\n'), isNull);
      expect(BridgeLogLine.parse('\x1B[0m'), isNull);
    });

    test('dropped N lines synthetic line maps to info', () {
      const raw = '[m_extension_server] dropped 12 lines';
      final parsed = BridgeLogLine.parse(raw);
      expect(parsed, isNotNull);
      expect(parsed!.level, LogLevel.info);
      expect(parsed.message, raw);
    });

    test('collapses carriage returns and caps message length', () {
      final long = 'x' * 2500;
      final parsed = BridgeLogLine.parse('line\r with\r cr$long');
      expect(parsed, isNotNull);
      expect(parsed!.message.contains('\r'), isFalse);
      expect(parsed.message.length, 2000);
    });
  });
}
