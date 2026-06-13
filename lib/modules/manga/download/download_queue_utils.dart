import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/chapter.dart';
import 'package:mangayomi/models/download.dart';
import 'package:mangayomi/utils/chapter_recognition.dart';
import 'package:mangayomi/utils/extensions/manga_extensions.dart';

/// Maximum download attempts before an item is skipped (but kept visible).
const int kMaxDownloadAttempts = 3;

bool isDownloadSkipped(Download download) =>
    (download.failed ?? 0) >= kMaxDownloadAttempts;

/// Whether [chapter] should be added to the download queue, applying
/// duplicate-episode deduplication for the parent manga.
bool shouldAddChapterToQueue(Chapter chapter) {
  final manga = chapter.manga.value;
  if (manga == null || chapter.id == null) return false;

  final existing = isar.downloads.getSync(chapter.id!);
  if (existing != null) return false;

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
    if (download?.isDownload == true) return false;

    if (download != null &&
        download.isStartDownload == true &&
        !isDownloadSkipped(download)) {
      return false;
    }

    representative ??= candidate;
  }

  return representative?.id == chapter.id;
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
