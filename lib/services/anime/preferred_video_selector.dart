import 'package:mangayomi/eval/model/source_preference.dart';
import 'package:mangayomi/models/video.dart';

/// Weights for ranking [Video.quality] labels against extension prefs.
const int _typeScore = 1000;
const int _serverScore = 100;
const int _qualityScore = 10;
const int _localhostPenalty = 1;

/// Preferred Type / Server / Quality tokens resolved from extension list prefs.
class PreferredStreamTokens {
  const PreferredStreamTokens({this.type, this.server, this.quality});

  final String? type;
  final String? server;
  final String? quality;

  bool get hasAny =>
      (type != null && type!.trim().isNotEmpty) ||
      (server != null && server!.trim().isNotEmpty) ||
      (quality != null && quality!.trim().isNotEmpty);
}

/// Reads list-pref values by key/title (Anikoto-style and similar Mihon sources).
///
/// Prefers [ListPreference.entryValues] at [ListPreference.valueIndex], else
/// [ListPreference.entries]. Does not hardcode a single extension.
PreferredStreamTokens resolvePreferredStreamTokens(
  List<SourcePreference> preferences,
) {
  return PreferredStreamTokens(
    type: _listPrefSelectedValue(
      preferences,
      keyNorms: const {'preferredtype'},
      titleNorms: const {'preferredtype'},
    ),
    server: _listPrefSelectedValue(
      preferences,
      keyNorms: const {'preferredserver'},
      titleNorms: const {'preferredserver'},
    ),
    quality: _listPrefSelectedValue(
      preferences,
      keyNorms: const {'preferredquality'},
      titleNorms: const {'preferredquality'},
    ),
  );
}

String? _listPrefSelectedValue(
  List<SourcePreference> preferences, {
  required Set<String> keyNorms,
  required Set<String> titleNorms,
}) {
  for (final pref in preferences) {
    final list = pref.listPreference;
    if (list == null) continue;
    final keyOk = keyNorms.contains(_normalizeToken(pref.key ?? ''));
    final titleOk = titleNorms.contains(_normalizeToken(list.title ?? ''));
    if (!keyOk && !titleOk) continue;
    final index = list.valueIndex ?? 0;
    final values = list.entryValues;
    if (values != null && index >= 0 && index < values.length) {
      final v = values[index].trim();
      if (v.isNotEmpty) return v;
    }
    final entries = list.entries;
    if (entries != null && index >= 0 && index < entries.length) {
      final v = entries[index].trim();
      if (v.isNotEmpty) return v;
    }
  }
  return null;
}

/// Returns [videos] ordered best-match-first for optional preferred tokens.
///
/// Does not mutate [videos]. When all prefs are null/empty, returns a copy of
/// the original order. Ties preserve relative input order (stable).
List<Video> sortVideosByPreference(
  List<Video> videos, {
  String? preferredType,
  String? preferredServer,
  String? preferredQuality,
}) {
  if (videos.isEmpty) return const [];
  if (!_hasAnyPref(preferredType, preferredServer, preferredQuality)) {
    return List<Video>.from(videos);
  }

  final indexed = <({int index, Video video, int score})>[
    for (var i = 0; i < videos.length; i++)
      (
        index: i,
        video: videos[i],
        score: scoreVideoPreference(
          videos[i],
          preferredType: preferredType,
          preferredServer: preferredServer,
          preferredQuality: preferredQuality,
        ),
      ),
  ];

  indexed.sort((a, b) {
    final byScore = b.score.compareTo(a.score);
    if (byScore != 0) return byScore;
    return a.index.compareTo(b.index);
  });

  return [for (final e in indexed) e.video];
}

/// Best match under [sortVideosByPreference], or null if [videos] is empty.
Video? pickPreferredVideo(
  List<Video> videos, {
  String? preferredType,
  String? preferredServer,
  String? preferredQuality,
}) {
  final sorted = sortVideosByPreference(
    videos,
    preferredType: preferredType,
    preferredServer: preferredServer,
    preferredQuality: preferredQuality,
  );
  if (sorted.isEmpty) return null;
  return sorted.first;
}

/// Higher is better. Used by [sortVideosByPreference].
int scoreVideoPreference(
  Video video, {
  String? preferredType,
  String? preferredServer,
  String? preferredQuality,
}) {
  final label = video.quality;
  final parts = _splitQualityLabel(label);
  var score = 0;

  final typePref = preferredType?.trim();
  if (typePref != null && typePref.isNotEmpty) {
    final labelType = parts.type ?? label;
    if (_typesMatch(typePref, labelType)) {
      score += _typeScore;
    }
  }

  final serverPref = preferredServer?.trim();
  if (serverPref != null && serverPref.isNotEmpty) {
    final labelServer = parts.server ?? label;
    if (_serversMatch(serverPref, labelServer)) {
      score += _serverScore;
    }
  }

  final qualityPref = preferredQuality?.trim();
  if (qualityPref != null && qualityPref.isNotEmpty) {
    final labelQuality = parts.resolution ?? label;
    if (_qualitiesMatch(qualityPref, labelQuality)) {
      score += _qualityScore;
    }
  }

  if (_isLocalhostPlaceholder(video.url) ||
      _isLocalhostPlaceholder(video.originalUrl)) {
    score -= _localhostPenalty;
  }

  return score;
}

bool _hasAnyPref(String? type, String? server, String? quality) {
  return (type != null && type.trim().isNotEmpty) ||
      (server != null && server.trim().isNotEmpty) ||
      (quality != null && quality.trim().isNotEmpty);
}

({String? server, String? type, String? resolution}) _splitQualityLabel(
  String quality,
) {
  final parts = quality
      .split(' - ')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
  if (parts.length >= 3) {
    return (server: parts[0], type: parts[1], resolution: parts[2]);
  }
  if (parts.length == 2) {
    return (server: parts[0], type: parts[1], resolution: null);
  }
  if (parts.length == 1) {
    return (server: parts[0], type: null, resolution: null);
  }
  return (server: null, type: null, resolution: null);
}

String _normalizeToken(String raw) {
  return raw.toLowerCase().replaceAll(RegExp(r'[\s\-_]+'), '');
}

/// Maps Anikoto-style prefs / label tokens to a type family.
String? _typeFamily(String raw) {
  final n = _normalizeToken(raw);
  if (n.isEmpty) return null;
  if (n == 'hsub' || n == 'hardsub' || n == 'hard') return 'hsub';
  if (n == 'sub' || n == 'softsub') return 'sub';
  if (n == 'adub') return 'adub';
  if (n == 'dub') return 'dub';
  return n;
}

bool _typesMatch(String preferred, String labelType) {
  final prefFamily = _typeFamily(preferred);
  final labelFamily = _typeFamily(labelType);
  if (prefFamily == null || labelFamily == null) return false;
  return prefFamily == labelFamily;
}

bool _serversMatch(String preferred, String labelServer) {
  return _normalizeToken(preferred) == _normalizeToken(labelServer);
}

bool _qualitiesMatch(String preferred, String labelQuality) {
  final pref = _normalizeToken(preferred);
  final label = _normalizeToken(labelQuality);
  if (pref.isEmpty || label.isEmpty) return false;
  return label == pref || label.contains(pref) || pref.contains(label);
}

bool _isLocalhostPlaceholder(String url) {
  final lower = url.toLowerCase();
  return lower.contains('localhost') && lower.contains('m3u8');
}
