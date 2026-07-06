import 'dart:convert';

import 'package:isar_community/isar.dart';
import 'package:mangayomi/eval/model/source_preference.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/services/get_source_preference.dart';

List<SourcePreference>? loadSourcePreferencesForSource(Source source) {
  try {
    final List<SourcePreference> defaults;
    if (source.sourceCodeLanguage == SourceCodeLanguage.mihon &&
        source.preferenceList != null) {
      defaults = (jsonDecode(source.preferenceList!) as List)
          .map((e) => SourcePreference.fromJson(e))
          .toList();
    } else {
      defaults = getSourcePreference(source: source);
    }
    if (defaults.isEmpty) return null;
    return defaults
        .map((e) => getSourcePreferenceEntry(e.key!, source.id!))
        .toList();
  } catch (_) {
    return null;
  }
}

List<SourcePreference> mergeFetchedSourcePreferences(
  List<SourcePreference> fetched,
  int sourceId,
) {
  return fetched.map((pref) {
    final matches = isar.sourcePreferences
        .filter()
        .sourceIdEqualTo(sourceId)
        .keyEqualTo(pref.key)
        .findAllSync();
    if (matches.isEmpty) return pref;
    matches.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    return matches.first;
  }).toList();
}

void setPreferenceSetting(SourcePreference sourcePreference, Source source) {
  final matchingPrefs = isar.sourcePreferences
      .filter()
      .sourceIdEqualTo(source.id)
      .keyEqualTo(sourcePreference.key)
      .findAllSync();

  final persistedPreference = SourcePreference.fromJson(
    sourcePreference.toJson(),
  )..sourceId = source.id;

  isar.writeTxnSync(() {
    for (final duplicate in matchingPrefs) {
      if (duplicate.id != null) {
        isar.sourcePreferences.deleteSync(duplicate.id!);
      }
    }
    isar.sourcePreferences.putSync(persistedPreference);

    if (source.sourceCodeLanguage == SourceCodeLanguage.mihon) {
      final dbSource = isar.sources.getSync(source.id!);
      if (dbSource?.preferenceList != null) {
        final prefs = (jsonDecode(dbSource!.preferenceList!) as List)
            .map((e) => SourcePreference.fromJson(e))
            .toList();
        final idx = prefs.indexWhere((e) => e.key == sourcePreference.key);
        if (idx != -1) {
          prefs[idx] = SourcePreference.fromJson(sourcePreference.toJson())
            ..sourceId = source.id;
          isar.sources.putSync(
            dbSource
              ..preferenceList = jsonEncode(
                prefs.map((e) => e.toJson()).toList(),
              ),
          );
        }
      }
    }
  });
}

dynamic getPreferenceValue(int sourceId, String key) {
  final sourcePreference = getSourcePreferenceEntry(key, sourceId);

  if (sourcePreference.listPreference != null) {
    final pref = sourcePreference.listPreference!;
    return pref.entryValues![pref.valueIndex!];
  } else if (sourcePreference.checkBoxPreference != null) {
    return sourcePreference.checkBoxPreference!.value;
  } else if (sourcePreference.switchPreferenceCompat != null) {
    return sourcePreference.switchPreferenceCompat!.value;
  } else if (sourcePreference.editTextPreference != null) {
    return sourcePreference.editTextPreference!.value;
  }
  return sourcePreference.multiSelectListPreference!.values;
}

SourcePreference getSourcePreferenceEntry(String key, int sourceId) {
  final matchingPreferences = isar.sourcePreferences
      .filter()
      .sourceIdEqualTo(sourceId)
      .keyEqualTo(key)
      .findAllSync();
  if (matchingPreferences.isNotEmpty) {
    matchingPreferences.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
    return matchingPreferences.first;
  }

  final source = isar.sources.getSync(sourceId)!;
  final sourcePreference = getSourcePreference(source: source).firstWhere(
    (element) => element.key == key,
    orElse: () => throw "Error when getting source preference",
  );
  setPreferenceSetting(sourcePreference, source);
  return getSourcePreferenceEntry(key, sourceId);
}

String getSourcePreferenceStringValue(
  int sourceId,
  String key,
  String defaultValue,
) {
  SourcePreferenceStringValue? sourcePreferenceStringValue = isar
      .sourcePreferenceStringValues
      .filter()
      .sourceIdEqualTo(sourceId)
      .keyEqualTo(key)
      .findFirstSync();
  if (sourcePreferenceStringValue == null) {
    setSourcePreferenceStringValue(sourceId, key, defaultValue);
    return defaultValue;
  }

  return sourcePreferenceStringValue.value ?? "";
}

void setSourcePreferenceStringValue(int sourceId, String key, String value) {
  final sourcePref = isar.sourcePreferenceStringValues
      .filter()
      .sourceIdEqualTo(sourceId)
      .keyEqualTo(key)
      .findFirstSync();
  isar.writeTxnSync(() {
    if (sourcePref != null) {
      isar.sourcePreferenceStringValues.putSync(sourcePref..value = value);
    } else {
      isar.sourcePreferenceStringValues.putSync(
        SourcePreferenceStringValue()
          ..key = key
          ..sourceId = sourceId
          ..value = value,
      );
    }
  });
}
