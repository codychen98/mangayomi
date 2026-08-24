import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mangayomi/eval/model/source_preference.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/modules/browse/extension/providers/extension_preferences_providers.dart';

void main() {
  group('copyPreferenceForPersist', () {
    test('copies ListPreference valueIndex explicitly', () {
      final original = SourcePreference(
        key: 'preferred_type',
        sourceId: 1,
        listPreference: ListPreference(
          title: 'Preferred Type',
          valueIndex: 0,
          entries: const ['Hard Sub', 'Soft Sub', 'H-sub'],
          entryValues: const ['hard', 'soft', 'hsub'],
        ),
      );
      original.listPreference!.valueIndex = 2;

      final copied = copyPreferenceForPersist(
        original,
        sourceId: 1,
        id: 42,
      );

      expect(copied.id, 42);
      expect(copied.sourceId, 1);
      expect(copied.key, 'preferred_type');
      expect(copied.listPreference!.valueIndex, 2);
      expect(copied.listPreference!.entries, ['Hard Sub', 'Soft Sub', 'H-sub']);
      expect(copied.listPreference!.entryValues, ['hard', 'soft', 'hsub']);

      // Mutating the original after copy must not affect the persisted copy.
      original.listPreference!.valueIndex = 0;
      expect(copied.listPreference!.valueIndex, 2);
    });
  });

  group('mergePreferenceIntoPreferenceListJson', () {
    test('updates matching key valueIndex in preferenceList JSON', () {
      final existing = jsonEncode([
        SourcePreference(
          key: 'preferred_type',
          listPreference: ListPreference(
            title: 'Preferred Type',
            valueIndex: 0,
            entries: const ['Hard Sub', 'Soft Sub'],
            entryValues: const ['hard', 'soft'],
          ),
        ).toJson(),
        SourcePreference(
          key: 'quality',
          listPreference: ListPreference(
            title: 'Quality',
            valueIndex: 0,
            entries: const ['1080p'],
            entryValues: const ['1080p'],
          ),
        ).toJson(),
      ]);

      final updated = SourcePreference(
        key: 'preferred_type',
        sourceId: 9,
        listPreference: ListPreference(
          title: 'Preferred Type',
          valueIndex: 1,
          entries: const ['Hard Sub', 'Soft Sub'],
          entryValues: const ['hard', 'soft'],
        ),
      );

      final mergedJson = mergePreferenceIntoPreferenceListJson(existing, updated);
      final merged = (jsonDecode(mergedJson) as List)
          .map((e) => SourcePreference.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(merged, hasLength(2));
      expect(merged[0].key, 'preferred_type');
      expect(merged[0].listPreference!.valueIndex, 1);
      expect(merged[1].key, 'quality');
      expect(merged[1].listPreference!.valueIndex, 0);
    });

    test('appends when key is missing from preferenceList', () {
      final existing = jsonEncode([
        SourcePreference(
          key: 'quality',
          listPreference: ListPreference(
            title: 'Quality',
            valueIndex: 0,
            entries: const ['1080p'],
            entryValues: const ['1080p'],
          ),
        ).toJson(),
      ]);

      final updated = SourcePreference(
        key: 'preferred_type',
        sourceId: 9,
        listPreference: ListPreference(
          title: 'Preferred Type',
          valueIndex: 2,
          entries: const ['Hard Sub', 'Soft Sub', 'H-sub'],
          entryValues: const ['hard', 'soft', 'hsub'],
        ),
      );

      final mergedJson = mergePreferenceIntoPreferenceListJson(existing, updated);
      final merged = (jsonDecode(mergedJson) as List)
          .map((e) => SourcePreference.fromJson(e as Map<String, dynamic>))
          .toList();

      expect(merged, hasLength(2));
      expect(merged.last.key, 'preferred_type');
      expect(merged.last.listPreference!.valueIndex, 2);
    });
  });

  group('resolveMihonSourcePreferences / dalvik payload', () {
    test('returns empty when preferenceList is null or empty', () {
      expect(resolveMihonSourcePreferences(Source()), isEmpty);
      expect(
        resolveMihonSourcePreferences(Source()..preferenceList = ''),
        isEmpty,
      );
      expect(
        resolveMihonSourcePreferences(Source()..preferenceList = '[]'),
        isEmpty,
      );
    });

    test('dalvik payload includes listPreference valueIndex as JSON maps', () {
      final source = Source()
        ..preferenceList = jsonEncode([
          SourcePreference(
            key: 'preferred_type',
            listPreference: ListPreference(
              title: 'Preferred Type',
              valueIndex: 1,
              entries: const ['Hard Sub', 'Soft Sub'],
              entryValues: const ['hard', 'soft'],
            ),
          ).toJson(),
        ]);

      final payload = mihonPreferencesDalvikPayload(source);

      expect(payload, hasLength(1));
      expect(payload.first['key'], 'preferred_type');
      expect(
        (payload.first['listPreference'] as Map)['valueIndex'],
        1,
      );
      // Must be encodable for Dalvik without JsonUnsupportedObjectError.
      expect(() => jsonEncode({'preferences': payload}), returnsNormally);
    });
  });
}
