import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/chapter.dart';
import 'package:mangayomi/models/download.dart';
import 'package:mangayomi/utils/chapter_recognition.dart';
import 'package:mangayomi/utils/extensions/manga_extensions.dart';
import 'package:mangayomi/utils/log/logger.dart';

/// Maximum download attempts before an item is skipped (but kept visible).
const int kMaxDownloadAttempts = 3;

String downloadLogContext(Chapter chapter) {
  final mangaName = chapter.manga.value?.name ?? 'unknown';
  return 'manga="$mangaName" chapterId=${chapter.id} '
      'episode="${chapter.name ?? 'unknown'}"';
}

void logDownloadQueueEvent(
  String event,
  Chapter chapter, {
  String? reason,
  String? detail,
  LogLevel logLevel = LogLevel.info,
}) {
  final buffer = StringBuffer('[$event] ${downloadLogContext(chapter)}');
  if (reason != null) {
    buffer.write(' reason=$reason');
  }
  if (detail != null) {
    buffer.write(' $detail');
  }
  AppLogger.log(buffer.toString(), logLevel: logLevel);
}

bool isDownloadSkipped(Download download) =>
    (download.failed ?? 0) >= kMaxDownloadAttempts;

/// Loads chapter and manga Isar links on [download].
///
/// [IsarLink.value] is null until loaded; callers must use this before
/// reading links from watch/findAll results.
void loadDownloadLinks(Download download) {
  if (!download.chapter.isLoaded) {
    download.chapter.loadSync();
  }
  final chapter = download.chapter.value;
  if (chapter != null && !chapter.manga.isLoaded) {
    chapter.manga.loadSync();
  }
}

/// True when the linked chapter or parent manga was deleted from the DB.
bool isOrphanDownload(Download download) {
  loadDownloadLinks(download);
  return download.chapter.value == null ||
      download.chapter.value?.manga.value == null;
}

/// Incomplete queue rows (`isDownload == false`, `isStartDownload == true`).
List<Download> getPendingQueueDownloads() {
  return isar.downloads
      .filter()
      .idIsNotNull()
      .isDownloadEqualTo(false)
      .isStartDownloadEqualTo(true)
      .findAllSync();
}

/// Whether [processDownloads] has at least one item it can attempt.
bool hasAutoResumableDownloads() {
  for (final download in getPendingQueueDownloads()) {
    if (isOrphanDownload(download)) continue;
    if (!isDownloadSkipped(download)) return true;
  }
  return false;
}

/// Whether [chapter] should be added to the download queue, applying
/// duplicate-episode deduplication for the parent manga.
bool shouldAddChapterToQueue(Chapter chapter) {
  final manga = chapter.manga.value;
  if (manga == null || chapter.id == null) {
    logDownloadQueueEvent('DEDUP_SKIP', chapter, reason: 'invalid_chapter');
    return false;
  }

  final existing = isar.downloads.getSync(chapter.id!);
  if (existing != null) {
    logDownloadQueueEvent('DEDUP_SKIP', chapter, reason: 'already_in_queue');
    return false;
  }

  final recognition = ChapterRecognition();
  final mangaTitle = manga.name ?? '';
  final episodeNumber = recognition.parseChapterNumber(
    mangaTitle,
    chapter.name ?? '',
  );

  if (episodeNumber <= 0) return true;

  final sortedChapters = manga.getSortedFilteredChapters();
  Chapter? representative;
  for (final candidate in sortedChapters) {
    if (candidate.id == null) continue;
    if (recognition.parseChapterNumber(mangaTitle, candidate.name ?? '') !=
        episodeNumber) {
      continue;
    }

    final download = isar.downloads.getSync(candidate.id!);
    if (download?.isDownload == true) {
      logDownloadQueueEvent(
        'DEDUP_SKIP',
        chapter,
        reason: 'already_downloaded',
        detail: 'episodeNumber=$episodeNumber',
      );
      return false;
    }

    if (download != null &&
        download.isStartDownload == true &&
        !isDownloadSkipped(download)) {
      logDownloadQueueEvent(
        'DEDUP_SKIP',
        chapter,
        reason: 'already_queued',
        detail: 'episodeNumber=$episodeNumber',
      );
      return false;
    }

    representative ??= candidate;
  }

  if (representative?.id != chapter.id) {
    logDownloadQueueEvent(
      'DEDUP_SKIP',
      chapter,
      reason: 'not_representative',
      detail:
          'episodeNumber=$episodeNumber representativeId=${representative?.id}',
    );
    return false;
  }

  return true;
}

void recordDownloadAttempt(
  int chapterId, {
  required bool permanentFailure,
}) {
  final download = isar.downloads.getSync(chapterId);
  if (download == null) return;

  final nextAttempts = permanentFailure
      ? kMaxDownloadAttempts
      : ((download.failed ?? 0) + 1).clamp(0, kMaxDownloadAttempts);

  isar.writeTxnSync(() {
    isar.downloads.putSync(
      download
        ..failed = nextAttempts
        ..isDownload = false
        ..isStartDownload = true
        ..succeeded = 0,
    );
  });
}

void resetDownloadAttempts(int chapterId) {
  final download = isar.downloads.getSync(chapterId);
  if (download == null) return;

  isar.writeTxnSync(() {
    isar.downloads.putSync(
      download
        ..failed = 0
        ..succeeded = 0,
    );
  });
}
