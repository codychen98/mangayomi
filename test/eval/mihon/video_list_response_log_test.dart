import 'package:flutter_test/flutter_test.dart';
import 'package:mangayomi/eval/mihon/video_list_response_log.dart';

void main() {
  group('mihonResponseBodyPreview', () {
    test('empty body', () {
      expect(mihonResponseBodyPreview(''), '(empty)');
      expect(mihonResponseBodyPreview('   \n\t'), '(empty)');
    });

    test('collapses whitespace', () {
      expect(mihonResponseBodyPreview('[\n  ]'), '[]');
    });

    test('truncates long body', () {
      final body = 'x' * 300;
      final preview = mihonResponseBodyPreview(body, maxChars: 50);
      expect(preview.startsWith('x' * 50), isTrue);
      expect(preview.contains('truncated,len=300'), isTrue);
    });
  });

  group('mihonListPreferenceLogSummary', () {
    test('empty payload', () {
      expect(mihonListPreferenceLogSummary(const []), '(none)');
    });

    test('no list prefs', () {
      expect(
        mihonListPreferenceLogSummary([
          {'key': 'onlySwitch', 'switchPreferenceCompat': {'value': true}},
        ]),
        '(no-list-prefs)',
      );
    });

    test('uses entryValues at valueIndex', () {
      expect(
        mihonListPreferenceLogSummary([
          {
            'key': 'Preferred Type',
            'listPreference': {
              'valueIndex': 1,
              'entries': ['Soft Sub', 'H-Sub', 'Dub'],
              'entryValues': ['sub', 'hsub', 'dub'],
            },
          },
        ]),
        'Preferred Type=hsub',
      );
    });

    test('falls back to entries when entryValues missing', () {
      expect(
        mihonListPreferenceLogSummary([
          {
            'key': 'Preferred Server',
            'listPreference': {
              'valueIndex': 0,
              'entries': ['HD-1', 'Vidstream-2'],
            },
          },
        ]),
        'Preferred Server=HD-1',
      );
    });
  });
}
