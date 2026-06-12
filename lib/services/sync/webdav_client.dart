import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// Remote sync file name under the configured WebDAV folder.
const String webDavSyncFileName = 'mangayomi-sync.json';

/// Thrown when a WebDAV request fails with a non-recoverable HTTP status.
class WebDavException implements Exception {
  WebDavException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Result of downloading the remote sync file.
class WebDavPullResult {
  const WebDavPullResult({
    this.bytes,
    this.etag,
    this.notModified = false,
    this.notFound = false,
  });

  final Uint8List? bytes;
  final String? etag;
  final bool notModified;
  final bool notFound;
}

/// Result of uploading the remote sync file.
class WebDavPushResult {
  const WebDavPushResult({
    this.success = false,
    this.conflict = false,
    this.newEtag,
  });

  final bool success;
  final bool conflict;
  final String? newEtag;
}

/// Low-level WebDAV HTTP client for sync file operations.
class WebDavClient {
  WebDavClient({
    required String url,
    required String username,
    required String password,
    String folder = 'mangayomi',
    http.Client? httpClient,
  })  : _baseUri = Uri.parse(_normalizeBaseUrl(url)),
        _username = username.trim(),
        _password = password,
        _folder = folder.trim(),
        _http = httpClient ?? IOClient(HttpClient()),
        _ownsHttpClient = httpClient == null;

  final Uri _baseUri;
  final String _username;
  final String _password;
  final String _folder;
  final http.Client _http;
  final bool _ownsHttpClient;

  List<String> get _folderSegments => _folder
      .split('/')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();

  String get _authorizationHeader =>
      'Basic ${base64Encode(utf8.encode('$_username:$_password'))}';

  static String _normalizeBaseUrl(String url) {
    var normalized = url.trim();
    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }

  static String? normalizeEtag(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return raw.replaceAll('"', '').trim();
  }

  /// RFC 7232 requires quoted entity-tags in If-Match / If-None-Match headers.
  static String? formatEtagHeader(String? raw) {
    final normalized = normalizeEtag(raw);
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return '"$normalized"';
  }

  /// Returns an error message when settings are invalid; `null` when valid.
  String? validateSettings() {
    if (!_baseUri.hasScheme ||
        (_baseUri.scheme != 'http' && _baseUri.scheme != 'https') ||
        _baseUri.host.isEmpty) {
      return 'Invalid WebDAV URL';
    }
    if (_username.isEmpty || _password.isEmpty) {
      return 'Username or password cannot be empty';
    }
    return null;
  }

  Uri _uriForPathSegments(List<String> segments) {
    final baseSegments =
        _baseUri.pathSegments.where((segment) => segment.isNotEmpty);
    return _baseUri.replace(pathSegments: [...baseSegments, ...segments]);
  }

  String buildFileUrl([String fileName = webDavSyncFileName]) {
    if (_folderSegments.isEmpty) {
      return _uriForPathSegments([fileName]).toString();
    }
    return _uriForPathSegments([..._folderSegments, fileName]).toString();
  }

  /// Creates nested folder segments with `MKCOL` when missing.
  Future<void> ensureFolderExists() async {
    final validationError = validateSettings();
    if (validationError != null) {
      throw WebDavException(validationError);
    }

    if (_folderSegments.isEmpty) {
      return;
    }

    final accumulated = <String>[];
    for (final part in _folderSegments) {
      accumulated.add(part);
      final folderUri = _uriForPathSegments(accumulated);
      if (await _folderExists(folderUri)) {
        continue;
      }

      final result = await _createSingleFolder(folderUri);
      if (!result.success) {
        if (await _folderExists(folderUri)) {
          continue;
        }
        throw WebDavException(
          'Failed to create folder: $folderUri (${result.statusCode})',
          statusCode: result.statusCode,
        );
      }
    }
  }

  Uri _collectionUri(Uri uri) {
    final path = uri.path.endsWith('/') ? uri.path : '${uri.path}/';
    return uri.replace(path: path);
  }

