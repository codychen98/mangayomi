/// Safe, truncated strings for Mihon getVideoList diagnostics in logs.txt.

/// Collapse whitespace and cap length for response body previews.
String mihonResponseBodyPreview(String body, {int maxChars = 240}) {
  final collapsed = body.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (collapsed.isEmpty) return '(empty)';
  if (collapsed.length <= maxChars) return collapsed;
  return '${collapsed.substring(0, maxChars)}…(truncated,len=${collapsed.length})';
}

/// Compact `key=selectedValue` list for listPreferences in a Dalvik prefs payload.
String mihonListPreferenceLogSummary(List<Map<String, dynamic>> prefsPayload) {
  if (prefsPayload.isEmpty) return '(none)';
  final parts = <String>[];
  for (final pref in prefsPayload) {
    final key = pref['key']?.toString();
    final list = pref['listPreference'];
    if (key == null || list is! Map) continue;
    final selected = _selectedListValue(list);
    if (selected == null) {
      parts.add('$key=?');
    } else {
      parts.add('$key=$selected');
    }
  }
  if (parts.isEmpty) return '(no-list-prefs)';
  return parts.join(',');
}

String? _selectedListValue(Map list) {
  final index = list['valueIndex'];
  if (index is! int) return null;
  final entryValues = list['entryValues'];
  if (entryValues is List && index >= 0 && index < entryValues.length) {
    return entryValues[index]?.toString();
  }
  final entries = list['entries'];
  if (entries is List && index >= 0 && index < entries.length) {
    return entries[index]?.toString();
  }
  return null;
}
