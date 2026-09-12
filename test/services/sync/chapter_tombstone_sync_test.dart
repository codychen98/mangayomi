import 'package:flutter_test/flutter_test.dart';
import 'package:mangayomi/models/chapter.dart';
import 'package:mangayomi/models/history.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/services/sync/sync_entity_keys.dart';
import 'package:mangayomi/services/sync/sync_merger.dart';
import 'package:mangayomi/services/sync/sync_snapshot.dart';
import 'package:mangayomi/services/sync/sync_tombstone.dart';

Manga _anime({
  required int id,
  String source = 'Anikoto',
  String link = 'https://example.com/anime#1',
  String name = 'Smoking Behind the Supermarket with You',
  int updatedAt = 100,
}) {
  return Manga(
    id: id,
    source: source,
    author: 'Author',
    artist: 'Artist',
    genre: const ['Comedy'],
    imageUrl: 'https://example.com/$id.jpg',
    lang: 'en',
    link: link,
    name: name,
    status: Status.ongoing,
    description: 'desc',
    sourceId: 55365075,
    itemType: ItemType.anime,
    updatedAt: updatedAt,
  );
}

Chapter _episode({
  required int id,
  required int mangaId,
  required String name,
  required String url,
  int updatedAt = 100,
}) {
  return Chapter(
    id: id,
    mangaId: mangaId,
    name: name,
    url: url,
    updatedAt: updatedAt,
  );
}

SyncTombstone _chapterTombstone(String key, int deletedAt) => SyncTombstone(
  entity: SyncTombstoneEntity.chapter,
  key: key,
  deletedAt: deletedAt,
);

