import 'package:mangayomi/models/sync_preference.dart';

/// Serializes sync preferences for local backup export.
///
/// [includeSensitive] must be true (backup index `8`) to include
/// [SyncPreference.authToken] and [SyncPreference.webDavPassword].
List<Map<String, dynamic>> exportSyncPreferencesForBackup(
  Iterable<SyncPreference> prefs, {
  required bool includeSensitive,
}) {
  return prefs.map((pref) {
    final json = pref.toJson();
    if (!includeSensitive) {
      json['authToken'] = null;
      json['webDavPassword'] = null;
    }
    return json;
  }).toList();
}

/// Merges restored sync preferences with existing local values.
///
/// When the backup omitted sensitive fields, local passwords/tokens are kept.
SyncPreference mergeSyncPreferenceFromBackup(
  SyncPreference incoming,
  SyncPreference? existing,
) {
  if (existing == null) {
    return incoming;
  }

  final merged = SyncPreference.fromJson(incoming.toJson());
  merged.syncId ??= existing.syncId;

  if (_isNullOrEmpty(merged.authToken)) {
    merged.authToken = existing.authToken;
  }
  if (_isNullOrEmpty(merged.webDavPassword)) {
    merged.webDavPassword = existing.webDavPassword;
  }

  return merged;
}

bool _isNullOrEmpty(String? value) => value == null || value.isEmpty;
