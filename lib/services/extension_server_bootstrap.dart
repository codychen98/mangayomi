import 'dart:io';

import 'package:mangayomi/main.dart';
import 'package:mangayomi/modules/more/settings/browse/extension_server/extension_server_utils.dart';
import 'package:mangayomi/utils/portable_paths.dart';
import 'package:path/path.dart' as p;

const String bundledExtensionServerDirName = 'extension_server';

/// Windows portable zips ship a fixed extension-server bundle beside [mangayomi.exe].
/// Auto-wire JRE + JAR paths so desktop extensions work without a manual download step.
Future<bool> ensurePortableExtensionServerConfigured() async {
  if (!PortablePaths.isEnabled) {
    return false;
  }

  final exeDir = p.dirname(Platform.resolvedExecutable);
  final bundledDir = Directory(p.join(exeDir, bundledExtensionServerDirName));
  if (!await bundledDir.exists()) {
    return false;
  }

  final jrePath = await findExtensionServerJavaExecutable(bundledDir);
  final jarPath = await findExtensionServerJar(bundledDir);
  if (jrePath == null || jarPath == null) {
    return false;
  }

  final settings = isar.settings.getSync(227);
  if (settings == null) {
    return false;
  }

  final currentJar = settings.extensionServerPath ?? '';
  final currentJre = settings.jrePath ?? '';
  final currentJarOk =
      currentJar.isNotEmpty && await File(currentJar).exists();
  final currentJreOk =
      currentJre.isNotEmpty && await File(currentJre).exists();

  if (currentJarOk && currentJreOk && currentJar == jarPath && currentJre == jrePath) {
    return false;
  }

  isar.writeTxnSync(
    () => isar.settings.putSync(
      settings
        ..jrePath = jrePath
        ..extensionServerPath = jarPath
        ..updatedAt = DateTime.now().millisecondsSinceEpoch,
    ),
  );
  return true;
}
