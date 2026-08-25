import 'package:flutter_test/flutter_test.dart';
import 'package:mangayomi/eval/model/source_preference.dart';
import 'package:mangayomi/models/video.dart';
import 'package:mangayomi/services/anime/preferred_video_selector.dart';

Video _v(String quality, {String url = 'https://cdn.example/index.m3u8'}) {
  return Video(url, quality, url);
}

List<Video> _anikotoEpisodeList() {
  return [
    _v('Vidstream-2 - Sub - 1080p'),
    _v('Vidstream-2 - Sub - 720p'),
    _v('Vidstream-2 - Sub - 360p'),
    _v('HD-2 - Sub - 1080p'),
    _v('HD-2 - Sub - 720p'),
    _v(
      'VidPlay-1 - HSub - 1080p',
      url: 'http://localhost/m3u8',
    ),
    _v(
      'VidPlay-1 - HSub - 720p',
      url: 'http://localhost/m3u8',
    ),
    _v('Vidstream-2 - Dub - 1080p'),
    _v('Vidstream-2 - Dub - 720p'),
  ];
}

SourcePreference _listPref({
  required String key,
  required String title,
  required List<String> entries,
  required List<String> entryValues,
  required int valueIndex,
}) {
  return SourcePreference(
    key: key,
    listPreference: ListPreference(
      title: title,
      entries: entries,
      entryValues: entryValues,
      valueIndex: valueIndex,
    ),
  );
}

void main() {
  group('resolvePreferredStreamTokens', () {
    test('reads Anikoto-style keys and entryValues', () {
      final tokens = resolvePreferredStreamTokens([
        _listPref(
          key: 'preferred_type',
          title: 'Preferred Type',
          entries: const ['Sub', 'Hard Sub', 'Dub', 'H-Sub', 'A-Dub'],
          entryValues: const ['Sub', 'Hard Sub', 'Dub', 'H-Sub', 'A-Dub'],
          valueIndex: 3,
        ),
        _listPref(
          key: 'preferred_server',
          title: 'Preferred Server',
          entries: const ['HD-1', 'HD-2'],
          entryValues: const ['HD-1', 'HD-2'],
          valueIndex: 0,
        ),
        _listPref(
          key: 'preferred_quality',
          title: 'Preferred Quality',
          entries: const ['1080p', '720p'],
          entryValues: const ['1080p', '720p'],
          valueIndex: 0,
        ),
        _listPref(
          key: 'preferred_title_lang',
          title: 'Preferred Title Language',
          entries: const ['English', 'Romaji'],
          entryValues: const ['en', 'romaji'],
          valueIndex: 0,
        ),
      ]);
      expect(tokens.type, 'H-Sub');
      expect(tokens.server, 'HD-1');
      expect(tokens.quality, '1080p');
    });

    test('matches by title when key differs', () {
      final tokens = resolvePreferredStreamTokens([
        _listPref(
          key: 'pref_type',
          title: 'Preferred Type',
          entries: const ['Sub', 'Dub'],
          entryValues: const ['sub', 'dub'],
          valueIndex: 1,
        ),
      ]);
      expect(tokens.type, 'dub');
      expect(tokens.server, isNull);
    });

    test('falls back to entries when entryValues missing', () {
      final tokens = resolvePreferredStreamTokens([
        SourcePreference(
          key: 'preferred_quality',
          listPreference: ListPreference(
            title: 'Preferred Quality',
            entries: const ['720p', '1080p'],
            valueIndex: 1,
          ),
        ),
      ]);
      expect(tokens.quality, '1080p');
    });
  });

  group('sortVideosByPreference', () {
    test('empty prefs keeps original order', () {
      final videos = _anikotoEpisodeList();
      final sorted = sortVideosByPreference(videos);
      expect(
        sorted.map((e) => e.quality).toList(),
        videos.map((e) => e.quality).toList(),
      );
    });

    test('H-Sub preferred picks VidPlay HSub 1080p before Soft Sub', () {
      final sorted = sortVideosByPreference(
        _anikotoEpisodeList(),
        preferredType: 'H-Sub',
        preferredServer: 'HD-1',
        preferredQuality: '1080p',
      );
      expect(sorted.first.quality, 'VidPlay-1 - HSub - 1080p');
    });

    test('Hard Sub preferred matches HSub label token', () {
      final sorted = sortVideosByPreference(
        _anikotoEpisodeList(),
        preferredType: 'Hard Sub',
        preferredQuality: '1080p',
      );
      expect(sorted.first.quality, 'VidPlay-1 - HSub - 1080p');
    });

    test('Soft Sub preferred picks Soft Sub first', () {
      final sorted = sortVideosByPreference(
        _anikotoEpisodeList(),
        preferredType: 'Sub',
        preferredQuality: '1080p',
      );
      expect(sorted.first.quality, 'Vidstream-2 - Sub - 1080p');
      expect(sorted.first.quality.contains('HSub'), isFalse);
    });

    test('missing preferred server still picks type + quality', () {
      final sorted = sortVideosByPreference(
        _anikotoEpisodeList(),
        preferredType: 'H-Sub',
        preferredServer: 'HD-1',
        preferredQuality: '1080p',
      );
      expect(sorted.first.quality, 'VidPlay-1 - HSub - 1080p');
    });

    test('preferred server HD-2 wins when present with matching type', () {
      final sorted = sortVideosByPreference(
        _anikotoEpisodeList(),
        preferredType: 'Sub',
        preferredServer: 'HD-2',
        preferredQuality: '1080p',
      );
      expect(sorted.first.quality, 'HD-2 - Sub - 1080p');
    });

    test('empty list returns empty', () {
      expect(sortVideosByPreference(const []), isEmpty);
      expect(pickPreferredVideo(const []), isNull);
    });

    test('does not mutate input list', () {
      final videos = _anikotoEpisodeList();
      final originalFirst = videos.first.quality;
      sortVideosByPreference(
        videos,
        preferredType: 'H-Sub',
        preferredQuality: '1080p',
      );
      expect(videos.first.quality, originalFirst);
    });

    test('localhost penalty only breaks ties after type match', () {
      final soft = _v('X - HSub - 1080p');
      final local = _v(
        'Y - HSub - 1080p',
        url: 'http://localhost/m3u8',
      );
      final sorted = sortVideosByPreference(
        [local, soft],
        preferredType: 'H-Sub',
        preferredQuality: '1080p',
      );
      expect(sorted.first.quality, 'X - HSub - 1080p');
    });

    test('stable: equal scores keep relative order', () {
      final a = _v('A - Other - 480p');
      final b = _v('B - Other - 480p');
      final sorted = sortVideosByPreference(
        [a, b],
        preferredType: 'Sub',
      );
      expect(sorted.map((e) => e.quality).toList(), [
        'A - Other - 480p',
        'B - Other - 480p',
      ]);
    });
  });

  group('pickPreferredVideo', () {
    test('returns first after sort', () {
      final pick = pickPreferredVideo(
        _anikotoEpisodeList(),
        preferredType: 'Dub',
        preferredQuality: '1080p',
      );
      expect(pick?.quality, 'Vidstream-2 - Dub - 1080p');
    });
  });

  group('scoreVideoPreference', () {
    test('Sub pref does not score HSub as type match', () {
      final soft = scoreVideoPreference(
        _v('Vidstream-2 - Sub - 1080p'),
        preferredType: 'Sub',
      );
      final hard = scoreVideoPreference(
        _v('VidPlay-1 - HSub - 1080p'),
        preferredType: 'Sub',
      );
      expect(soft, greaterThan(hard));
    });
  });
}