  /// Some providers (e.g. pCloud) reject MKCOL on paths that already exist.
  Future<bool> _folderExists(Uri folderUri) async {
    final uri = _collectionUri(folderUri);
    final propfind = http.Request('PROPFIND', uri)
      ..headers['Authorization'] = _authorizationHeader
      ..headers['Depth'] = '0'
      ..headers['Content-Length'] = '0';

    final response = await _http.send(propfind);
    await response.stream.drain<void>();

    if (response.statusCode == 207 || response.statusCode == 200) {
      return true;
    }
    if (response.statusCode == 404) {
      return false;
    }

    final head = http.Request('HEAD', uri)
      ..headers['Authorization'] = _authorizationHeader;
    final headResponse = await _http.send(head);
    await headResponse.stream.drain<void>();
    return headResponse.statusCode >= 200 && headResponse.statusCode < 300;
  }

  bool _isMkcolSuccess(int statusCode) {
    return statusCode >= 200 && statusCode < 300 ||
        statusCode == 301 ||
        statusCode == 302 ||
        statusCode == 307 ||
        statusCode == 308 ||
        statusCode == 405 ||
        statusCode == 409;
  }

  Future<({bool success, int statusCode})> _createSingleFolder(
    Uri folderUri,
  ) async {
    final uri = _collectionUri(folderUri);
    final request = http.Request('MKCOL', uri)
      ..headers['Authorization'] = _authorizationHeader
      ..headers['Content-Length'] = '0';

    final response = await _http.send(request);
    await response.stream.drain<void>();

    final statusCode = response.statusCode;
    return (success: _isMkcolSuccess(statusCode), statusCode: statusCode);
  }

  /// Downloads the remote sync file. Supports conditional GET via [ifNoneMatch].
  Future<WebDavPullResult> pull({String? ifNoneMatch}) async {
    final validationError = validateSettings();
    if (validationError != null) {
      throw WebDavException(validationError);
    }

    final headers = <String, String>{
      'Authorization': _authorizationHeader,
    };
    final normalizedEtag = formatEtagHeader(ifNoneMatch);
    if (normalizedEtag != null) {
      headers['If-None-Match'] = normalizedEtag;
    }

    final response = await _http.get(
      Uri.parse(buildFileUrl()),
      headers: headers,
    );

    switch (response.statusCode) {
      case 304:
        return WebDavPullResult(
          notModified: true,
          etag: normalizeEtag(ifNoneMatch),
        );
      case 404:
        return const WebDavPullResult(notFound: true);
      case 200:
      case 201:
        return WebDavPullResult(
          bytes: Uint8List.fromList(response.bodyBytes),
          etag: normalizeEtag(response.headers['etag']),
        );
      default:
        throw WebDavException(
          'Failed to download sync file (${response.statusCode})',
          statusCode: response.statusCode,
        );
    }
  }

  /// Uploads [body] to the remote sync file. Supports optimistic locking via [ifMatch].
  Future<WebDavPushResult> push(
    Uint8List body, {
    String? ifMatch,
  }) async {
    final validationError = validateSettings();
    if (validationError != null) {
      throw WebDavException(validationError);
    }

    final headers = <String, String>{
      'Authorization': _authorizationHeader,
      'Content-Type': 'application/json; charset=utf-8',
    };
    final normalizedEtag = formatEtagHeader(ifMatch);
    if (normalizedEtag != null) {
      headers['If-Match'] = normalizedEtag;
    }

    final response = await _http.put(
      Uri.parse(buildFileUrl()),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 412) {
      return const WebDavPushResult(conflict: true);
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return WebDavPushResult(
        success: true,
        newEtag: normalizeEtag(response.headers['etag']),
      );
    }

    throw WebDavException(
      'Failed to upload sync file (${response.statusCode})',
      statusCode: response.statusCode,
    );
  }

  void close() {
    if (_ownsHttpClient) {
      _http.close();
    }
  }
}
