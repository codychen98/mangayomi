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

/// Resolves Mihon prefs from [Source.preferenceList], overlaying Isar saves.
///
/// Does not call [getSourcePreference] (avoids recursion through MihonService).
List<SourcePreference> resolveMihonSourcePreferences(Source source) {
  final preferenceList = source.preferenceList;
  if (preferenceList == null || preferenceList.isEmpty) {
    return const [];
  }
  try {
    final defaults = (jsonDecode(preferenceList) as List)
        .map((e) => SourcePreference.fromJson(e as Map<String, dynamic>))
        .toList();
    if (defaults.isEmpty) return const [];
    final sourceId = source.id;
    if (sourceId == null) return defaults;
    return mergeFetchedSourcePreferences(defaults, sourceId);
  } catch (_) {
    return const [];
  }
}

/// JSON maps for Dalvik [applyPreferences] (jsonEncode cannot encode models).
List<Map<String, dynamic>> mihonPreferencesDalvikPayload(Source source) {
  return resolveMihonSourcePreferences(
    source,
  ).map((e) => e.toJson()).toList();
}

/// Deep-copies a preference for Isar/JSON persist, keeping [valueIndex] explicit.
SourcePreference copyPreferenceForPersist(
  SourcePreference sourcePreference, {
  required int? sourceId,
  Id? id,
}) {
  final list = sourcePreference.listPreference;
  final multi = sourcePreference.multiSelectListPreference;
  final checkBox = sourcePreference.checkBoxPreference;
  final switchPref = sourcePreference.switchPreferenceCompat;
  final editText = sourcePreference.editTextPreference;

  return SourcePreference(
    id: id ?? Isar.autoIncrement,
    sourceId: sourceId,
    key: sourcePreference.key,
    checkBoxPreference: checkBox == null
        ? null
        : CheckBoxPreference(
            title: checkBox.title,
            summary: checkBox.summary,
            value: checkBox.value,
          ),
    switchPreferenceCompat: switchPref == null
        ? null
        : SwitchPreferenceCompat(
            title: switchPref.title,
            summary: switchPref.summary,
            value: switchPref.value,
          ),
    listPreference: list == null
        ? null
        : ListPreference(
            title: list.title,
            summary: list.summary,
            valueIndex: list.valueIndex,
            entries: list.entries == null
                ? null
                : List<String>.from(list.entries!),
            entryValues: list.entryValues == null
                ? null
                : List<String>.from(list.entryValues!),
          ),
    multiSelectListPreference: multi == null
        ? null
        : MultiSelectListPreference(
            title: multi.title,
            summary: multi.summary,
            entries: multi.entries == null
                ? null
                : List<String>.from(multi.entries!),
            entryValues: multi.entryValues == null
                ? null
                : List<String>.from(multi.entryValues!),
            values: multi.values == null
                ? null
                : List<String>.from(multi.values!),
          ),
    editTextPreference: editText == null
        ? null
        : EditTextPreference(
            title: editText.title,
            summary: editText.summary,
            value: editText.value,
            dialogTitle: editText.dialogTitle,
            dialogMessage: editText.dialogMessage,
            text: editText.text,
          ),
  );
}

/// Updates or appends [updated] in a Mihon `preferenceList` JSON array by key.
String mergePreferenceIntoPreferenceListJson(
  String preferenceListJson,
  SourcePreference updated,
) {
  final prefs = (jsonDecode(preferenceListJson) as List)
      .map((e) => SourcePreference.fromJson(e as Map<String, dynamic>))
      .toList();
  final idx = prefs.indexWhere((e) => e.key == updated.key);
  // Prefer null id in preferenceList JSON so reloads do not reuse Isar ids.
  final withoutId = copyPreferenceForPersist(
    updated,
    sourceId: updated.sourceId,
  )..id = null;

  if (idx != -1) {
    prefs[idx] = withoutId;
  } else {
    prefs.add(withoutId);
  }
  return jsonEncode(prefs.map((e) => e.toJson()).toList());
}

void setPreferenceSetting(SourcePreference sourcePreference, Source source) {
  final matchingPrefs = isar.sourcePreferences
      .filter()
      .sourceIdEqualTo(source.id)
      .keyEqualTo(sourcePreference.key)
      .findAllSync();
  matchingPrefs.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));
  final existingId = matchingPrefs.isNotEmpty ? matchingPrefs.first.id : null;

  final persistedPreference = copyPreferenceForPersist(
    sourcePreference,
    sourceId: source.id,
    id: existingId,
  );

  isar.writeTxnSync(() {
    for (final duplicate in matchingPrefs) {
      if (duplicate.id != null && duplicate.id != existingId) {
        isar.sourcePreferences.deleteSync(duplicate.id!);
      }
    }
    isar.sourcePreferences.putSync(persistedPreference);

    final dbSource = source.id != null ? isar.sources.getSync(source.id!) : null;
    if (dbSource != null) {
      if (source.sourceCodeLanguage == SourceCodeLanguage.mihon &&
          dbSource.preferenceList != null &&
          dbSource.preferenceList!.isNotEmpty) {
        dbSource.preferenceList = mergePreferenceIntoPreferenceListJson(
          dbSource.preferenceList!,
          persistedPreference,
        );
      }
      // Any extension language: bump so WebDAV LWW can sync this device's change.
      dbSource.updatedAt = DateTime.now().millisecondsSinceEpoch;
      isar.sources.putSync(dbSource);
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
  // Return defaults without writing them — avoids clobbering a good Isar /
  // preferenceList row via delete-all re-seed on read.
  return copyPreferenceForPersist(
    sourcePreference,
    sourceId: sourceId,
  )..id = null;
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
    setSourcePreferenceStringValue(
      sourceId,
      key,
      defaultValue,
      bumpSourceUpdatedAt: false,
    );
    return defaultValue;
  }

  return sourcePreferenceStringValue.value ?? "";
}

void setSourcePreferenceStringValue(
  int sourceId,
  String key,
  String value, {
  bool bumpSourceUpdatedAt = true,
}) {
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
    if (bumpSourceUpdatedAt) {
      final dbSource = isar.sources.getSync(sourceId);
      if (dbSource != null) {
        isar.sources.putSync(
          dbSource..updatedAt = DateTime.now().millisecondsSinceEpoch,
        );
      }
    }
  });
}
