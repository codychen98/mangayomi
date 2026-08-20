import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mangayomi/l10n/generated/app_localizations_en.dart';
import 'package:mangayomi/models/manga.dart';
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

    test('collapses duplicate Isar ids after merge (newest updatedAt wins)', () {
      final local = SyncSnapshot(
        manga: [
          Manga(
            id: 8,
            source: 'miruro.tv',
            author: 'A',
            artist: 'A',
            genre: const ['Action'],
            imageUrl: 'https://example.com/miruro.jpg',
            lang: 'en',
            link: 'https://miruro.tv/watch?id=170942',
            name: 'Ao no Hako',
            status: Status.ongoing,
            description: 'desc',
            sourceId: 10,
            itemType: ItemType.anime,
            updatedAt: 100,
            favorite: true,
          ),
        ],
      );
      final remote = SyncSnapshot(
        manga: [
          Manga(
            id: 8,
            source: 'Anikoto',
            author: 'A',
            artist: 'A',
            genre: const ['Action'],
            imageUrl: 'https://example.com/anikoto.jpg',
            lang: 'en',
            link: '/watch/blue-box#8#8',
            name: 'Blue Box',
            status: Status.ongoing,
            description: 'desc',
            sourceId: 20,
            itemType: ItemType.anime,
            updatedAt: 150,
            favorite: true,
          ),
          Manga(
            id: 8,
            source: 'Anikoto',
            author: 'A',
            artist: 'A',
            genre: const ['Action'],
            imageUrl: 'https://example.com/anikoto2.jpg',
            lang: 'en',
            link: 'https://anikototv.to/watch/blue-box#8#8#8',
            name: 'Blue Box',
            status: Status.ongoing,
            description: 'desc',
            sourceId: 20,
            itemType: ItemType.anime,
            updatedAt: 200,
            favorite: true,
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

      expect(merged.manga, hasLength(1));
      expect(merged.manga.single.source, 'Anikoto');
      expect(merged.manga.single.updatedAt, 200);
      expect(
        merged.manga.single.link,
        'https://anikototv.to/watch/blue-box#8#8#8',
      );
    });

    test('collapses duplicate Isar ids on local-only resolve', () {
      final local = SyncSnapshot(
        manga: [
          Manga(
            id: 8,
            source: 'miruro.tv',
            author: 'A',
            artist: 'A',
            genre: const ['Action'],
            imageUrl: 'https://example.com/miruro.jpg',
            lang: 'en',
            link: 'https://miruro.tv/watch?id=170942',
            name: 'Ao no Hako',
            status: Status.ongoing,
            description: 'desc',
            sourceId: 10,
            itemType: ItemType.anime,
            updatedAt: 100,
          ),
          Manga(
            id: 8,
            source: 'Anikoto',
            author: 'A',
            artist: 'A',
            genre: const ['Action'],
            imageUrl: 'https://example.com/anikoto.jpg',
            lang: 'en',
            link: 'https://anikototv.to/watch/blue-box#8',
            name: 'Blue Box',
            status: Status.ongoing,
            description: 'desc',
            sourceId: 20,
            itemType: ItemType.anime,
            updatedAt: 200,
          ),
        ],
      );

      final resolved = resolveSnapshotForBidirectionalSync(
        local: local,
        pullResult: const WebDavPullResult(notFound: true),
      );

      expect(resolved.manga, hasLength(1));
      expect(resolved.manga.single.source, 'Anikoto');
    });
  });

  group('withCollapsedMangaById', () {
    test('returns same snapshot when no duplicate ids', () {
      final snapshot = SyncSnapshot(
        manga: [
          Manga(
            id: 1,
            source: 'src',
            author: 'A',
            artist: 'A',
            genre: const ['Action'],
            imageUrl: 'https://example.com/1.jpg',
            lang: 'en',
            link: 'https://example.com/1',
            name: 'One',
            status: Status.ongoing,
            description: 'desc',
            sourceId: 1,
          ),
        ],
      );

      expect(identical(withCollapsedMangaById(snapshot), snapshot), isTrue);
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

  group('shouldApplyRemoteSnapshot', () {
    test('returns false when remote is missing or unchanged', () {
      expect(
        shouldApplyRemoteSnapshot(const WebDavPullResult(notFound: true)),
        isFalse,
      );
      expect(
        shouldApplyRemoteSnapshot(
          const WebDavPullResult(notModified: true, etag: 'abc'),
        ),
        isFalse,
      );
    });

    test('returns true when remote body is present', () {
      expect(
        shouldApplyRemoteSnapshot(
          WebDavPullResult(bytes: Uint8List.fromList(const [123]), etag: 'abc'),
        ),
        isTrue,
      );
    });
  });

  group('ifMatchEtagForPush', () {
    test('returns null for first sync', () {
      expect(
        ifMatchEtagForPush(
          pullResult: const WebDavPullResult(notFound: true),
        ),
        isNull,
      );
    });

    test('uses etag from current pull only', () {
      expect(
        ifMatchEtagForPush(
          pullResult: const WebDavPullResult(
            notModified: true,
            etag: 'from-pull',
          ),
        ),
        'from-pull',
      );
    });

    test('returns null when pull has no etag', () {
      expect(
        ifMatchEtagForPush(
          pullResult: const WebDavPullResult(notModified: true),
        ),
        isNull,
      );
    });
  });
}
