import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:mangayomi/services/hls/hls_aes.dart';
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
  bool _loggedPlaylist = false;
  bool _loggedSegment = false;
  Uint8List? _aesKey;
  Uint8List? _aesIv;

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
    _loggedPlaylist = false;
    _loggedSegment = false;
    _aesKey = null;
    _aesIv = null;
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
    return proxiedUrl(
      upstreamUrl,
      'http://127.0.0.1:$port',
      name: 'index.m3u8',
    );
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
      var bytes = response.bodyBytes;
      final resource = request.uri.queryParameters['n'] ?? '';
      final wantsPlaylist = resource.toLowerCase().contains('m3u8');
      final playlistOff = hlsPlaylistOffset(bytes);
      if (playlistOff != null) {
        final text = utf8.decode(
          bytes.sublist(playlistOff),
          allowMalformed: true,
        );
        await _loadAesFromPlaylist(text, upstream);
        final rewritten = rewritePlaylist(
          text,
          upstream,
          'http://127.0.0.1:${_server!.port}',
          stripAesKey: _aesKey != null,
        );
        if (!_loggedPlaylist) {
          _loggedPlaylist = true;
          AppLogger.log(
            '[HLS-PNG] playlist in=${bytes.length} off=$playlistOff '
            'aes=${_aesKey != null} ${_playlistSummary(text)}',
          );
        }
        request.response.headers.contentType = ContentType(
          'application',
          'vnd.apple.mpegurl',
          charset: 'utf-8',
        );
        request.response.write(rewritten);
      } else if (wantsPlaylist) {
        // Extension-server / nested proxies may return URL lists or bodies
        // without #EXTM3U. Never treat those playlist fetches as TS segments.
        if (!_loggedPlaylist) {
          _loggedPlaylist = true;
          AppLogger.log(
            '[HLS-PNG] non-EXTM3U playlist passthrough in=${bytes.length} '
            'magic=${_hexPrefix(Uint8List.fromList(bytes))}',
          );
        }
        request.response.headers.contentType = ContentType(
          'application',
          'vnd.apple.mpegurl',
          charset: 'utf-8',
        );
        request.response.add(bytes);
      } else {
        final seq = int.tryParse(request.uri.queryParameters['s'] ?? '');
        if (_aesKey != null &&
            seq != null &&
            resource != 'index.m3u8' &&
            resource != 'key.bin') {
          try {
            bytes = decryptHlsAes128(
              bytes,
              _aesKey!,
              iv: _aesIv,
              sequence: seq,
            );
          } catch (e) {
            AppLogger.log(
              '[HLS-PNG] AES decrypt failed seq=$seq: $e',
              logLevel: LogLevel.error,
            );
          }
        }
        final kind = hlsImageDisguiseKind(bytes);
        final stripped = stripImagePrefix(bytes);
        if (!_loggedSegment) {
          _loggedSegment = true;
          AppLogger.log(
            '[HLS-PNG] segment magic=${_hexPrefix(bytes)} kind=${kind ?? 'none'} '
            'in=${bytes.length} out=${stripped.length}',
          );
        }
        request.response.headers.contentType =
            stripped.isNotEmpty && stripped[0] == 0x47
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

  Future<void> _loadAesFromPlaylist(String body, String playlistUrl) async {
    if (_aesKey != null) return;
    final parsed = parseHlsAes128(body, playlistUrl);
    if (parsed == null) return;
    try {
      final response = await _client.get(
        Uri.parse(parsed.keyUrl),
        headers: _headers,
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        AppLogger.log(
          '[HLS-PNG] AES key fetch status=${response.statusCode} '
          'uri=${parsed.keyUrl.toLogSafeUri()}',
          logLevel: LogLevel.error,
        );
        return;
      }
      _aesKey = Uint8List.fromList(response.bodyBytes);
      _aesIv = parsed.iv;
      AppLogger.log(
        '[HLS-PNG] AES-128 keyBytes=${_aesKey!.length} '
        'iv=${parsed.iv != null} seq=${parsed.mediaSequence}',
      );
    } catch (e) {
      AppLogger.log(
        '[HLS-PNG] AES key fetch failed: $e',
        logLevel: LogLevel.error,
      );
    }
  }
}

