import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:mangayomi/services/http/m_client.dart';
import 'package:mangayomi/services/http/rhttp/src/model/settings.dart';
import 'package:mangayomi/utils/extensions/string_extensions.dart';
import 'package:mangayomi/utils/log/logger.dart';

/// Loopback proxy that rewrites HLS playlists and strips a leading image
/// disguise (PNG/JPEG/GIF/WebP) from media segments so desktop libmpv/ffmpeg
/// can demux them.
class HlsPngStripProxy {
  HttpServer? _server;
  Map<String, String> _headers = const {};
  StreamSubscription<HttpRequest>? _subscription;
  final http.Client _client;
  String? _loggedStripKind;

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
    _loggedStripKind = null;
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
        final kind = hlsImageDisguiseKind(bytes);
        final stripped = stripImagePrefix(bytes);
        if (kind != null && _loggedStripKind == null) {
          _loggedStripKind = kind;
          AppLogger.log(
            '[HLS-PNG] stripped $kind prefix '
            'in=${bytes.length} out=${stripped.length}',
          );
        }
        request.response.headers.contentType = stripped.isNotEmpty &&
                stripped[0] == 0x47
            ? ContentType('video', 'mp2t')
            : ContentType('application', 'octet-stream');
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

/// Image disguise on [data], or null when the payload is not PNG/JPEG/GIF/WebP.
String? hlsImageDisguiseKind(Uint8List data) {
  if (_startsWith(data, const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) {
    return 'png';
  }
  if (data.length >= 3 &&
      data[0] == 0xFF &&
      data[1] == 0xD8 &&
      data[2] == 0xFF) {
    return 'jpeg';
  }
  if (_startsWith(data, const [0x47, 0x49, 0x46, 0x38])) {
    return 'gif';
  }
  if (data.length >= 12 &&
      _startsWith(data, const [0x52, 0x49, 0x46, 0x46]) &&
      data[8] == 0x57 &&
      data[9] == 0x45 &&
      data[10] == 0x42 &&
      data[11] == 0x50) {
    return 'webp';
  }
  return null;
}

/// If [data] starts with an image disguise, return from the first MPEG-TS sync.
Uint8List stripImagePrefix(Uint8List data) {
  final kind = hlsImageDisguiseKind(data);
  if (kind == null) return data;
  final searchFrom = switch (kind) {
    'png' => 8,
    'jpeg' => 3,
    'gif' => 6,
    'webp' => 12,
    _ => 0,
  };
  final tsOffset = _mpegTsSyncOffset(data, searchFrom);
  if (tsOffset != null) {
    return Uint8List.sublistView(data, tsOffset);
  }
  if (kind == 'jpeg') {
    final afterEoi = _jpegPayloadOffset(data);
    if (afterEoi != null) {
      return Uint8List.sublistView(data, afterEoi);
    }
  }
  if (kind == 'png' && data.length > 8) {
    return Uint8List.sublistView(data, 8);
  }
  return data;
}

/// Legacy name used by existing tests.
Uint8List stripPngPrefix(Uint8List data) => stripImagePrefix(data);

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

bool _startsWith(Uint8List data, List<int> prefix) {
  if (data.length < prefix.length) return false;
  for (var i = 0; i < prefix.length; i++) {
    if (data[i] != prefix[i]) return false;
  }
  return true;
}

int? _mpegTsSyncOffset(Uint8List data, int start) {
  final last = data.length - 188;
  for (var i = start; i < last; i++) {
    if (data[i] != 0x47) continue;
    if (data[i + 188] == 0x47) {
      return i;
    }
  }
  return null;
}

int? _jpegPayloadOffset(Uint8List data) {
  for (var i = 2; i < data.length - 1; i++) {
    if (data[i] == 0xFF && data[i + 1] == 0xD9) {
      final end = i + 2;
      if (end < data.length) return end;
    }
  }
  return null;
}
