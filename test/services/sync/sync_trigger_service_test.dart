import 'package:flutter_test/flutter_test.dart';
import 'package:mangayomi/models/sync_preference.dart';
import 'package:mangayomi/services/sync/sync_service_type.dart';
import 'package:mangayomi/services/sync/sync_trigger_service.dart';

void main() {
  group('isSyncTriggerEnabled', () {
    SyncPreference configuredPrefs() => SyncPreference(
      syncOn: true,
      syncServiceType: SyncServiceType.webDav,
      webDavUrl: 'https://example.com/dav',
      webDavUsername: 'user',
      webDavPassword: 'secret',
      syncOnChapterSeen: true,
      syncOnChapterOpen: true,
      syncOnAppStart: true,
      syncOnAppResume: true,
    );

    test('returns false when sync is disabled', () {
      final prefs = configuredPrefs()..syncOn = false;

      expect(
        isSyncTriggerEnabled(prefs, SyncTriggerEvent.chapterSeen),
        isFalse,
      );
    });

    test('returns false when backend is not configured', () {
      final prefs = SyncPreference(
        syncOn: true,
        syncOnChapterSeen: true,
      );

      expect(
        isSyncTriggerEnabled(prefs, SyncTriggerEvent.chapterSeen),
        isFalse,
      );
    });

    test('returns true only for the matching enabled trigger', () {
      final prefs = configuredPrefs()
        ..syncOnChapterSeen = true
        ..syncOnChapterOpen = false
        ..syncOnAppStart = false
        ..syncOnAppResume = false;

      expect(
        isSyncTriggerEnabled(prefs, SyncTriggerEvent.chapterSeen),
        isTrue,
      );
      expect(
        isSyncTriggerEnabled(prefs, SyncTriggerEvent.chapterOpen),
        isFalse,
      );
    });
  });

  group('isSyncTriggerDebounced', () {
    test('returns false when no prior trigger exists', () {
      expect(
        isSyncTriggerDebounced(DateTime(2026, 6, 12, 12, 0, 30), lastAt: null),
        isFalse,
      );
    });

    test('returns true within the debounce window', () {
      final last = DateTime(2026, 6, 12, 12, 0, 0);
      final now = DateTime(2026, 6, 12, 12, 0, 15);

      expect(isSyncTriggerDebounced(now, lastAt: last), isTrue);
    });

    test('returns false after the debounce window', () {
      final last = DateTime(2026, 6, 12, 12, 0, 0);
      final now = DateTime(2026, 6, 12, 12, 0, 31);

      expect(isSyncTriggerDebounced(now, lastAt: last), isFalse);
    });
  });
}
