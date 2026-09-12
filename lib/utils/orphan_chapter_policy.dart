/// Plain inputs for orphan delete selection (no Isar / Download models).
class OrphanChapterCandidate {
  const OrphanChapterCandidate({
    required this.id,
    required this.url,
    required this.isFullyDownloaded,
  });

  final int id;
  final String? url;

  /// True when [Download.isDownload] is true for this chapter.
  final bool isFullyDownloaded;
}

/// Trimmed non-empty URLs from a refreshed source chapter list.
Set<String> sourceUrlSet(Iterable<String?> urls) {
  return {
    for (final url in urls)
      if (url != null && url.trim().isNotEmpty) url.trim(),
  };
}

/// Whether [chapterUrl] is missing from the current source URL set.
///
/// Null/blank URLs are never treated as orphans (cannot match by URL safely).
bool isOrphanChapterUrl(String? chapterUrl, Set<String> sourceUrls) {
  final url = chapterUrl?.trim();
  if (url == null || url.isEmpty) return false;
  return !sourceUrls.contains(url);
}

/// Whether an existing chapter row should be deleted during a source sync.
///
/// Bookmarks are intentionally not an input — only a completed download keeps
/// an orphan offline. Pref off or an empty source list never deletes.
bool shouldDeleteOrphan({
  required bool isOrphan,
  required bool isFullyDownloaded,
  required bool removeMissingEnabled,
  required bool sourceListNonEmpty,
}) {
  if (!removeMissingEnabled) return false;
  if (!sourceListNonEmpty) return false;
  if (!isOrphan) return false;
  if (isFullyDownloaded) return false;
  return true;
}

/// Chapter ids to delete given plain existing rows and the refreshed URL set.
///
/// Returns a new list; does not mutate [existing].
List<int> chapterIdsToDeleteAsOrphans({
  required Iterable<OrphanChapterCandidate> existing,
  required Set<String> sourceUrls,
  required bool removeMissingEnabled,
}) {
  if (!removeMissingEnabled || sourceUrls.isEmpty) return const [];

  return [
    for (final chapter in existing)
      if (shouldDeleteOrphan(
        isOrphan: isOrphanChapterUrl(chapter.url, sourceUrls),
        isFullyDownloaded: chapter.isFullyDownloaded,
        removeMissingEnabled: true,
        sourceListNonEmpty: true,
      ))
        chapter.id,
  ];
}
