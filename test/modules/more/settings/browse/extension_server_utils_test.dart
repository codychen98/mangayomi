import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mangayomi/modules/more/settings/browse/extension_server/extension_server_utils.dart';
import 'package:path/path.dart' as path;

void main() {
  group('compareExtensionServerVersions', () {
    test('orders semver segments numerically', () {
      expect(compareExtensionServerVersions('1.0.4', '1.0.1'), greaterThan(0));
      expect(compareExtensionServerVersions('1.0.1', '1.0.4'), lessThan(0));
      expect(compareExtensionServerVersions('1.0.4', '1.0.4'), 0);
    });
  });

  group('findExtensionServerJar', () {
    test('returns the newest jar when multiple versions exist', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'extension-server-utils-test-',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final oldJar = File(
        path.join(tempDir.path, 'MExtensionServer-v1.0.1-r1.jar'),
      );
      final newJar = File(
        path.join(tempDir.path, 'MExtensionServer-v1.0.4-r1.jar'),
      );
      await oldJar.writeAsString('old');
      await newJar.writeAsString('new');

      final resolvedJar = await findExtensionServerJar(tempDir);

      expect(resolvedJar, newJar.path);
    });
  });
}