void main() {
  group('chapterTombstoneKey', () {
    test('is built from itemType, source, url and name, normalized', () {
      final manga = _anime(id: 1, source: ' Anikoto ');
      final chapter = _episode(
        id: 10,
        mangaId: 1,
        name: ' E11: Episode 11 ',
        url: ' /watch/x/ep-11 ',
      );

      expect(
        chapterTombstoneKey(manga, chapter),
        '${ItemType.anime.index}|anikoto|/watch/x/ep-11|e11: episode 11',
      );
    });

    test('ignores parent manga link drift', () {
      final chapter = _episode(
        id: 10,
        mangaId: 1,
        name: 'Episode 1',
        url: '/watch/x/ep-1',
      );
      final before = _anime(id: 1, link: 'https://example.com/x#8950');
      final after = _anime(id: 1, link: 'https://example.com/x#8950#8950');

      expect(
        chapterTombstoneKey(before, chapter),
        chapterTombstoneKey(after, chapter),
      );
    });
  });

  group('SyncTombstone parsing', () {
    test('tryFromJson returns null for unknown entity index', () {
      expect(
        SyncTombstone.tryFromJson({'entity': 99, 'key': 'x', 'deletedAt': 1}),
        isNull,
      );
    });

    test('parseSyncTombstoneList skips unknown entities', () {
      final parsed = parseSyncTombstoneList([
        {'entity': SyncTombstoneEntity.chapter.index, 'key': 'a', 'deletedAt': 1},
        {'entity': 42, 'key': 'b', 'deletedAt': 2},
        'not a map',
      ]);

      expect(parsed, hasLength(1));
      expect(parsed.first.entity, SyncTombstoneEntity.chapter);
      expect(parsed.first.key, 'a');
    });

    test('chapter entity round-trips through the snapshot json', () {
      final snapshot = SyncSnapshot(
        tombstones: [_chapterTombstone('k', 5)],
      );

      final decoded = SyncSnapshot.fromJson(snapshot.toJson());

      expect(decoded.tombstones, hasLength(1));
      expect(decoded.tombstones.first.entity, SyncTombstoneEntity.chapter);
      expect(decoded.tombstones.first.compositeKey, '3|k');
    });
  });

  group('mergeSyncSnapshots chapter tombstones', () {
    final localManga = _anime(id: 1);
    final remoteManga = _anime(id: 1);

    test('drops a remote-only chapter that was deleted locally', () {
      final stale = _episode(
        id: 20,
        mangaId: 1,
        name: 'E11: Episode 11',
        url: '/watch/x/ep-11-old',
        updatedAt: 100,
      );
      final live = _episode(
        id: 21,
        mangaId: 1,
        name: 'Episode 11',
        url: '/watch/x/ep-11',
        updatedAt: 100,
      );
      final local = SyncSnapshot(
        manga: [localManga],
        chapters: [live],
        tombstones: [
          _chapterTombstone(chapterTombstoneKey(localManga, stale), 200),
        ],
      );
      final remote = SyncSnapshot(
        manga: [remoteManga],
        chapters: [stale, live],
      );

      final merged = mergeSyncSnapshots(local, remote);

      expect(merged.chapters.map((c) => c.url), ['/watch/x/ep-11']);
      expect(merged.tombstones, hasLength(1));
    });

    test('drops a local chapter when the remote carries the tombstone', () {
      final stale = _episode(
        id: 20,
        mangaId: 1,
        name: 'E11: Episode 11',
        url: '/watch/x/ep-11-old',
        updatedAt: 100,
      );
      final local = SyncSnapshot(manga: [localManga], chapters: [stale]);
      final remote = SyncSnapshot(
        manga: [remoteManga],
        tombstones: [
          _chapterTombstone(chapterTombstoneKey(remoteManga, stale), 200),
        ],
      );

      final merged = mergeSyncSnapshots(local, remote);

      expect(merged.chapters, isEmpty);
    });

    test('keeps a chapter re-added after the tombstone', () {
      final readded = _episode(
        id: 20,
        mangaId: 1,
        name: 'E11: Episode 11',
        url: '/watch/x/ep-11-old',
        updatedAt: 300,
      );
      final local = SyncSnapshot(
        manga: [localManga],
        tombstones: [
          _chapterTombstone(chapterTombstoneKey(localManga, readded), 200),
        ],
      );
      final remote = SyncSnapshot(manga: [remoteManga], chapters: [readded]);

      final merged = mergeSyncSnapshots(local, remote);

      expect(merged.chapters, hasLength(1));
    });

    test('does not affect the same url under a different source', () {
      final otherManga = _anime(id: 2, source: 'Miruro.tv');
      final chapter = _episode(
        id: 30,
        mangaId: 2,
        name: 'E11: Episode 11',
        url: '/watch/x/ep-11-old',
      );
      final tombstonedTwin = _episode(
        id: 20,
        mangaId: 1,
        name: 'E11: Episode 11',
        url: '/watch/x/ep-11-old',
      );
      final local = SyncSnapshot(
        manga: [localManga, otherManga],
        chapters: [chapter],
        tombstones: [
          _chapterTombstone(
            chapterTombstoneKey(localManga, tombstonedTwin),
            200,
          ),
        ],
      );
      final remote = SyncSnapshot(manga: [remoteManga, otherManga]);

      final merged = mergeSyncSnapshots(local, remote);

      expect(merged.chapters, hasLength(1));
      expect(merged.chapters.first.mangaId, 2);
    });

    test('history pointing at a tombstoned chapter loses its chapterId', () {
      final stale = _episode(
        id: 20,
        mangaId: 1,
        name: 'E11: Episode 11',
        url: '/watch/x/ep-11-old',
      );
      final local = SyncSnapshot(
        manga: [localManga],
        tombstones: [
          _chapterTombstone(chapterTombstoneKey(localManga, stale), 200),
        ],
      );
      final remote = SyncSnapshot(
        manga: [remoteManga],
        chapters: [stale],
        history: [
          History(
            id: 2,
            mangaId: 1,
            chapterId: 20,
            itemType: ItemType.anime,
            date: '2000',
            updatedAt: 100,
          ),
        ],
      );

      final merged = mergeSyncSnapshots(local, remote);

      expect(merged.chapters, isEmpty);
      expect(merged.history.single.chapterId, isNull);
    });
  });
}
