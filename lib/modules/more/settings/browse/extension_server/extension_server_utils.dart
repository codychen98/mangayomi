import 'dart:ffi';
import 'dart:io';

import 'package:mangayomi/utils/extensions/string_extensions.dart';
import 'package:path/path.dart' as path;

const extensionServerFallbackVersion = '1.0.0';
const extensionServerJarPrefix = 'MExtensionServer-';
const extensionServerInstalledReleaseFileName =
    'extension_server_installed_release.txt';
const extensionServerReleaseApiUrl =
    'https://api.github.com/repos/codychen98/M-Extension-Server/releases?page=1&per_page=10';
const apkBridgeReleaseUrl =
    'https://github.com/Schnitzel5/ApkBridge/releases/latest';

String? extensionServerDirectoryFromPaths({
  required String jrePath,
  required String extensionServerPath,
}) {
  if (extensionServerPath.isNotEmpty) {
    return path.dirname(extensionServerPath);
  }
  if (jrePath.isNotEmpty) {
    return path.dirname(jrePath);
  }
  return null;
}

Future<String?> findExtensionServerJavaExecutable(Directory root) async {
  final executableName = Platform.isWindows ? 'java.exe' : 'java';
  final preferredPath = path.join(
    root.path,
    'jre',
    'jre',
    'bin',
    executableName,
  );
  if (await File(preferredPath).exists()) {
    return preferredPath;
  }
  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is File &&
        path.basename(entity.path).toLowerCase() == executableName) {
      return entity.path;
    }
  }
  return null;
}

String? extractExtensionServerVersion(String value) {
  final match = RegExp(r'v?(\d+(?:\.\d+)+)').firstMatch(value);
  return match?.group(1);
}

int compareExtensionServerVersions(String version1, String version2) {
  final v1Parts = version1.split('.');
  final v2Parts = version2.split('.');
  final minLength = v1Parts.length < v2Parts.length
      ? v1Parts.length
      : v2Parts.length;

  for (var i = 0; i < minLength; i++) {
    final v1Value = int.parse(v1Parts[i].padRight(2, '0'));
    final v2Value = int.parse(v2Parts[i].padRight(2, '0'));
    final comparison = v1Value.compareTo(v2Value);
    if (comparison != 0) return comparison;
  }

  return v1Parts.length.compareTo(v2Parts.length);
}

Future<String?> findExtensionServerJar(Directory root) async {
  String? newestPath;
  String? newestVersion;
  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    final fileName = path.basename(entity.path);
    if (!fileName.startsWith(extensionServerJarPrefix) ||
        !fileName.endsWith('.jar')) {
      continue;
    }
    final version =
        extractExtensionServerVersion(fileName) ??
        extensionServerFallbackVersion;
    if (newestVersion == null ||
        compareExtensionServerVersions(version, newestVersion) > 0) {
      newestVersion = version;
      newestPath = entity.path;
    }
  }
  return newestPath;
}

Future<void> removeExtensionServerJars(Directory root) async {
  if (!await root.exists()) return;
  await for (final entity in root.list(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    final fileName = path.basename(entity.path);
    if (!fileName.startsWith(extensionServerJarPrefix) ||
        !fileName.endsWith('.jar')) {
      continue;
    }
    try {
      await entity.delete();
    } catch (_) {}
  }
}

String? extensionServerAssetNameForCurrentPlatform() {
  final abi = Abi.current();
  if (Platform.isIOS) {
    return abi == Abi.iosArm64 ? 'macOS-arm64-bundle.zip' : null;
  }
  if (Platform.isWindows) {
    return abi == Abi.windowsX64 ? 'windows-x64-bundle.zip' : null;
  }
  if (Platform.isLinux) {
    return abi == Abi.linuxX64 ? 'linux-x64-bundle.zip' : null;
  }
  if (Platform.isMacOS) {
    return switch (abi) {
      Abi.macosArm64 => 'macOS-arm64-bundle.zip',
      Abi.macosX64 => 'macOS-x64-bundle.zip',
      _ => null,
    };
  }
  return null;
}

String resolveInstalledExtensionServerVersion(String extensionServerPath) {
  if (extensionServerPath.isEmpty) return '';
  final installDir = path.dirname(extensionServerPath);
  final versionFile = File(
    path.join(installDir, extensionServerInstalledReleaseFileName),
  );
  if (versionFile.existsSync()) {
    final fromFile = versionFile.readAsStringSync().trim();
    if (fromFile.isNotEmpty) {
      return extractExtensionServerVersion(fromFile) ?? fromFile;
    }
  }
  return extractExtensionServerVersion(path.basename(extensionServerPath)) ??
      extensionServerFallbackVersion;
}

Future<void> writeInstalledExtensionServerReleaseVersion(
  String installDirectory,
  String releaseVersion,
) async {
  if (installDirectory.isEmpty || releaseVersion.isEmpty) return;
  final versionFile = File(
    path.join(installDirectory, extensionServerInstalledReleaseFileName),
  );
  await versionFile.writeAsString(releaseVersion);
}

String resolveExtensionServerReleaseVersion(Map<String, dynamic> release) {
  final versionSource =
      release['tag_name']?.toString() ??
      release['name']?.toString() ??
      extensionServerFallbackVersion;
  return extractExtensionServerVersion(versionSource) ??
      versionSource.substringAfter('v').substringBefore('-');
}
