import 'package:flutter_test/flutter_test.dart';
import 'package:mangayomi/eval/model/source_preference.dart';
import 'package:mangayomi/models/feed_saved_search.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/settings.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/services/sync/device_local_settings.dart';
import 'package:mangayomi/services/sync/library_category_sort_sync.dart';
import 'package:mangayomi/services/sync/sync_merger.dart';
import 'package:mangayomi/services/sync/sync_snapshot.dart';
import 'package:mangayomi/services/sync/sync_tombstone.dart';

void main() {
  group('device local settings', () {
    test('stripDeviceLocalSettings clears download and backup paths', () {
      final settings = Settings(
        id: 227,
        downloadLocation: r'W:\Backup\Mangayomi Download',
        autoBackupLocation: r'C:\userdata\backup',
      );

      final stripped = stripDeviceLocalSettings(settings);

      expect(stripped.downloadLocation, '');
      expect(stripped.autoBackupLocation, '');
    });

    test('preserveDeviceLocalSettings keeps local paths after merge', () {
      final local = Settings(
        id: 227,
        downloadLocation: r'W:\Backup\Mangayomi Download',
        autoBackupLocation: r'C:\userdata\backup',
        themeIsDark: true,
      );
      final remote = Settings(
        id: 227,
        downloadLocation: '/storage/emulated/0/Download',
        autoBackupLocation: '/data/backup',
        themeIsDark: false,
      );

      final merged = preserveDeviceLocalSettings(remote, local);

      expect(merged.downloadLocation, local.downloadLocation);
      expect(merged.autoBackupLocation, local.autoBackupLocation);
      expect(merged.themeIsDark, remote.themeIsDark);
    });
  });

  group('mergeSyncSnapshots extension settings', () {
    test('merges extension preferences from both devices by sourceId and key',
        () {
      final local = SyncSnapshot(
        extensionsPreferences: [
          SourcePreference(
            sourceId: 1,
            key: 'lang',
            listPreference: ListPreference(value: 'en'),
          ),
        ],
        extensionsPreferenceStringValues: [
          SourcePreferenceStringValue(
            sourceId: 1,
            key: 'baseUrl',
            value: 'https://local.example',
          ),
        ],
      );
      final remote = SyncSnapshot(
        extensionsPreferences: [
          SourcePreference(
            sourceId: 1,
            key: 'lang',
            listPreference: ListPreference(value: 'fr'),
          ),
          SourcePreference(
            sourceId: 2,
            key: 'quality',
            listPreference: ListPreference(value: 'hd'),
          ),
        ],
        extensionsPreferenceStringValues: [
          SourcePreferenceStringValue(
            sourceId: 2,
            key: 'token',
            value: 'remote-token',
          ),
        ],
      );

      final merged = mergeSyncSnapshots(local, remote);

      expect(merged.extensionsPreferences, hasLength(2));
      expect(
        merged.extensionsPreferences
            .firstWhere((e) => e.sourceId == 1)
            .listPreference
            ?.value,
        'fr',
      );
      expect(
        merged.extensionsPreferenceStringValues
            .map((e) => '${e.sourceId}|${e.key}|${e.value}')
            .toSet(),
        {
          '1|baseUrl|https://local.example',
          '2|token|remote-token',
        },
      );
    });
  });

  group('Manga.fromJson', () {
    test('defaults favorite to false when missing', () {
      final manga = Manga.fromJson({
        'author': 'A',
        'artist': 'A',
        'genre': ['Action'],
        'imageUrl': 'https://example.com/cover.jpg',
        'lang': 'en',
        'link': 'https://example.com/manga/1',
        'name': 'Test',
        'status': Status.ongoing.index,
        'description': 'desc',
        'source': 'src',
        'sourceId': 1,
      });

      expect(manga.favorite, isFalse);
    });
  });

  group('mergeSyncSnapshots extensions and feeds', () {
    test('merges installed extensions with full binary by source id', () {
      final local = SyncSnapshot(
        extensions: [
          Source(
            id: 42,
            name: 'MangaDex',
            lang: 'en',
            itemType: ItemType.manga,
            isAdded: true,
            sourceCode: 'local-binary',
            updatedAt: 100,
          ),
        ],
      );
      final remote = SyncSnapshot(
        extensions: [
          Source(
            id: 42,
            name: 'MangaDex',
            lang: 'en',
            itemType: ItemType.manga,
            isAdded: true,
            sourceCode: 'remote-binary',
            updatedAt: 200,
          ),
        ],
      );

      final merged = mergeSyncSnapshots(local, remote);

      expect(merged.extensions, hasLength(1));
      expect(merged.extensions.first.sourceCode, 'remote-binary');
    });

    test('tombstone removes extension from merged snapshot', () {
      final local = SyncSnapshot(
        extensions: [
          Source(
            id: 42,
            name: 'MangaDex',
            lang: 'en',
            itemType: ItemType.manga,
            isAdded: true,
            sourceCode: 'binary',
            updatedAt: 100,
          ),
        ],
      );
      final remote = SyncSnapshot(
        tombstones: const [
          SyncTombstone(
            entity: SyncTombstoneEntity.extension,
            key: '42',
            deletedAt: 500,
          ),
        ],
      );

      final merged = mergeSyncSnapshots(local, remote);

      expect(merged.extensions, isEmpty);
      expect(merged.tombstones, hasLength(1));
    });

    test('merges feed order using feedOrder field', () {
      final local = SyncSnapshot(
        feedSavedSearches: [
          FeedSavedSearch(
            sourceId: 1,
            itemType: ItemType.manga,
            global: true,
            feedOrder: 0,
            updatedAt: 100,
          ),
        ],
      );
      final remote = SyncSnapshot(
        feedSavedSearches: [
          FeedSavedSearch(
            sourceId: 1,
            itemType: ItemType.manga,
            global: true,
            feedOrder: 2,
            updatedAt: 300,
          ),
        ],
      );

      final merged = mergeSyncSnapshots(local, remote);

      expect(merged.feedSavedSearches.single.feedOrder, 2);
    });

    test('merges library category sort by stable category key', () {
      final local = SyncSnapshot(
        libraryCategorySorts: const [
          LibraryCategorySortEntry(
            categoryKey: '0|reading',
            index: 1,
            reverse: false,
            updatedAt: 100,
          ),
        ],
      );
      final remote = SyncSnapshot(
        libraryCategorySorts: const [
          LibraryCategorySortEntry(
            categoryKey: '0|reading',
            index: 3,
            reverse: true,
            updatedAt: 250,
          ),
        ],
      );

      final merged = mergeSyncSnapshots(local, remote);

      expect(merged.libraryCategorySorts.single.index, 3);
      expect(merged.libraryCategorySorts.single.reverse, isTrue);
    });
  });
}
