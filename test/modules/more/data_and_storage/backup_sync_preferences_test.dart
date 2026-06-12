import 'package:flutter_test/flutter_test.dart';
import 'package:mangayomi/models/sync_preference.dart';
import 'package:mangayomi/modules/more/data_and_storage/providers/backup_sync_preferences.dart';
import 'package:mangayomi/services/sync/sync_service_type.dart';

void main() {
  group('exportSyncPreferencesForBackup', () {
    final pref = SyncPreference(
      syncId: 1,
      syncOn: true,
      syncServiceType: SyncServiceType.webDav,
      webDavUrl: 'https://cloud.example.com/dav',
      webDavUsername: 'user',
      webDavPassword: 'secret',
      authToken: 'server-token',
    );

    test('includes sensitive fields when includeSensitive is true', () {
      final exported = exportSyncPreferencesForBackup(
        [pref],
        includeSensitive: true,
      );

      expect(exported, hasLength(1));
      expect(exported.first['webDavPassword'], 'secret');
      expect(exported.first['authToken'], 'server-token');
    });

    test('nulls sensitive fields when includeSensitive is false', () {
      final exported = exportSyncPreferencesForBackup(
        [pref],
        includeSensitive: false,
      );

      expect(exported.first['webDavPassword'], isNull);
      expect(exported.first['authToken'], isNull);
      expect(exported.first['webDavUrl'], 'https://cloud.example.com/dav');
      expect(exported.first['syncOn'], isTrue);
    });
  });

  group('mergeSyncPreferenceFromBackup', () {
    test('keeps local password when backup omitted it', () {
      final incoming = SyncPreference.fromJson({
        'syncId': 1,
        'webDavUrl': 'https://cloud.example.com/dav',
        'webDavUsername': 'user',
        'webDavPassword': null,
        'authToken': null,
        'syncServiceType': SyncServiceType.webDav.index,
      });
      final existing = SyncPreference(
        syncId: 1,
        webDavPassword: 'stored-secret',
        authToken: 'stored-token',
      );

      final merged = mergeSyncPreferenceFromBackup(incoming, existing);

      expect(merged.webDavPassword, 'stored-secret');
      expect(merged.authToken, 'stored-token');
      expect(merged.webDavUrl, 'https://cloud.example.com/dav');
    });

    test('uses backup password when present', () {
      final incoming = SyncPreference(
        syncId: 1,
        webDavPassword: 'new-secret',
        authToken: 'new-token',
      );
      final existing = SyncPreference(
        syncId: 1,
        webDavPassword: 'old-secret',
        authToken: 'old-token',
      );

      final merged = mergeSyncPreferenceFromBackup(incoming, existing);

      expect(merged.webDavPassword, 'new-secret');
      expect(merged.authToken, 'new-token');
    });
  });
}
