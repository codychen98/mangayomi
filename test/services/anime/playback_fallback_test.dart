import 'package:flutter_test/flutter_test.dart';
import 'package:mangayomi/models/video.dart';
import 'package:mangayomi/services/anime/playback_fallback.dart';

Video _v(String quality, String url) => Video(url, quality, url);

void main() {
  group('PlaybackFallbackState.markFailed', () {
    test('returns new state with trimmed url and incremented attempts', () {
      const empty = PlaybackFallbackState.empty;
      final next = empty.markFailed('  https://cdn/a  ');
      expect(next.failedUrls, {'https://cdn/a'});
      expect(next.attempts, 1);
      expect(empty.failedUrls, isEmpty);
      expect(empty.attempts, 0);
    });

    test('accumulates failed urls without mutating prior state', () {
      final first = PlaybackFallbackState.empty.markFailed('https://cdn/a');
      final second = first.markFailed('https://cdn/b');
      expect(first.failedUrls, {'https://cdn/a'});
      expect(first.attempts, 1);
      expect(second.failedUrls, {'https://cdn/a', 'https://cdn/b'});
      expect(second.attempts, 2);
    });
  });

  group('nextFallbackVideo', () {
    test('returns next in order when first fails', () {
      final ordered = [
        _v('A', 'https://cdn/a'),
        _v('B', 'https://cdn/b'),
        _v('C', 'https://cdn/c'),
      ];
      final state = PlaybackFallbackState.empty.markFailed('https://cdn/a');
      final next = nextFallbackVideo(
        ordered,
        currentUrl: 'https://cdn/a',
        state: state,
      );
      expect(next?.quality, 'B');
      expect(next?.url, 'https://cdn/b');
    });

    test(
      'skips candidates whose url equals a failed url (episode-22 case)',
      () {
        const shared =
            'http://127.0.0.1:62544/video/741d9a76-aaaa-bbbb-cccc-ddddeeeeffff';
        final ordered = [
          _v('Vidstream-2 - Sub - Video', shared),
          _v('HD-2 - Sub - Video', shared),
        ];
        final state = PlaybackFallbackState.empty.markFailed(shared);
        final next = nextFallbackVideo(
          ordered,
          currentUrl: shared,
          state: state,
        );
        expect(next, isNull);
      },
    );

    test('skips currentUrl even if not yet in failed set', () {
      final ordered = [
        _v('A', 'https://cdn/a'),
        _v('B', 'https://cdn/b'),
      ];
      final next = nextFallbackVideo(
        ordered,
        currentUrl: 'https://cdn/a',
        state: PlaybackFallbackState.empty,
      );
      expect(next?.quality, 'B');
    });

    test('returns null on empty list', () {
      expect(
        nextFallbackVideo(
          const [],
          currentUrl: 'https://cdn/a',
          state: PlaybackFallbackState.empty,
        ),
        isNull,
      );
    });

    test('returns null when all remaining urls have failed', () {
      final ordered = [
        _v('A', 'https://cdn/a'),
        _v('B', 'https://cdn/b'),
      ];
      final state = PlaybackFallbackState.empty
          .markFailed('https://cdn/a')
          .markFailed('https://cdn/b');
      expect(
        nextFallbackVideo(
          ordered,
          currentUrl: 'https://cdn/b',
          state: state,
        ),
        isNull,
      );
    });

    test('trims urls before comparison', () {
      final ordered = [
        _v('A', '  https://cdn/a  '),
        _v('B', '  https://cdn/b  '),
      ];
      final state = PlaybackFallbackState.empty.markFailed('https://cdn/a');
      final next = nextFallbackVideo(
        ordered,
        currentUrl: '  https://cdn/a  ',
        state: state,
      );
      expect(next?.quality, 'B');
    });

    test('preserves ordered list order across distinct urls', () {
      final ordered = [
        _v('first', 'https://cdn/1'),
        _v('second', 'https://cdn/2'),
        _v('third', 'https://cdn/3'),
      ];
      final state = PlaybackFallbackState.empty.markFailed('https://cdn/1');
      final next = nextFallbackVideo(
        ordered,
        currentUrl: 'https://cdn/1',
        state: state,
      );
      expect(next?.quality, 'second');
    });
  });

  group('duplicateStreamUrlLabels', () {
    test('returns groups only for urls with 2+ labels', () {
      const shared =
          'http://127.0.0.1:62544/video/741d9a76-aaaa-bbbb-cccc-ddddeeeeffff';
      final videos = [
        _v('Vidstream-2 - Sub - Video', shared),
        _v('HD-2 - Sub - Video', shared),
        _v('Unique', 'https://cdn/unique'),
      ];
      final dupes = duplicateStreamUrlLabels(videos);
      expect(dupes.keys, [shared]);
      expect(dupes[shared], [
        'Vidstream-2 - Sub - Video',
        'HD-2 - Sub - Video',
      ]);
    });

    test('returns empty map when all urls are unique', () {
      final videos = [
        _v('A', 'https://cdn/a'),
        _v('B', 'https://cdn/b'),
      ];
      expect(duplicateStreamUrlLabels(videos), isEmpty);
    });

    test('trims urls when grouping', () {
      final videos = [
        _v('A', '  https://cdn/same  '),
        _v('B', 'https://cdn/same'),
      ];
      final dupes = duplicateStreamUrlLabels(videos);
      expect(dupes.keys, ['https://cdn/same']);
      expect(dupes['https://cdn/same'], ['A', 'B']);
    });
  });
}
