import 'package:flutter_test/flutter_test.dart';
import 'package:mangayomi/eval/model/filter.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/services/fetch_sources_list.dart';

Source _mihonSource({
  bool? supportLatest,
  String? filterList,
  String? preferenceList,
  bool isAdded = true,
  String sourceCode = 'encoded-apk',
}) {
  return Source()
    ..id = 1
    ..sourceCodeLanguage = SourceCodeLanguage.mihon
    ..sourceCode = sourceCode
    ..isAdded = isAdded
    ..supportLatest = supportLatest
    ..filterList = filterList
    ..preferenceList = preferenceList;
}

const _selectFilterJson = '''
[
  {
    "name": "Sort",
    "state": 0,
    "values": ["Latest", "Popular"]
  }
]
''';

void main() {
  group('parseDalvikBoolResponse', () {
    test('parses plain-text true and false', () {
      expect(parseDalvikBoolResponse('true'), isTrue);
      expect(parseDalvikBoolResponse(' false '), isFalse);
    });

    test('parses JSON-encoded booleans', () {
      expect(parseDalvikBoolResponse('true'), isTrue);
      expect(parseDalvikBoolResponse('false'), isFalse);
    });

    test('returns null for error bodies and non-200 status', () {
      expect(parseDalvikBoolResponse('{"error":"failed"}'), isNull);
      expect(parseDalvikBoolResponse('true', statusCode: 500), isNull);
      expect(parseDalvikBoolResponse('not-a-bool'), isNull);
    });
  });

  group('parseDalvikFilterResponse', () {
    test('parses bare JSON array', () {
      final result = parseDalvikFilterResponse(_selectFilterJson);
      expect(result, isA<FilterList>());
      expect(result!.filters, isNotEmpty);
      expect(result.filters.first, isA<SelectFilter>());
    });

    test('parses wrapped list object', () {
      final result = parseDalvikFilterResponse(
        '{"list":[{"name":"Sort","state":0,"values":["Latest","Popular"]}]}',
      );
      expect(result, isA<FilterList>());
      expect(result!.filters, isNotEmpty);
    });

    test('returns null for error and invalid bodies', () {
      expect(parseDalvikFilterResponse('{"error":"failed"}'), isNull);
      expect(parseDalvikFilterResponse('{"unexpected":[]}'), isNull);
      expect(parseDalvikFilterResponse('not-json'), isNull);
    });
  });

  group('parseDalvikPreferencesResponse', () {
    test('parses bare JSON array', () {
      final result = parseDalvikPreferencesResponse(
        '[{"key":"quality","listPreference":{"title":"Quality","entries":["1080p"],"entryValues":["1080p"],"valueIndex":0}}]',
      );
      expect(result, isNotNull);
      expect(result, hasLength(1));
    });

    test('parses wrapped list object', () {
      final result = parseDalvikPreferencesResponse(
        '{"list":[{"key":"quality","listPreference":{"title":"Quality","entries":["1080p"],"entryValues":["1080p"],"valueIndex":0}}]}',
      );
      expect(result, isNotNull);
      expect(result, hasLength(1));
    });

    test('returns null for error and invalid bodies', () {
      expect(parseDalvikPreferencesResponse('{"error":"failed"}'), isNull);
      expect(parseDalvikPreferencesResponse('not-json'), isNull);
    });
  });

  group('mihonSourceMetadataMissing', () {
    test('returns false for non-mihon or uninstalled sources', () {
      expect(
        mihonSourceMetadataMissing(
          _mihonSource(
            supportLatest: true,
            filterList: '{"filters":[]}',
            preferenceList: '[]',
            isAdded: false,
          ),
        ),
        isFalse,
      );
      expect(
        mihonSourceMetadataMissing(
          Source()
            ..sourceCodeLanguage = SourceCodeLanguage.dart
            ..isAdded = true
            ..sourceCode = 'code',
        ),
        isFalse,
      );
    });

    test('returns false when all metadata fields are present', () {
      expect(
        mihonSourceMetadataMissing(
          _mihonSource(
            supportLatest: false,
            filterList: '{"filters":[]}',
            preferenceList: '[]',
          ),
        ),
        isFalse,
      );
    });

    test('returns true when any metadata field is absent', () {
      expect(
        mihonSourceMetadataMissing(
          _mihonSource(
            filterList: '{"filters":[]}',
            preferenceList: '[]',
          ),
        ),
        isTrue,
      );
      expect(
        mihonSourceMetadataMissing(
          _mihonSource(
            supportLatest: true,
            preferenceList: '[]',
          ),
        ),
        isTrue,
      );
      expect(
        mihonSourceMetadataMissing(
          _mihonSource(
            supportLatest: true,
            filterList: '{"filters":[]}',
          ),
        ),
        isTrue,
      );
    });
  });
}