String _playlistSummary(String body) {
  var segs = 0;
  String? first;
  var hasKey = false;
  for (final raw in body.split('\n')) {
    final line = raw.trim();
    if (line.contains('#EXT-X-KEY')) hasKey = true;
    if (line.isEmpty || line.startsWith('#')) continue;
    segs++;
    first ??= line.length > 80 ? '${line.substring(0, 80)}...' : line;
  }
  return 'key=$hasKey segs=$segs first=${first ?? 'none'}';
}

String _hexPrefix(Uint8List data) {
  final n = min(data.length, 8);
  final out = StringBuffer();
  for (var i = 0; i < n; i++) {
    out.write(data[i].toRadixString(16).padLeft(2, '0'));
  }
  return out.toString();
}

/// True when [url] is an M-Extension-Server HLS proxy (`/m3u8` or `/segment`).
///
/// Those streams are already proxied (headers / AES) by the extension server;
/// wrapping them in [HlsPngStripProxy] mis-handles non-`#EXTM3U` bodies.
bool isExtensionServerHlsProxyUri(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || uri.host.isEmpty) return false;
  final host = uri.host.toLowerCase();
  if (host != 'localhost' && host != '127.0.0.1') return false;
  final path = uri.path.toLowerCase();
  return path == '/m3u8' ||
      path.endsWith('/m3u8') ||
      path == '/segment' ||
      path.endsWith('/segment');
}

/// Ensures loopback extension HLS URLs use the running proxy [proxyBase] port.
///
/// Leaves URLs that already have an explicit non-default port unchanged.
String resolveExtensionServerStreamUri(String url, String? proxyBase) {
  if (!isExtensionServerHlsProxyUri(url)) return url;
  final uri = Uri.parse(url);
  final hasExplicitPort = uri.hasPort && uri.port != 80 && uri.port != 443;
  if (hasExplicitPort) return url;
  if (proxyBase == null || proxyBase.trim().isEmpty) return url;
  final base = Uri.tryParse(proxyBase.trim());
  if (base == null || !base.hasPort) return url;
  return uri
      .replace(
        scheme: base.scheme.isNotEmpty ? base.scheme : uri.scheme,
        host: base.host.isNotEmpty ? base.host : uri.host,
        port: base.port,
      )
      .toString();
}

/// Offset of `#EXTM3U` in the first 8KiB, or null.
int? hlsPlaylistOffset(List<int> bytes) {
  if (bytes.isEmpty) return null;
  const needle = [0x23, 0x45, 0x58, 0x54, 0x4D, 0x33, 0x55]; // #EXTM3U
  final last = min(bytes.length, 8192) - needle.length;
  for (var i = 0; i <= last; i++) {
    var match = true;
    for (var j = 0; j < needle.length; j++) {
      if (bytes[i + j] != needle[j]) {
        match = false;
        break;
      }
    }
    if (match) return i;
  }
  return null;
}

/// True when [bytes] look like an HLS playlist (`#EXTM3U`).
bool isHlsPlaylist(List<int> bytes) => hlsPlaylistOffset(bytes) != null;

