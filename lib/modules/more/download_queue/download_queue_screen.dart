import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:isar_community/isar.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/chapter.dart';
import 'package:mangayomi/models/download.dart';
import 'package:mangayomi/modules/manga/detail/widgets/custom_floating_action_btn.dart';
import 'package:mangayomi/modules/manga/download/download_queue_utils.dart';
import 'package:mangayomi/modules/manga/download/providers/download_provider.dart';
import 'package:mangayomi/providers/l10n_providers.dart';
import 'package:mangayomi/utils/extensions/chapter_extensions.dart';
import 'package:mangayomi/utils/global_style.dart';
import 'package:mangayomi/utils/log/logger.dart';

class DownloadQueueScreen extends ConsumerWidget {
  const DownloadQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = l10nLocalizations(context);
    return StreamBuilder(
      stream: isar.downloads
          .filter()
          .idIsNotNull()
          .isDownloadEqualTo(false)
          .isStartDownloadEqualTo(true)
          .sortBySucceededDesc()
          .watch(fireImmediately: true),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final allEntries = snapshot.data!;
          final entries = <Download>[];
          var orphanCount = 0;
          for (final d in allEntries) {
            if (isOrphanDownload(d)) {
              orphanCount++;
              continue;
            }
            entries.add(d);
          }
          if (orphanCount > 0) {
            logDownloadQueueMessage(
              'QUEUE_UI_ORPHAN_SKIP',
              detail: 'hidden=$orphanCount (not deleted from UI)',
              logLevel: LogLevel.warning,
            );
          }
          if (entries.isEmpty) {
            return Scaffold(
              appBar: AppBar(title: Text(l10n!.download_queue)),
              body: Center(child: Text(l10n.no_downloads)),
            );
          }
          final allQueueLength = entries.length;
          var activeCount = 0;
          var waitingCount = 0;
          var failedCount = 0;
          for (final entry in entries) {
            if (isDownloadSkipped(entry)) {
              failedCount++;
            } else if ((entry.succeeded ?? 0) > 0) {
              activeCount++;
            } else {
              waitingCount++;
            }
          }
          return Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Text(l10n!.download_queue),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Badge(
                      backgroundColor: Theme.of(context).focusColor,
                      label: Text(
                        allQueueLength.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall!.color,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(28),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$activeCount active · $waitingCount waiting · '
                      '$failedCount failed',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ),
            ),
            body: GroupedListView<Download, String>(
              elements: entries,
              groupBy: (element) =>
                  resolveDownloadManga(element)?.source ?? "",
              groupSeparatorBuilder: (String groupByValue) {
                final sourceQueueLength = entries
                    .where(
                      (element) =>
                          (resolveDownloadManga(element)?.source ?? "") ==
                          groupByValue,
                    )
                    .toList()
                    .length;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6, left: 12),
                  child: Text('$groupByValue ($sourceQueueLength)'),
                );
              },
              itemBuilder: (context, Download element) {
                final chapter = resolveDownloadChapter(element);
                final manga = resolveDownloadManga(element);
                final skipped = isDownloadSkipped(element);
                final attempts = element.failed ?? 0;
                final statusLabel = skipped
                    ? l10n.failed
                    : attempts > 0
                    ? '${l10n.failed} ($attempts/$kMaxDownloadAttempts)'
                    : '${element.succeeded}/${element.total}';

                return SizedBox(
                  height: 60,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.drag_handle),
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  manga?.name ?? "",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: skipped
                                        ? Theme.of(context).colorScheme.error
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              chapter?.name ?? "",
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              tween: Tween<double>(
                                begin: 0,
                                end: skipped
                                    ? 1
                                    : element.succeeded! / element.total!,
                              ),
                              builder: (context, value, _) =>
                                  LinearProgressIndicator(
                                    value: value,
                                    color: skipped
                                        ? Theme.of(context).colorScheme.error
                                        : null,
                                    backgroundColor: skipped
                                        ? Theme.of(context)
                                              .colorScheme
                                              .error
                                              .withValues(alpha: 0.2)
                                        : null,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PopupMenuButton(
                          popUpAnimationStyle: popupAnimationStyle,
                          child: const Icon(Icons.more_vert),
                          onSelected: (value) async {
                            if (value.toString() == 'Retry') {
                              if (element.id != null) {
                                resetDownloadAttempts(element.id!);
                                ref.read(processDownloadsProvider());
                              }
                            } else if (value.toString() == 'Cancel') {
                              if (chapter != null) {
                                chapter.cancelDownloads(
                                  element.id!,
                                );
                              } else {
                                isar.writeTxnSync(() {
                                  isar.downloads.deleteSync(element.id!);
                                });
                              }
                            } else if (value.toString() == 'CancelAll') {
                              final a = entries
                                  .where(
                                    (e) =>
                                        '${resolveDownloadManga(e)?.name}' ==
                                            '${manga?.name}' &&
                                        '${resolveDownloadManga(e)?.source}' ==
                                            '${manga?.source}',
                                  )
                                  .map(
                                    (e) => (
                                      e.id,
                                      resolveDownloadChapter(e)?.id,
                                    ),
                                  )
                                  .toList();
                              for (var ids in a) {
                                final (downloadId, chapterId) = ids;
                                final chapter = isar.chapters.getSync(
                                  chapterId!,
                                );
                                chapter?.cancelDownloads(downloadId!);
                              }
                            } else if (value.toString() == 'CancelAllDownloads') {
                              _cancelAllDownloads(entries);
                            }
                          },
                          itemBuilder: (context) => [
                            if (skipped)
                              PopupMenuItem(
                                value: 'Retry',
                                child: Text(l10n.retry),
                              ),
                            PopupMenuItem(
                              value: 'Cancel',
                              child: Text(l10n.cancel),
                            ),
                            PopupMenuItem(
                              value: 'CancelAll',
                              child: Text(l10n.cancel_all_for_this_series),
                            ),
                            PopupMenuItem(
                              value: 'CancelAllDownloads',
                              child: Text(l10n.cancel_all_downloads),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              itemComparator: (item1, item2) =>
                  (resolveDownloadManga(item1)?.source ?? "").compareTo(
                    resolveDownloadManga(item2)?.source ?? "",
                  ),
              order: GroupedListOrder.DESC,
            ),
            floatingActionButton: CustomFloatingActionBtn(
              isExtended: false,
              label: l10n.download_queue,
              onPressed: () {
                ref.read(processDownloadsProvider());
              },
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(l10n!.download_queue)),
          body: Center(child: Text(l10n.no_downloads)),
        );
      },
    );
  }

  void _cancelAllDownloads(List<Download> entries) {
    for (final entry in entries) {
      final chapter = resolveDownloadChapter(entry);
      if (chapter != null && entry.id != null) {
        chapter.cancelDownloads(entry.id!);
      }
    }
  }

  Size measureText(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.size;
  }

  double calculateDynamicButtonWidth(
    String text,
    TextStyle textStyle,
    double padding,
  ) {
    final textSize = measureText(text, textStyle);
    return textSize.width + padding;
  }
}
