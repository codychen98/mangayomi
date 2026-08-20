import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/services/sync/collapse_manga_by_id.dart';
import 'package:mangayomi/services/sync/sync_merger.dart';

Manga _manga({
  int? id,
  required String name,
  required String link,
  required String source,
  ItemType itemType = ItemType.anime,
  int updatedAt = 0,
  int? sourceId = 1,
  bool favorite = true,
}) {
  return Manga(
    id: id,
    source: source,
    author: 'Author',
    artist: 'Artist',
    genre: const ['Action'],
    imageUrl: 'https://example.com/$name.jpg',
    lang: 'en',
    link: link,
    name: name,
    status: Status.ongoing,
    description: 'desc',
    sourceId: sourceId,
    itemType: itemType,
    updatedAt: updatedAt,
    favorite: favorite,
  );
}

void main() {
  group('collapseMangaById', () {
    test('Miruro and Anikoto same id keeps newer Anikoto', () {
      final miruro = _manga(
        id: 8,
        name: 'Ao no Hako',
        link: 'https://miruro.tv/watch?id=170942',
        source: 'miruro.tv',
        updatedAt: 100,
        sourceId: 10,
      );
      final anikoto = _manga(
        id: 8,
        name: 'Blue Box',
        link: 'https://anikototv.to/watch/blue-box#8',
        source: 'Anikoto',
        updatedAt: 200,
        sourceId: 20,
      );

      final collapsed = collapseMangaById([miruro, anikoto]);

      expect(collapsed, hasLength(1));
      expect(collapsed.single.source, 'Anikoto');
      expect(collapsed.single.name, 'Blue Box');
      expect(collapsed.single.updatedAt, 200);
    });

    test('three Anikoto link variants keeps newest updatedAt', () {
      final older = _manga(
        id: 8,
        name: 'Blue Box',
        link: '/watch/blue-box#8#8',
        source: 'Anikoto',
        updatedAt: 100,
      );
      final newest = _manga(
        id: 8,
        name: 'Blue Box',
        link: 'https://anikototv.to/watch/blue-box#8#8#8',
        source: 'Anikoto',
        updatedAt: 300,
      );
      final middle = _manga(
        id: 8,
        name: 'Blue Box',
        link: '/watch/blue-box#8',
        source: 'Anikoto',
        updatedAt: 200,
      );

      final collapsed = collapseMangaById([older, newest, middle]);

      expect(collapsed, hasLength(1));
      expect(collapsed.single.link, newest.link);
      expect(collapsed.single.updatedAt, 300);
    });

    test('null id entries are kept as-is and not collapsed together', () {
      final a = _manga(
        id: null,
        name: 'Untitled A',
        link: 'https://example.com/a',
        source: 'A',
        updatedAt: 50,
      );
      final b = _manga(
        id: null,
        name: 'Untitled B',
        link: 'https://example.com/b',
        source: 'B',
        updatedAt: 50,
      );

      final collapsed = collapseMangaById([a, b]);

      expect(collapsed, hasLength(2));
      expect(collapsed[0].name, 'Untitled A');
      expect(collapsed[1].name, 'Untitled B');
    });

    test('Isar.autoIncrement ids are kept as-is and not collapsed together', () {
      final a = _manga(
        id: Isar.autoIncrement,
        name: 'Auto A',
        link: 'https://example.com/a',
        source: 'A',
        updatedAt: 50,
      );
      final b = _manga(
        id: Isar.autoIncrement,
        name: 'Auto B',
        link: 'https://example.com/b',
        source: 'B',
        updatedAt: 50,
      );

      final collapsed = collapseMangaById([a, b]);

      expect(collapsed, hasLength(2));
      expect(collapsed.map((e) => e.name).toList(), ['Auto A', 'Auto B']);
    });

    test('unique ids are preserved in first-appearance order', () {
      final first = _manga(
        id: 1,
        name: 'One',
        link: 'https://example.com/1',
        source: 'S',
        updatedAt: 1,
      );
      final second = _manga(
        id: 2,
        name: 'Two',
        link: 'https://example.com/2',
        source: 'S',
        updatedAt: 1,
      );

      final collapsed = collapseMangaById([first, second]);

      expect(collapsed.map((e) => e.id), [1, 2]);
    });

    test('tie on updatedAt prefers non-null sourceId', () {
      final withoutSourceId = _manga(
        id: 8,
        name: 'Blue Box',
        link: 'https://example.com/a',
        source: 'Anikoto',
        updatedAt: 100,
        sourceId: null,
      );
      final withSourceId = _manga(
        id: 8,
        name: 'Blue Box',
        link: 'https://example.com/b',
        source: 'Anikoto',
        updatedAt: 100,
        sourceId: 42,
      );

      final collapsed = collapseMangaById([withoutSourceId, withSourceId]);

      expect(collapsed, hasLength(1));
      expect(collapsed.single.sourceId, 42);
      expect(collapsed.single.link, withSourceId.link);
    });

    test('tie on updatedAt and sourceId prefers greater mangaSyncKey', () {
      final lowerKey = _manga(
        id: 8,
        name: 'Blue Box',
        link: 'https://example.com/a',
        source: 'Anikoto',
        updatedAt: 100,
        sourceId: 1,
      );
      final higherKey = _manga(
        id: 8,
        name: 'Blue Box',
        link: 'https://example.com/z',
        source: 'Anikoto',
        updatedAt: 100,
        sourceId: 1,
      );

      expect(
        mangaSyncKey(higherKey).compareTo(mangaSyncKey(lowerKey)),
        greaterThan(0),
      );

      final collapsed = collapseMangaById([lowerKey, higherKey]);

      expect(collapsed, hasLength(1));
      expect(collapsed.single.link, higherKey.link);
    });

    test('empty list returns empty list', () {
      expect(collapseMangaById(const []), isEmpty);
    });
  });
}
