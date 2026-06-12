import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mangayomi/l10n/generated/app_localizations_en.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/sync_preference.dart';
import 'package:mangayomi/services/sync/sync_snapshot.dart';
import 'package:mangayomi/services/sync/webdav_client.dart';
import 'package:mangayomi/services/sync/webdav_sync_backend.dart';

void main() {
  group('encodeSyncSnapshot / decodeSyncSnapshot', () {
    test('round-trips snapshot JSON', () {
      final snapshot = SyncSnapshot(
        manga: [
          Manga(
            source: 'src',
            author: 'A',
            artist: 'A',
            genre: const ['Action'],
            imageUrl: 'https://example.com/1.jpg',
            lang: 'en',
            link: 'https://example.com/1',
            name: 'Test',
            status: Status.ongoing,
            description: 'desc',
            sourceId: 1,
            itemType: ItemType.anime,
          ),
        ],
      );

      final restored = decodeSyncSnapshot(encodeSyncSnapshot(snapshot));

      expect(restored.manga, hasLength(1));
      expect(restored.manga.first.itemType, ItemType.anime);
      expect(restored.manga.first.name, 'Test');
    });
  });

  group('resolveSnapshotForBidirectionalSync', () {
    test('returns local snapshot when remote is missing', () {
      final local = SyncSnapshot(
        manga: [
          Manga(
            source: 'src',
            author: 'A',
            artist: 'A',
            genre: const ['Action'],
            imageUrl: 'https://example.com/local.jpg',
            lang: 'en',
            link: 'https://example.com/local',
            name: 'Local',
            status: Status.ongoing,
            description: 'desc',
            sourceId: 1,
          ),
        ],
      );

      final merged = resolveSnapshotForBidirectionalSync(
        local: local,
        pullResult: const WebDavPullResult(notFound: true),
      );

      expect(merged.manga, hasLength(1));
      expect(merged.manga.first.name, 'Local');
    });

    test('returns local snapshot when remote is not modified', () {
      final local = SyncSnapshot(
        manga: [
          Manga(
            source: 'src',
            author: 'A',
            artist: 'A',
            genre: const ['Action'],
            imageUrl: 'https://example.com/local.jpg',
            lang: 'en',
            link: 'https://example.com/local',
            name: 'Local',
            status: Status.ongoing,
            description: 'desc',
            sourceId: 1,
            updatedAt: 2,
          ),
        ],
      );

      final merged = resolveSnapshotForBidirectionalSync(
        local: local,
        pullResult: const WebDavPullResult(notModified: true, etag: 'abc'),
      );

      expect(merged.manga.first.name, 'Local');
    });

    test('merges local and remote when remote body is present', () {
      final local = SyncSnapshot(
        manga: [
          Manga(
            source: 'src',
            author: 'A',
            artist: 'A',
            genre: const ['Action'],
            imageUrl: 'https://example.com/local.jpg',
            lang: 'en',
            link: 'https://example.com/local',
            name: 'Local',
            status: Status.ongoing,
            description: 'desc',
            sourceId: 1,
            updatedAt: 1,
          ),
        ],
      );
      final remote = SyncSnapshot(
        manga: [
          Manga(
            source: 'src',
            author: 'B',
            artist: 'B',
            genre: const ['Drama'],
            imageUrl: 'https://example.com/remote.jpg',
            lang: 'en',
            link: 'https://example.com/remote',
            name: 'Remote',
            status: Status.ongoing,
            description: 'desc',
            sourceId: 2,
            updatedAt: 2,
          ),
        ],
      );
      final remoteBytes = Uint8List.fromList(
        utf8.encode(jsonEncode(remote.toJson())),
      );

      final merged = resolveSnapshotForBidirectionalSync(
        local: local,
        pullResult: WebDavPullResult(bytes: remoteBytes, etag: 'etag-1'),
      );

      expect(merged.manga, hasLength(2));
      expect(
        merged.manga.map((e) => e.name).toSet(),
        {'Local', 'Remote'},
      );
    });
  });

  group('messageForWebDavException', () {
    final l10n = AppLocalizationsEn();

    test('returns localized message for 401', () {
      expect(
        messageForWebDavException(
          l10n,
          WebDavException('Unauthorized', statusCode: 401),
        ),
        l10n.webdav_invalid_credentials,
      );
    });

    test('returns original message for other status codes', () {
      expect(
        messageForWebDavException(
          l10n,
          WebDavException('Server error', statusCode: 500),
        ),
        'Server error',
      );
    });
  });

  group('ifMatchEtagForPush', () {
    test('returns null for first sync', () {
      final prefs = SyncPreference();

      expect(
        ifMatchEtagForPush(
          pullResult: const WebDavPullResult(notFound: true),
          prefs: prefs,
        ),
        isNull,
      );
    });

    test('prefers pull etag over stored etag', () {
      final prefs = SyncPreference(lastSyncEtag: 'stored');

      expect(
        ifMatchEtagForPush(
          pullResult: const WebDavPullResult(
            notModified: true,
            etag: 'from-pull',
          ),
          prefs: prefs,
        ),
        'from-pull',
      );
    });

    test('falls back to stored etag when pull has none', () {
      final prefs = SyncPreference(lastSyncEtag: 'stored');

      expect(
        ifMatchEtagForPush(
          pullResult: const WebDavPullResult(notModified: true),
          prefs: prefs,
        ),
        'stored',
      );
    });
  });
}