/// Image disguise on [data] at [start], or null.
String? hlsImageDisguiseKind(Uint8List data, [int start = 0]) {
  bool at(List<int> prefix) {
    if (data.length < start + prefix.length) return false;
    for (var i = 0; i < prefix.length; i++) {
      if (data[start + i] != prefix[i]) return false;
    }
    return true;
  }

  if (at(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) {
    return 'png';
  }
  if (data.length >= start + 2 &&
      data[start] == 0xFF &&
      data[start + 1] == 0xD8) {
    return 'jpeg';
  }
  if (at(const [0x47, 0x49, 0x46, 0x38])) {
    return 'gif';
  }
  if (data.length >= start + 12 &&
      at(const [0x52, 0x49, 0x46, 0x46]) &&
      data[start + 8] == 0x57 &&
      data[start + 9] == 0x45 &&
      data[start + 10] == 0x42 &&
      data[start + 11] == 0x50) {
    return 'webp';
  }
  return null;
}

/// If [data] has an image disguise, return from the first MPEG-TS sync.
Uint8List stripImagePrefix(Uint8List data) {
  var kind = hlsImageDisguiseKind(data);
  var searchFrom = 0;
  if (kind == null && (data.isEmpty || data[0] != 0x47)) {
    final magicAt = _imageMagicOffset(data);
    if (magicAt != null) {
      kind = hlsImageDisguiseKind(data, magicAt);
      searchFrom = magicAt;
    }
  }
  if (kind != null) {
    searchFrom += switch (kind) {
      'png' => 8,
      'jpeg' => 2,
      'gif' => 6,
      'webp' => 12,
      _ => 0,
    };
    final tsOffset = _mpegTsSyncOffset(data, searchFrom);
    if (tsOffset != null) {
      return Uint8List.sublistView(data, tsOffset);
    }
    if (kind == 'jpeg') {
      final afterEoi = _jpegPayloadOffset(data, searchFrom);
      if (afterEoi != null) {
        return Uint8List.sublistView(data, afterEoi);
      }
    }
    if (kind == 'png' && data.length > searchFrom) {
      return Uint8List.sublistView(data, searchFrom);
    }
    return data;
  }
  final tsOffset = _mpegTsSyncOffset(data, 0);
  if (tsOffset != null && tsOffset > 0) {
    return Uint8List.sublistView(data, tsOffset);
  }
  return data;
}

/// Legacy name used by existing tests.
Uint8List stripPngPrefix(Uint8List data) => stripImagePrefix(data);

/// Loopback URL that ends with a video/playlist extension ffmpeg will accept.
String proxiedUrl(
  String absolute,
  String proxyBase, {
  required String name,
  int? sequence,
}) {
  final encoded = Uri.encodeQueryComponent(absolute);
  final seq = sequence == null ? '' : '&s=$sequence';
  // `n=` must be last so ffmpeg av_match_ext sees `.ts` / `.m3u8`, not `.jpg`.
  return '$proxyBase/$name?u=$encoded$seq&n=$name';
}

String _resourceName(String absolute, {required bool isTagUri, String? tagLine}) {
  final lower = absolute.toLowerCase();
  if (lower.contains('.m3u8')) return 'index.m3u8';
  if (isTagUri && (tagLine ?? '').contains('#EXT-X-KEY')) return 'key.bin';
  return 'seg.ts';
}

/// Rewrites media / key / map URIs in an HLS playlist to go through [proxyBase].
String rewritePlaylist(
  String body,
  String playlistUrl,
  String proxyBase, {
  bool stripAesKey = false,
}) {
  final playlistUri = Uri.parse(playlistUrl);
  var sequence = parseHlsAes128(body, playlistUrl)?.mediaSequence ?? 0;
  final lines = body.split('\n');
  final out = <String>[];
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) {
      out.add(line);
      continue;
    }
    if (trimmed.startsWith('#')) {
      if (stripAesKey && trimmed.contains('#EXT-X-KEY')) {
        continue;
      }
      if (trimmed.startsWith('#EXT-X-MEDIA-SEQUENCE')) {
        final value = int.tryParse(trimmed.substring(trimmed.indexOf(':') + 1).trim());
        if (value != null) sequence = value;
      }
      out.add(_rewriteTagUris(line, playlistUri, proxyBase, stripAesKey));
      continue;
    }
    final absolute = playlistUri.resolve(trimmed).toString();
    out.add(
      proxiedUrl(
        absolute,
        proxyBase,
        name: _resourceName(absolute, isTagUri: false),
        sequence: sequence,
      ),
    );
    sequence++;
  }
  return out.join('\n');
}

String _rewriteTagUris(
  String line,
  Uri playlistUri,
  String proxyBase,
  bool stripAesKey,
) {
  if (stripAesKey && line.contains('#EXT-X-KEY')) return line;
  return line.replaceAllMapped(RegExp(r'URI="([^"]+)"'), (match) {
    final absolute = playlistUri.resolve(match.group(1)!).toString();
    return 'URI="${proxiedUrl(
      absolute,
      proxyBase,
      name: _resourceName(absolute, isTagUri: true, tagLine: line),
    )}"';
  });
}

int? _imageMagicOffset(Uint8List data) {
  final last = min(data.length, 1024);
  for (var i = 1; i < last; i++) {
    if (hlsImageDisguiseKind(data, i) != null) return i;
  }
  return null;
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

int? _jpegPayloadOffset(Uint8List data, [int start = 2]) {
  for (var i = start; i < data.length - 1; i++) {
    if (data[i] == 0xFF && data[i + 1] == 0xD9) {
      final end = i + 2;
      if (end < data.length) return end;
    }
  }
  return null;
}
