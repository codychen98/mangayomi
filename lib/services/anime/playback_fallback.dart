import 'package:mangayomi/models/video.dart';

/// Immutable state for open-failure fallback across an ordered candidate list.
class PlaybackFallbackState {
  const PlaybackFallbackState({
    required this.failedUrls,
    required this.attempts,
  });

  /// Stream URLs that failed to open (trimmed).
  final Set<String> failedUrls;

  /// Number of open failures recorded in this chain.
  final int attempts;

  static const empty = PlaybackFallbackState(failedUrls: {}, attempts: 0);

  /// Returns a new state with [url] (trimmed) marked failed.
  PlaybackFallbackState markFailed(String url) {
    final trimmed = url.trim();
    return PlaybackFallbackState(
      failedUrls: {...failedUrls, trimmed},
      attempts: attempts + 1,
    );
  }
}

/// Next candidate whose url is not in [state.failedUrls] and differs from
/// [currentUrl]; null when exhausted. Preserves [ordered] order.
///
/// URL comparison is exact string match after [String.trim]; no further
/// normalization (proxy URLs are opaque UUIDs).
Video? nextFallbackVideo(
  List<Video> ordered, {
  required String currentUrl,
  required PlaybackFallbackState state,
}) {
  final current = currentUrl.trim();
  for (final video in ordered) {
    final url = video.url.trim();
    if (url == current) continue;
    if (state.failedUrls.contains(url)) continue;
    return video;
  }
  return null;
}

/// Labels grouped by identical url when more than one label shares a url.
///
/// URLs are trimmed before grouping. Returns an empty map when every url is
/// unique (or appears only once).
Map<String, List<String>> duplicateStreamUrlLabels(List<Video> videos) {
  final byUrl = <String, List<String>>{};
  for (final video in videos) {
    final url = video.url.trim();
    final labels = byUrl.putIfAbsent(url, () => <String>[]);
    labels.add(video.quality);
  }
  return {
    for (final entry in byUrl.entries)
      if (entry.value.length > 1) entry.key: List<String>.unmodifiable(entry.value),
  };
}
