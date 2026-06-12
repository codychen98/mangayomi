import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mangayomi/services/sync/webdav_client.dart';

WebDavClient _clientFor(MockClient httpClient, {String folder = 'mangayomi'}) {
  return WebDavClient(
    url: 'https://cloud.example.com/dav',
    username: 'user',
    password: 'pass',
    folder: folder,
    httpClient: httpClient,
  );
}

void main() {
  group('WebDavClient.validateSettings', () {
    test('returns null for valid settings', () {
      final client = WebDavClient(
        url: 'https://cloud.example.com/dav',
        username: 'user',
        password: 'pass',
      );

      expect(client.validateSettings(), isNull);
    });

    test('rejects invalid URL and empty credentials', () {
      final invalidUrl = WebDavClient(
        url: 'ftp://bad',
        username: 'user',
        password: 'pass',
      );
      final missingUser = WebDavClient(
        url: 'https://cloud.example.com',
        username: '   ',
        password: 'pass',
      );

      expect(invalidUrl.validateSettings(), isNotNull);
      expect(missingUser.validateSettings(), isNotNull);
    });
  });

  group('WebDavClient.buildFileUrl', () {
    test('builds nested folder path and trims slashes', () {
      final client = WebDavClient(
        url: 'https://cloud.example.com/dav/',
        username: 'user',
        password: 'pass',
        folder: '/mangayomi/',
      );

      expect(
        client.buildFileUrl(),
        'https://cloud.example.com/dav/mangayomi/mangayomi-sync.json',
      );
    });

    test('encodes folder segments with special characters', () {
      final client = WebDavClient(
        url: 'https://webdav.pcloud.com',
        username: 'user',
        password: 'pass',
        folder: '(Reinstall)/BACKUP/Mangayomi',
      );

      expect(
        client.buildFileUrl(),
        'https://webdav.pcloud.com/(Reinstall)/BACKUP/Mangayomi/mangayomi-sync.json',
      );
    });
  });

  group('WebDavClient.ensureFolderExists', () {
    test('MKCOL treats 405 and 409 as success', () async {
      final requests = <String>[];
      final mock = MockClient((request) async {
        requests.add('${request.method} ${request.url.path}');
        if (request.method == 'PROPFIND') {
          return http.Response('', 404);
        }
        if (request.method == 'MKCOL') {
          final path = request.url.path;
          if (path.endsWith('/mangayomi')) {
            return http.Response('', 201);
          }
          if (path.endsWith('/nested')) {
            return http.Response('', 405);
          }
        }
        return http.Response('', 500);
      });

      final client = _clientFor(mock, folder: 'mangayomi/nested');
      await client.ensureFolderExists();

      expect(requests, [
        'PROPFIND /dav/mangayomi/',
        'MKCOL /dav/mangayomi/',
        'PROPFIND /dav/mangayomi/nested/',
        'MKCOL /dav/mangayomi/nested/',
      ]);
    });

    test('skips MKCOL when folder already exists', () async {
      final requests = <String>[];
      final mock = MockClient((request) async {
        requests.add('${request.method} ${request.url.path}');
        if (request.method == 'PROPFIND') {
          return http.Response('', 207);
        }
        return http.Response('', 500);
      });

      final client = WebDavClient(
        url: 'https://webdav.pcloud.com',
        username: 'user',
        password: 'pass',
        folder: '(Reinstall)/BACKUP/Mangayomi',
        httpClient: mock,
      );
      await client.ensureFolderExists();

      expect(requests, [
        'PROPFIND /(Reinstall)/',
        'PROPFIND /(Reinstall)/BACKUP/',
        'PROPFIND /(Reinstall)/BACKUP/Mangayomi/',
      ]);
      expect(requests.where((r) => r.startsWith('MKCOL')), isEmpty);
    });

    test('treats MKCOL failure as success when folder exists afterward', () async {
      var mangayomiChecks = 0;
      final mock = MockClient((request) async {
        if (request.method == 'PROPFIND') {
          final path = request.url.path;
          if (path.endsWith('/mangayomi/') && mangayomiChecks == 0) {
            mangayomiChecks++;
            return http.Response('', 404);
          }
          if (path.endsWith('/mangayomi/')) {
            return http.Response('', 207);
          }
          return http.Response('', 404);
        }
        if (request.method == 'MKCOL') {
          return http.Response('', 403);
        }
        return http.Response('', 500);
      });

      final client = _clientFor(mock, folder: 'mangayomi');
      await client.ensureFolderExists();
    });
  });

  group('WebDavClient.pull', () {
    test('returns notFound on 404', () async {
      final mock = MockClient((request) async => http.Response('', 404));
      final client = _clientFor(mock);

      final result = await client.pull();

      expect(result.notFound, isTrue);
      expect(result.bytes, isNull);
    });

    test('returns notModified on 304 and preserves etag', () async {
      final mock = MockClient((request) async {
        expect(request.headers['if-none-match'], 'etag-1');
        return http.Response('', 304);
      });
      final client = _clientFor(mock);

      final result = await client.pull(ifNoneMatch: '"etag-1"');

      expect(result.notModified, isTrue);
      expect(result.etag, 'etag-1');
      expect(result.bytes, isNull);
    });

    test('returns bytes and etag on 200', () async {
      final body = utf8.encode('{"version":"2"}');
      final mock = MockClient(
        (request) async => http.Response.bytes(
          body,
          200,
          headers: {'etag': '"remote-etag"'},
        ),
      );
      final client = _clientFor(mock);

      final result = await client.pull();

      expect(result.bytes, Uint8List.fromList(body));
      expect(result.etag, 'remote-etag');
      expect(result.notModified, isFalse);
      expect(result.notFound, isFalse);
    });
  });

  group('WebDavClient.push', () {
    test('returns conflict on 412', () async {
      final mock = MockClient((request) async {
        expect(request.headers['if-match'], 'stale-etag');
        return http.Response('', 412);
      });
      final client = _clientFor(mock);

      final result = await client.push(
        Uint8List.fromList(utf8.encode('{}')),
        ifMatch: 'stale-etag',
      );

      expect(result.conflict, isTrue);
      expect(result.success, isFalse);
    });

    test('returns success and new etag on 204', () async {
      final mock = MockClient((request) async {
        expect(request.headers['authorization'], startsWith('Basic '));
        expect(request.headers['content-type'], contains('application/json'));
        return http.Response('', 204, headers: {'etag': '"new-etag"'});
      });
      final client = _clientFor(mock);

      final result = await client.push(
        Uint8List.fromList(utf8.encode('{"version":"2"}')),
      );

      expect(result.success, isTrue);
      expect(result.conflict, isFalse);
      expect(result.newEtag, 'new-etag');
    });
  });

  group('WebDavClient.normalizeEtag', () {
    test('strips quotes and whitespace', () {
      expect(WebDavClient.normalizeEtag(' "abc" '), 'abc');
      expect(WebDavClient.normalizeEtag(''), isNull);
      expect(WebDavClient.normalizeEtag(null), isNull);
    });
  });
}
