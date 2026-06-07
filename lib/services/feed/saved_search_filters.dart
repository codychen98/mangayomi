import 'dart:convert';

import 'package:mangayomi/eval/model/filter.dart';

String? serializeSavedSearchFilters(List<dynamic> filters) {
  if (filters.isEmpty) return null;
  return jsonEncode(FilterList(filters).toJson());
}

List<dynamic> deserializeSavedSearchFilters(String? filtersJson) {
  if (filtersJson == null || filtersJson.isEmpty) return [];
  try {
    final decoded = jsonDecode(filtersJson);
    if (decoded is Map<String, dynamic> && decoded['builtin'] != null) {
      return [];
    }
    if (decoded is! Map<String, dynamic>) return [];
    return FilterList.fromJson(decoded).filters;
  } catch (_) {
    return [];
  }
}
