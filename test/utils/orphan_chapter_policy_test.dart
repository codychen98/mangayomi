import 'package:flutter_test/flutter_test.dart';
import 'package:mangayomi/utils/orphan_chapter_policy.dart';

void main() {
  group('sourceUrlSet', () {
    test('trims and drops null/blank urls', () {
      expect(
        sourceUrlSet(const [' /a ', null, '', '  ', '/b']),
        {'/a', '/b'},
      );
    });
  });

  group('isOrphanChapterUrl', () {
    const source = {'/ep/1', '/ep/2'};

    test('true when trimmed url missing from source', () {
      expect(isOrphanChapterUrl(' /ep/9 ', source), isTrue);
    });

    test('false when url still on source', () {
      expect(isOrphanChapterUrl('/ep/1', source), isFalse);
    });

    test('false for null or blank url', () {
      expect(isOrphanChapterUrl(null, source), isFalse);
      expect(isOrphanChapterUrl('  ', source), isFalse);
    });
  });

  group('shouldDeleteOrphan', () {
    test('pref off → never delete', () {
      expect(
        shouldDeleteOrphan(
          isOrphan: true,
          isFullyDownloaded: false,
          removeMissingEnabled: false,
          sourceListNonEmpty: true,
        ),
        isFalse,
      );
    });

    test('empty source → never delete', () {
      expect(
        shouldDeleteOrphan(
          isOrphan: true,
          isFullyDownloaded: false,
          removeMissingEnabled: true,
          sourceListNonEmpty: false,
        ),
        isFalse,
      );
    });

    test('orphan + not downloaded → delete', () {
      expect(
        shouldDeleteOrphan(
          isOrphan: true,
          isFullyDownloaded: false,
          removeMissingEnabled: true,
          sourceListNonEmpty: true,
        ),
        isTrue,
      );
    });

    test('orphan + fully downloaded → keep', () {
      expect(
        shouldDeleteOrphan(
          isOrphan: true,
          isFullyDownloaded: true,
          removeMissingEnabled: true,
          sourceListNonEmpty: true,
        ),
        isFalse,
      );
    });

    test('non-orphan → keep', () {
      expect(
        shouldDeleteOrphan(
          isOrphan: false,
          isFullyDownloaded: false,
          removeMissingEnabled: true,
          sourceListNonEmpty: true,
        ),
        isFalse,
      );
    });
  });

  group('chapterIdsToDeleteAsOrphans', () {
    const source = {'/live/1', '/live/2'};

    final existing = [
      const OrphanChapterCandidate(
        id: 1,
        url: '/live/1',
        isFullyDownloaded: false,
      ),
      const OrphanChapterCandidate(
        id: 2,
        url: '/ghost/sub',
        isFullyDownloaded: false,
      ),
      const OrphanChapterCandidate(
        id: 3,
        url: '/ghost/downloaded',
        isFullyDownloaded: true,
      ),
      const OrphanChapterCandidate(
        id: 4,
        url: null,
        isFullyDownloaded: false,
      ),
    ];

    test('pref off → empty', () {
      expect(
        chapterIdsToDeleteAsOrphans(
          existing: existing,
          sourceUrls: source,
          removeMissingEnabled: false,
        ),
        isEmpty,
      );
    });

    test('empty source → empty', () {
      expect(
        chapterIdsToDeleteAsOrphans(
          existing: existing,
          sourceUrls: const {},
          removeMissingEnabled: true,
        ),
        isEmpty,
      );
    });

    test('deletes undownloaded orphans only; bookmark is not an input', () {
      // Bookmarks are intentionally omitted from [OrphanChapterCandidate];
      // keep/delete depends only on orphan status + completed download.
      expect(
        chapterIdsToDeleteAsOrphans(
          existing: existing,
          sourceUrls: source,
          removeMissingEnabled: true,
        ),
        [2],
      );
    });
  });
}
