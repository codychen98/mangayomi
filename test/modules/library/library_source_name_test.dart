import 'package:flutter_test/flutter_test.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/modules/library/library_source_name.dart';
import 'package:mangayomi/utils/utils.dart';

void main() {
  group('resolveLibrarySourceName', () {
    test('prefers live source name over stored name', () {
      expect(
        resolveLibrarySourceName(
          isLocalArchive: false,
          storedSource: 'Miruro.tv',
          liveSourceName: 'Anikoto',
        ),
        'Anikoto',
      );
    });

    test('falls back to stored name when live is empty', () {
      expect(
        resolveLibrarySourceName(
          isLocalArchive: false,
          storedSource: 'Miruro.tv',
          liveSourceName: '  ',
        ),
        'Miruro.tv',
      );
    });

    test('local archive is always Local', () {
      expect(
        resolveLibrarySourceName(
          isLocalArchive: true,
          storedSource: 'Miruro.tv',
          liveSourceName: 'Anikoto',
        ),
        'Local',
      );
    });
  });

  group('selectSource', () {
    Source source({
      required int id,
      required String name,
      String? sourceCode,
    }) {
      return Source(id: id, name: name, lang: 'en')..sourceCode = sourceCode;
    }

    test('ID match wins over stale stored name', () {
      final selected = selectSource(
        [
          source(id: 2, name: 'Miruro.tv', sourceCode: 'miruro'),
          source(id: 1, name: 'Anikoto', sourceCode: 'anikoto'),
        ],
        lang: 'en',
        name: 'Miruro.tv',
        sourceId: 1,
      );
      expect(selected?.name, 'Anikoto');
    });

    test('ID match is used even when sourceCode is still missing', () {
      final selected = selectSource(
        [
          source(id: 2, name: 'Miruro.tv', sourceCode: 'miruro'),
          source(id: 1, name: 'Anikoto', sourceCode: null),
        ],
        lang: 'en',
        name: 'Miruro.tv',
        sourceId: 1,
      );
      expect(selected?.name, 'Anikoto');
    });

    test('falls back to name when sourceId is not in the list', () {
      final selected = selectSource(
        [
          source(id: 2, name: 'Miruro.tv', sourceCode: 'miruro'),
          source(id: 1, name: 'Anikoto', sourceCode: 'anikoto'),
        ],
        lang: 'en',
        name: 'Miruro.tv',
        sourceId: 99,
      );
      expect(selected?.name, 'Miruro.tv');
    });
  });
}
