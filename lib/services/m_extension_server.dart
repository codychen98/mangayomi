import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:m_extension_server/m_extension_server.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/settings.dart';
import 'package:mangayomi/modules/more/settings/browse/providers/browse_state_provider.dart';
import 'package:mangayomi/services/extension_server_bootstrap.dart';
import 'package:mangayomi/utils/platform_utils.dart';

const _dalvikReadyTimeout = Duration(seconds: 15);
const _dalvikReadyPollInterval = Duration(milliseconds: 500);

Future<bool> isExtensionServerDalvikReady(String baseUrl) async {
  if (baseUrl.isEmpty || baseUrl == 'http://127.0.0.1:0') return false;
  try {
    final res = await http
        .post(
          Uri.parse('$baseUrl/dalvik'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'method': 'headersManga', 'data': ''}),
        )
        .timeout(const Duration(seconds: 3));
    return res.statusCode == 200;
  } catch (_) {
    return false;
  }
}

class MExtensionServerPlatform {
  WidgetRef ref;
  MExtensionServerPlatform(this.ref);

  Future<bool> check() async {
    if (_baseUrl == "http://127.0.0.1:0") return false;
    try {
      final res = await http.get(Uri.parse("$_baseUrl/"));
      if (res.statusCode == 200) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<String> ensureDalvikProxyReady() async {
    await startServer();
    final deadline = DateTime.now().add(_dalvikReadyTimeout);
    while (DateTime.now().isBefore(deadline)) {
      final proxy = ref.read(androidProxyServerStateProvider);
      if (await isExtensionServerDalvikReady(proxy)) {
        return proxy;
      }
      await Future.delayed(_dalvikReadyPollInterval);
    }
    return ref.read(androidProxyServerStateProvider);
  }

  Future<void> startServer() async {
    try {
      if (isDesktop) {
        await ensurePortableExtensionServerConfigured();
        final settings = isar.settings.getSync(227);
        final jrePath = settings?.jrePath;
        final serverJarPath = settings?.extensionServerPath;
        if ((jrePath?.isEmpty ?? true) || (serverJarPath?.isEmpty ?? true)) {
          return;
        }
        if (!await File(jrePath!).exists() ||
            !await File(serverJarPath!).exists()) {
          return;
        }
        final currentUrl = ref.read(androidProxyServerStateProvider);
        if (await isExtensionServerDalvikReady(currentUrl)) {
          return;
        }
        await MExtensionServer().stopServer();
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final port = server.port;
        await server.close();
        await MExtensionServer().startServer(
          port,
          jvmPath: jrePath,
          serverJarPath: serverJarPath,
        );
        ref
            .read(androidProxyServerStateProvider.notifier)
            .set("http://127.0.0.1:$port");
        return;
      }

      final isRunning = await check();
      if (!isRunning) {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final port = server.port;
        await server.close();
        await MExtensionServer().startServer(port);
        ref
            .read(androidProxyServerStateProvider.notifier)
            .set("http://127.0.0.1:$port");
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> stopServer() async {
    try {
      await MExtensionServer().stopServer();
    } catch (_) {}
  }

  String get _baseUrl => ref.watch(androidProxyServerStateProvider);
}
