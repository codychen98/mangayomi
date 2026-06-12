import 'package:flutter_test/flutter_test.dart';
import 'package:mangayomi/models/category.dart';
import 'package:mangayomi/models/chapter.dart';
import 'package:mangayomi/models/history.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/settings.dart';
import 'package:mangayomi/services/sync/sync_merger.dart';
import 'package:mangayomi/services/sync/sync_snapshot.dart';

Manga _manga({
  required int id,
  required String name,
  required String link,
  ItemType itemType = ItemType.manga,
  int updatedAt = 0,
  List<int>? categories,
}) {
  return Manga(
    id: id,
    source: 'test-src',
    author: 'Author',
    artist: 'Artist',
    genre: const ['Action'],
    imageUrl: 'https://example.com/$id.jpg',
    lang: 'en',
    link: link,
    name: name,
    status: Status.ongoing,
    description: 'desc',
    sourceId: 1,
    itemType: itemType,
    updatedAt: updatedAt,
    categories: categories,
  );
}

void main() {
  group('mergeSyncSnapshots', () {
    test('keeps different manga from each side', () {
      final local = SyncSnapshot(
        manga: [
          _manga(id: 1, name: 'Local Manga', link: 'https://example.com/local'),
        ],
      );
      final remote = SyncSnapshot(
        manga: [
          _manga(id: 2, name: 'Remote Manga', link: 'https://example.com/remote'),
        ],
      );

      final merged = mergeSyncSnapshots(local, remote);

      expect(merged.manga, hasLength(2));
      expect(
        merged.manga.map((e) => e.name).toSet(),
        {'Local Manga', 'Remote Manga'},
      );
    });

    test('keeps anime and manga without cross-type collision', () {
      final local = SyncSnapshot(
        manga: [
          _manga(
            id: 1,
            name: 'Device A Anime',
            link: 'https://example.com/anime-a',
            itemType: ItemType.anime,
          ),
        ],
      );
      final remote = SyncSnapshot(
        manga: [
          _manga(
            id: 2,
            name: 'Device B Manga',
            link: 'https://example.com/manga-b',
            itemType: ItemType.manga,
          ),
        ],
      );

      final merged = mergeSyncSnapshots(local, remote);

      expect(merged.manga, hasLength(2));
      expect(merged.manga.any((e) => e.itemType == ItemType.anime), isTrue);
      expect(merged.manga.any((e) => e.itemType == ItemType.manga), isTrue);
    });

    test('does not merge anime and manga categories with the same name', () {
      final local = SyncSnapshot(
        categories: [
          Category(
            id: 1,
            name: 'Favorites',
            forItemType: ItemType.manga,
            updatedAt: 100,
          ),
        ],
      );
      final remote = SyncSnapshot(
        categories: [
          Category(
            id: 2,
            name: 'Favorites',
            forItemType: ItemType.anime,
            updatedAt: 200,
          ),
        ],
      );

      final merged = mergeSyncSnapshots(local, remote);

      expect(merged.categories, hasLength(2));
      expect(
        merged.categories.map((e) => e.forItemType).toSet(),
        {ItemType.manga, ItemType.anime},
      );
    });

    test('newer updatedAt wins for the same library entry', () {
      final local = SyncSnapshot(
        manga: [
          _manga(
            id: 1,
            name: 'Shared Title',
            link: 'https://example.com/shared',
            updatedAt: 100,
          )..description = 'local description',
        ],
      );
      final remote = SyncSnapshot(
        manga: [
          _manga(
            id: 99,
            name: 'Shared Title',
            link: 'https://example.com/shared',
            updatedAt: 500,
          )..description = 'remote description',
        ],
      );

      final merged = mergeSyncSnapshots(local, remote);

      expect(merged.manga, hasLength(1));
      expect(merged.manga.first.description, 'remote description');
      expect(merged.manga.first.id, 99);
    });

    test('merges episode watch progress by composite chapter key', () {
      final localManga = _manga(
        id: 1,
        name: 'Shared Anime',
        link: 'https://example.com/anime',
        itemType: ItemType.anime,
      );
      final remoteManga = _manga(
        id: 50,
        name: 'Shared Anime',
        link: 'https://example.com/anime',
        itemType: ItemType.anime,
      );
      final local = SyncSnapshot(
        manga: [localManga],
        chapters: [
          Chapter(
            id: 10,
            mangaId: 1,
            name: 'Episode 1',
            url: 'https://example.com/ep/1',
            isRead: false,
            lastPageRead: '0',
            duration: '24:00',
            updatedAt: 100,
          ),
        ],
      );
      final remote = SyncSnapshot(
        manga: [remoteManga],
        chapters: [
          Chapter(
            id: 20,
            mangaId: 50,
            name: 'Episode 1',
            url: 'https://example.com/ep/1',
            isRead: true,
            lastPageRead: '1200',
            duration: '24:00',
            updatedAt: 900,
          ),
        ],
      );

      final merged = mergeSyncSnapshots(local, remote);

      expect(merged.chapters, hasLength(1));
      final episode = merged.chapters.first;
      expect(episode.isRead, isTrue);
      expect(episode.lastPageRead, '1200');
      expect(episode.mangaId, merged.manga.first.id);
    });

    test('re-links history mangaId and chapterId after merge', () {
      final localManga = _manga(
        id: 1,
        name: 'History Anime',
        link: 'https://example.com/history',
        itemType: ItemType.anime,
      );
      final remoteManga = _manga(
        id: 2,
        name: 'History Anime',
        link: 'https://example.com/history',
        itemType: ItemType.anime,
      );
      final localChapter = Chapter(
        id: 10,
        mangaId: 1,
        name: 'Episode 1',
        url: 'https://example.com/ep/1',
        updatedAt: 50,
      );
      final remoteChapter = Chapter(
        id: 20,
        mangaId: 2,
        name: 'Episode 1',
        url: 'https://example.com/ep/1',
        updatedAt: 50,
      );
      final local = SyncSnapshot(
        manga: [localManga],
        chapters: [localChapter],
        history: [
          History(
            id: 1,
            mangaId: 1,
            chapterId: 10,
            itemType: ItemType.anime,
            date: '1000',
            updatedAt: 100,
          ),
        ],
      );
      final remote = SyncSnapshot(
        manga: [remoteManga],
        chapters: [remoteChapter],
        history: [
          History(
            id: 2,
            mangaId: 2,
            chapterId: 20,
            itemType: ItemType.anime,
            date: '2000',
            updatedAt: 500,
          ),
        ],
      );

      final merged = mergeSyncSnapshots(local, remote);

      expect(merged.history, hasLength(1));
      expect(merged.history.first.date, '2000');
      expect(merged.history.first.mangaId, merged.manga.first.id);
      expect(merged.history.first.chapterId, merged.chapters.first.id);
    });

    test('merges settings with cookies without type errors', () {
      final local = SyncSnapshot(
        settings: [
          Settings.fromJson({
            'id': 227,
            'updatedAt': 100,
            'cookiesList': [],
          }),
        ],
      );
      final remote = SyncSnapshot(
        settings: [
          Settings.fromJson({
            'id': 227,
            'updatedAt': 500,
            'cookiesList': [
              {'host': 'example.com', 'cookie': 'session=abc'},
            ],
          }),
        ],
      );

      final merged = mergeSyncSnapshots(local, remote);

      expect(merged.settings, hasLength(1));
      expect(merged.settings.first.updatedAt, 500);
      expect(
        Settings.fromJson(merged.settings.first.toJson()).cookiesList,
        hasLength(1),
      );
    });
  });
}
