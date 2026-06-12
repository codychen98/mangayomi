import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:mangayomi/main.dart' as app;
import 'package:mangayomi/models/category.dart';
import 'package:mangayomi/models/chapter.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/settings.dart';
import 'package:mangayomi/models/sync_preference.dart';
import 'package:mangayomi/services/sync/sync_snapshot.dart';

void main() {
  group('SyncSnapshot', () {
    test('fromJson(toJson(snapshot)) round-trip preserves anime data', () {
      final snapshot = SyncSnapshot(
        manga: [
          Manga(
            source: 'test',
            author: 'Author',
            artist: 'Artist',
            genre: ['Action'],
            imageUrl: 'https://example.com/cover.jpg',
            lang: 'en',
            link: 'https://example.com/anime/1',
            name: 'Test Anime',
            status: Status.ongoing,
            description: 'An anime entry',
            sourceId: 1,
            itemType: ItemType.anime,
            favorite: true,
            id: 42,
            updatedAt: 1_700_000_000_000,
          ),
        ],
        categories: [
          Category(
            name: 'Watching',
            forItemType: ItemType.anime,
            id: 7,
            updatedAt: 1_700_000_000_001,
          ),
        ],
        chapters: [
          Chapter(
            mangaId: 42,
            name: 'Episode 1',
            url: 'https://example.com/ep/1',
            isRead: true,
            lastPageRead: '120',
            duration: '24:00',
            id: 100,
            updatedAt: 1_700_000_000_002,
          ),
        ],
      );

      final restored = SyncSnapshot.fromJson(snapshot.toJson());

      expect(restored.version, '2');
      expect(restored.manga, hasLength(1));
      expect(restored.manga.first.itemType, ItemType.anime);
      expect(restored.manga.first.name, 'Test Anime');
      expect(restored.categories.first.forItemType, ItemType.anime);
      expect(restored.chapters, hasLength(1));
      expect(restored.chapters.first.duration, '24:00');
      expect(restored.chapters.first.isRead, isTrue);
    });

    test('buildLocalSnapshot exports all library rows without favorite filter',
        () async {
      final tempDir = await Directory.systemTemp.createTemp('sync_snapshot_test');
      final isarInstance = await Isar.open(
        [
          MangaSchema,
          CategorySchema,
          ChapterSchema,
          SettingsSchema,
        ],
        directory: tempDir.path,
        name: 'sync_snapshot_test',
      );
      app.isar = isarInstance;

      try {
        await isarInstance.writeTxn(() async {
          final settings = Settings(id: 227);
          await isarInstance.settings.put(settings);

          final favorited = Manga(
            source: 'src',
            author: 'A',
            artist: 'A',
            genre: ['Drama'],
            imageUrl: 'https://example.com/fav.jpg',
            lang: 'en',
            link: 'https://example.com/fav',
            name: 'Favorited Manga',
            status: Status.ongoing,
            description: 'fav',
            sourceId: 1,
            favorite: true,
          );
          final unfavorited = Manga(
            source: 'src',
            author: 'B',
            artist: 'B',
            genre: ['Comedy'],
            imageUrl: 'https://example.com/unfav.jpg',
            lang: 'en',
            link: 'https://example.com/unfav',
            name: 'Unfavorited Anime',
            status: Status.ongoing,
            description: 'unfav',
            sourceId: 2,
            itemType: ItemType.anime,
            favorite: false,
          );
          await isarInstance.mangas.putAll([favorited, unfavorited]);

          await isarInstance.chapters.put(
            Chapter(
              mangaId: unfavorited.id,
              name: 'Episode 1',
              url: 'https://example.com/ep/1',
            ),
          );
        });

        final prefs = SyncPreference(
          syncHistories: false,
          syncUpdates: false,
          syncSettings: false,
        );
        final snapshot = buildLocalSnapshot(prefs);

        expect(snapshot.manga, hasLength(2));
        expect(
          snapshot.manga.map((e) => e.name).toSet(),
          {'Favorited Manga', 'Unfavorited Anime'},
        );
        expect(
          snapshot.manga.any((e) => e.itemType == ItemType.anime),
          isTrue,
        );
        expect(snapshot.chapters, hasLength(1));
        expect(snapshot.manga.every((e) => e.customCoverImage == null), isTrue);
      } finally {
        await isarInstance.close(deleteFromDisk: true);
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    });
  });
}
