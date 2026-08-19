import 'package:isar_community/isar.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/utils/log/logger.dart';

bool _hasSourceCode(Source source) =>
    source.sourceCode != null && source.sourceCode!.isNotEmpty;

/// Picks a source from an in-memory list. ID wins even when [Source.sourceCode]
/// is still null or empty; name+lang is only used when [sourceId] does not match.
Source? selectSource(
  List<Source> sources, {
  required String lang,
  required String name,
  int? sourceId,
}) {
  if (sourceId != null) {
    Source? byIdWithoutCode;
    for (final source in sources) {
      if (source.id != sourceId) continue;
      if (_hasSourceCode(source)) return source;
      byIdWithoutCode ??= source;
    }
    if (byIdWithoutCode != null) return byIdWithoutCode;
  }

  final nameLower = name.toLowerCase();
  for (final source in sources) {
    if (source.name?.toLowerCase() == nameLower &&
        source.lang == lang &&
        _hasSourceCode(source)) {
      return source;
    }
  }
  return null;
}

Source? getSource(
  String lang,
  String name,
  int? sourceId, {
  bool installedOnly = false,
}) {
  try {
    var sourcesFilter = isar.sources.filter().idIsNotNull();
    if (installedOnly) {
      sourcesFilter = sourcesFilter.isActiveEqualTo(true).isAddedEqualTo(true);
    }
    final sourcesList = sourcesFilter.findAllSync();
    final selected = selectSource(
      sourcesList,
      lang: lang,
      name: name,
      sourceId: sourceId,
    );
    if (selected != null &&
        name.isNotEmpty &&
        selected.name != null &&
        selected.name!.toLowerCase() != name.toLowerCase()) {
      AppLogger.log(
        '[SOURCE] mismatch requested=$name id=$sourceId '
        'resolved=${selected.name} base=${selected.baseUrl} '
        'hasCode=${selected.sourceCode != null && selected.sourceCode!.isNotEmpty}',
      );
    }
    return selected;
  } catch (_) {
    return null;
  }
}
