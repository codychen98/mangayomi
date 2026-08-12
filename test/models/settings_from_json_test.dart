import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mangayomi/models/settings.dart';

Map<String, dynamic> _json(String source) =>
    jsonDecode(source) as Map<String, dynamic>;

void main() {
  group('Settings.fromJson', () {
    test('empty map does not throw and uses enum defaults', () {
      final settings = Settings.fromJson(_json('{}'));

      expect(settings.displayType, DisplayType.compactGrid);
      expect(settings.animeDisplayType, DisplayType.compactGrid);
      expect(settings.mangaHomeDisplayType, DisplayType.comfortableGrid);
      expect(settings.novelDisplayType, DisplayType.comfortableGrid);
      expect(settings.defaultReaderMode, ReaderMode.vertical);
      expect(settings.scaleType, ScaleType.fitScreen);
      expect(settings.backgroundColor, BackgroundColor.black);
      expect(settings.colorFilterBlendMode, ColorFilterBlendMode.none);
      expect(settings.disableSectionType, SectionType.all);
      expect(settings.novelTextAlign, NovelTextAlign.left);
      expect(settings.debandingType, DebandingType.none);
      expect(settings.audioChannels, AudioChannel.autoSafe);
      expect(settings.flexColorSchemeBlendLevel, isNull);
      expect(settings.defaultPlayBackSpeed, isNull);
      expect(settings.personalReaderModeList, isNull);
      expect(settings.personalPageModeList, isNull);
    });

    test('null and out-of-range enum fields use defaults', () {
      final settings = Settings.fromJson(
        _json('''
{
  "displayType": null,
  "animeDisplayType": 99,
  "mangaHomeDisplayType": -1,
  "novelDisplayType": "grid",
  "defaultReaderMode": null,
  "scaleType": 999,
  "backgroundColor": null,
  "colorFilterBlendMode": -5,
  "disableSectionType": 50,
  "novelTextAlign": null,
  "debandingType": 8,
  "audioChannels": "auto"
}
'''),
      );

      expect(settings.displayType, DisplayType.compactGrid);
      expect(settings.animeDisplayType, DisplayType.compactGrid);
      expect(settings.mangaHomeDisplayType, DisplayType.comfortableGrid);
      expect(settings.novelDisplayType, DisplayType.comfortableGrid);
      expect(settings.defaultReaderMode, ReaderMode.vertical);
      expect(settings.scaleType, ScaleType.fitScreen);
      expect(settings.backgroundColor, BackgroundColor.black);
      expect(settings.colorFilterBlendMode, ColorFilterBlendMode.none);
      expect(settings.disableSectionType, SectionType.all);
      expect(settings.novelTextAlign, NovelTextAlign.left);
      expect(settings.debandingType, DebandingType.none);
      expect(settings.audioChannels, AudioChannel.autoSafe);
    });

    test('valid enum indices and numeric fields are preserved', () {
      final settings = Settings.fromJson(
        _json('''
{
  "displayType": 1,
  "defaultReaderMode": 2,
  "flexColorSchemeBlendLevel": 10,
  "defaultPlayBackSpeed": 1.5
}
'''),
      );

      expect(settings.displayType, DisplayType.comfortableGrid);
      expect(settings.defaultReaderMode, ReaderMode.rtl);
      expect(settings.flexColorSchemeBlendLevel, 10.0);
      expect(settings.defaultPlayBackSpeed, 1.5);
    });

    test('non-numeric blend level and playback speed become null', () {
      final settings = Settings.fromJson(
        _json('''
{
  "flexColorSchemeBlendLevel": "high",
  "defaultPlayBackSpeed": null
}
'''),
      );

      expect(settings.flexColorSchemeBlendLevel, isNull);
      expect(settings.defaultPlayBackSpeed, isNull);
    });

    test('nested personal modes tolerate missing, null, and invalid enums', () {
      final settings = Settings.fromJson(
        _json('''
{
  "personalReaderModeList": [
    {"mangaId": 1},
    {"mangaId": 2, "readerMode": null},
    {"mangaId": 3, "readerMode": 999},
    {"mangaId": 4, "readerMode": 1}
  ],
  "personalPageModeList": [
    {"mangaId": 1},
    {"mangaId": 2, "pageMode": null},
    {"mangaId": 3, "pageMode": 99},
    {"mangaId": 4, "pageMode": 1}
  ]
}
'''),
      );

      expect(settings.personalReaderModeList, hasLength(4));
      expect(settings.personalReaderModeList![0].readerMode, ReaderMode.vertical);
      expect(settings.personalReaderModeList![1].readerMode, ReaderMode.vertical);
      expect(settings.personalReaderModeList![2].readerMode, ReaderMode.vertical);
      expect(settings.personalReaderModeList![3].readerMode, ReaderMode.ltr);

      expect(settings.personalPageModeList, hasLength(4));
      expect(settings.personalPageModeList![0].pageMode, PageMode.onePage);
      expect(settings.personalPageModeList![1].pageMode, PageMode.onePage);
      expect(settings.personalPageModeList![2].pageMode, PageMode.onePage);
      expect(settings.personalPageModeList![3].pageMode, PageMode.doublePage);
    });
  });

  group('PersonalReaderMode.fromJson', () {
    test('missing, null, and out-of-range readerMode use vertical', () {
      expect(
        PersonalReaderMode.fromJson(_json('{"mangaId": 7}')).readerMode,
        ReaderMode.vertical,
      );
      expect(
        PersonalReaderMode.fromJson(
          _json('{"mangaId": 7, "readerMode": null}'),
        ).readerMode,
        ReaderMode.vertical,
      );
      expect(
        PersonalReaderMode.fromJson(
          _json('{"mangaId": 7, "readerMode": 99}'),
        ).readerMode,
        ReaderMode.vertical,
      );
    });
  });

  group('PersonalPageMode.fromJson', () {
    test('missing, null, and out-of-range pageMode use onePage', () {
      expect(
        PersonalPageMode.fromJson(_json('{"mangaId": 7}')).pageMode,
        PageMode.onePage,
      );
      expect(
        PersonalPageMode.fromJson(
          _json('{"mangaId": 7, "pageMode": null}'),
        ).pageMode,
        PageMode.onePage,
      );
      expect(
        PersonalPageMode.fromJson(
          _json('{"mangaId": 7, "pageMode": -1}'),
        ).pageMode,
        PageMode.onePage,
      );
    });
  });
}
