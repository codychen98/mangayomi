import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:mangayomi/services/http/m_client.dart';

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
  })  : _baseUrl = _normalizeBaseUrl(url),
        _username = username.trim(),
        _password = password,
        _folder = folder.trim(),
        _http = httpClient ??
            MClient.init(reqcopyWith: {'useDartHttpClient': true});

  final String _baseUrl;
  final String _username;
  final String _password;
  final String _folder;
  final http.Client _http;

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

  /// Returns an error message when settings are invalid; `null` when valid.
  String? validateSettings() {
    if (_baseUrl.isEmpty || !_baseUrl.startsWith('http')) {
      return 'Invalid WebDAV URL';
    }
    if (_username.isEmpty || _password.isEmpty) {
      return 'Username or password cannot be empty';
    }
    return null;
  }

  String buildFileUrl([String fileName = webDavSyncFileName]) {
    final cleanFolder = _folder.replaceAll(RegExp(r'^/+|/+$'), '');
    if (cleanFolder.isEmpty) {
      return '$_baseUrl/$fileName';
    }
    return '$_baseUrl/$cleanFolder/$fileName';
  }

  /// Creates nested folder segments with `MKCOL` when missing.
  Future<void> ensureFolderExists() async {
    final validationError = validateSettings();
    if (validationError != null) {
      throw WebDavException(validationError);
    }

    final folderParts =
        _folder.split('/').map((part) => part.trim()).where((part) => part.isNotEmpty);
    if (folderParts.isEmpty) {
      return;
    }

    var currentPath = _baseUrl;
    for (final part in folderParts) {
      currentPath = '$currentPath/$part';
      final created = await _createSingleFolder(currentPath);
      if (!created) {
        throw WebDavException('Failed to create folder: $currentPath');
      }
    }
  }

  Future<bool> _createSingleFolder(String folderUrl) async {
    final request = http.Request('MKCOL', Uri.parse(folderUrl))
      ..headers['Authorization'] = _authorizationHeader
      ..headers['Content-Length'] = '0';

    final response = await _http.send(request);
    await response.stream.drain<void>();

    return response.statusCode >= 200 && response.statusCode < 300 ||
        response.statusCode == 405 ||
        response.statusCode == 409;
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
    final normalizedEtag = normalizeEtag(ifNoneMatch);
    if (normalizedEtag != null && normalizedEtag.isNotEmpty) {
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
          etag: normalizedEtag,
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
    final normalizedEtag = normalizeEtag(ifMatch);
    if (normalizedEtag != null && normalizedEtag.isNotEmpty) {
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
    _http.close();
  }
}
