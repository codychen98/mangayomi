import 'package:flutter_test/flutter_test.dart';
import 'package:mangayomi/models/sync_preference.dart';
import 'package:mangayomi/services/sync/sync_backend.dart';
import 'package:mangayomi/services/sync/sync_service_type.dart';

void main() {
  group('isSyncConfigured', () {
    test('returns false when mangayomi-server has no auth token', () {
      final prefs = SyncPreference(
        syncServiceType: SyncServiceType.mangayomiServer,
      );

      expect(isSyncConfigured(prefs), isFalse);
    });

    test('returns true when mangayomi-server has auth token', () {
      final prefs = SyncPreference(
        syncServiceType: SyncServiceType.mangayomiServer,
        authToken: 'token',
      );

      expect(isSyncConfigured(prefs), isTrue);
    });

    test('returns false when WebDAV credentials are incomplete', () {
      final prefs = SyncPreference(
        syncServiceType: SyncServiceType.webDav,
        webDavUrl: 'https://example.com/dav',
        webDavUsername: 'user',
      );

      expect(isSyncConfigured(prefs), isFalse);
    });

    test('returns true when WebDAV credentials are complete', () {
      final prefs = SyncPreference(
        syncServiceType: SyncServiceType.webDav,
        webDavUrl: 'https://example.com/dav',
        webDavUsername: 'user',
        webDavPassword: 'secret',
      );

      expect(isSyncConfigured(prefs), isTrue);
    });
  });
}
