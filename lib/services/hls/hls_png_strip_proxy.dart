import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:mangayomi/services/http/m_client.dart';
import 'package:mangayomi/services/http/rhttp/src/model/settings.dart';
import 'package:mangayomi/utils/extensions/string_extensions.dart';
import 'package:mangayomi/utils/log/logger.dart';

/// Loopback proxy that rewrites HLS playlists and strips a leading PNG disguise
/// from media segments so desktop libmpv/ffmpeg can demux them.
class HlsPngStripProxy {
  HttpServer? _server;
  Map<String, String> _headers = const {};
  StreamSubscription<HttpRequest>? _subscription;
  final http.Client _client;

  HlsPngStripProxy({http.Client? client})
    : _client =
          client ??
          MClient.httpClient(
            settings: const ClientSettings(
              throwOnStatusCode: false,
              tlsSettings: TlsSettings(verifyCertificates: false),
            ),
          );

  bool get isRunning => _server != null;

  /// Starts (or restarts) the proxy and returns a loopback URL for [m3u8Url].
  Future<String> startFor(
    String m3u8Url, {
    Map<String, String>? headers,
  }) async {
    await stop();
    _headers = Map<String, String>.from(headers ?? const {});
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _subscription = _server!.listen(_handleRequest);
    final proxyUrl = proxyUriFor(m3u8Url);
    AppLogger.log(
      '[HLS-PNG] proxy started port=${_server!.port} '
      'upstream=${m3u8Url.toLogSafeUri()} headerCount=${_headers.length}',
    );
    return proxyUrl;
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    await _server?.close(force: true);
    _server = null;
  }

  String proxyUriFor(String upstreamUrl) {
    final port = _server?.port;
    if (port == null) {
      throw StateError('HlsPngStripProxy is not running');
    }
    return 'http://127.0.0.1:$port/p?u=${Uri.encodeQueryComponent(upstreamUrl)}';
  }

  Future<void> _handleRequest(HttpRequest request) async {
    try {
      if (request.method != 'GET') {
        request.response.statusCode = HttpStatus.methodNotAllowed;
        await request.response.close();
        return;
      }
      final upstream = request.uri.queryParameters['u'];
      if (upstream == null || upstream.isEmpty) {
        request.response.statusCode = HttpStatus.badRequest;
        await request.response.close();
        return;
      }
      final response = await _client.get(
        Uri.parse(upstream),
        headers: _headers,
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        request.response.statusCode = response.statusCode;
        request.response.write(response.bodyBytes);
        await request.response.close();
        return;
      }
      final bytes = response.bodyBytes;
      if (isHlsPlaylist(bytes)) {
        final rewritten = rewritePlaylist(
          utf8.decode(bytes, allowMalformed: true),
          upstream,
          'http://127.0.0.1:${_server!.port}/p',
        );
        request.response.headers.contentType = ContentType(
          'application',
          'vnd.apple.mpegurl',
          charset: 'utf-8',
        );
        request.response.write(rewritten);
      } else {
        final stripped = stripPngPrefix(bytes);
        request.response.headers.contentType = ContentType(
          'video',
          'mp2t',
        );
        request.response.add(stripped);
      }
      await request.response.close();
    } catch (e) {
      AppLogger.log(
        '[HLS-PNG] proxy request failed: $e',
        logLevel: LogLevel.error,
      );
      try {
        request.response.statusCode = HttpStatus.badGateway;
        await request.response.close();
      } catch (_) {}
    }
  }
}

/// True when [bytes] look like an HLS playlist (`#EXTM3U`).
bool isHlsPlaylist(List<int> bytes) {
  if (bytes.isEmpty) return false;
  final start = utf8
      .decode(
        bytes.take(16).toList(),
        allowMalformed: true,
      )
      .trimLeft();
  return start.startsWith('#EXTM3U');
}

/// If [data] starts with a PNG signature, return from the first MPEG-TS sync.
Uint8List stripPngPrefix(Uint8List data) {
  if (data.length < 8) return data;
  const pngSig = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
  for (var i = 0; i < pngSig.length; i++) {
    if (data[i] != pngSig[i]) return data;
  }
  for (var i = 8; i < data.length; i++) {
    if (data[i] != 0x47) continue;
    final next = i + 188;
    if (next < data.length && data[next] == 0x47) {
      return Uint8List.sublistView(data, i);
    }
  }
  // Signature only / tiny prefix — drop the 8-byte magic.
  return Uint8List.sublistView(data, 8);
}

/// Rewrites media / key / map URIs in an HLS playlist to go through [proxyBase].
String rewritePlaylist(
  String body,
  String playlistUrl,
  String proxyBase,
) {
  final playlistUri = Uri.parse(playlistUrl);
  final lines = body.split('\n');
  final out = <String>[];
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) {
      out.add(line);
      continue;
    }
    if (trimmed.startsWith('#')) {
      out.add(_rewriteTagUris(line, playlistUri, proxyBase));
      continue;
    }
    final absolute = playlistUri.resolve(trimmed).toString();
    out.add('$proxyBase?u=${Uri.encodeQueryComponent(absolute)}');
  }
  return out.join('\n');
}

String _rewriteTagUris(String line, Uri playlistUri, String proxyBase) {
  return line.replaceAllMapped(RegExp(r'URI="([^"]+)"'), (match) {
    final absolute = playlistUri.resolve(match.group(1)!).toString();
    return 'URI="$proxyBase?u=${Uri.encodeQueryComponent(absolute)}"';
  });
}
