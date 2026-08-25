import 'dart:async';
import 'dart:io';
import 'package:mangayomi/eval/model/source_preference.dart';
import 'package:mangayomi/models/chapter.dart';
import 'package:mangayomi/models/video.dart';
import 'package:mangayomi/modules/browse/extension/providers/extension_preferences_providers.dart';
import 'package:mangayomi/modules/more/settings/browse/providers/browse_state_provider.dart';
import 'package:mangayomi/providers/storage_provider.dart';
import 'package:mangayomi/services/anime/preferred_video_selector.dart';
import 'package:mangayomi/services/isolate_service.dart';
import 'package:mangayomi/services/torrent_server.dart';
import 'package:mangayomi/utils/extensions/string_extensions.dart';
import 'package:mangayomi/utils/log/logger.dart';
import 'package:mangayomi/utils/utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path/path.dart' as p;

import '../models/source.dart';
part 'get_video_list.g.dart';

List<SourcePreference> _sourcePreferencesForStreamSelect(Source source) {
  if (source.sourceCodeLanguage == SourceCodeLanguage.mihon) {
    return resolveMihonSourcePreferences(source);
  }
  try {
    return loadSourcePreferencesForSource(source) ?? const [];
  } catch (_) {
    return const [];
  }
}

/// Reorders [videos] using extension Preferred Type / Server / Quality.
List<Video> _applyPreferredStreamOrder(List<Video> videos, Source? source) {
  if (source == null || videos.length <= 1) return videos;
  final tokens = resolvePreferredStreamTokens(
    _sourcePreferencesForStreamSelect(source),
  );
  if (!tokens.hasAny) return videos;

  final sorted = sortVideosByPreference(
    videos,
    preferredType: tokens.type,
    preferredServer: tokens.server,
    preferredQuality: tokens.quality,
  );
  AppLogger.log(
    '[VIDEO] preferred stream source=${source.name} '
    'type=${tokens.type} server=${tokens.server} quality=${tokens.quality} '
    'chosen=${sorted.isEmpty ? "(none)" : sorted.first.quality}',
  );
  return sorted;
}

@riverpod
Future<(List<Video>, bool, List<String>, Directory?)> getVideoList(
  Ref ref, {
  required Chapter episode,
}) async {
  (List<Video>, bool, List<String>, Directory?) result;
  final keepAlive = ref.keepAlive();
  try {
    final storageProvider = StorageProvider();
    final mpvDirectory = await storageProvider.getMpvDirectory();
    final mangaDirectory = await storageProvider.getMangaMainDirectory(episode);
    final isLocalArchive =
        episode.manga.value!.isLocalArchive! &&
        episode.manga.value!.source != "torrent";
    final mp4animePath = p.join(
      mangaDirectory!.path,
      "${episode.name!.replaceForbiddenCharacters(' ')}.mp4",
    );
    List<String> infoHashes = [];
    if (await File(mp4animePath).exists() || isLocalArchive) {
      final animeDir =
          episode.archivePath != null && episode.manga.value?.source == "local"
          ? Directory(p.dirname(episode.archivePath!))
          : null;
      final chapterDirectory = (await storageProvider.getMangaChapterDirectory(
        episode,
        mangaMainDirectory: animeDir ?? mangaDirectory,
      ))!;
      final path = isLocalArchive ? episode.archivePath : mp4animePath;
      final subtitlesDir = Directory(
        p.join('${chapterDirectory.path}_subtitles'),
      );
      List<Track> subtitles = [];
      if (subtitlesDir.existsSync()) {
        for (var element in subtitlesDir.listSync()) {
          if (element is File) {
            final subtitle = Track(
              label: element.uri.pathSegments.last.replaceAll('.srt', ''),
              file: element.uri.toString(),
            );
            subtitles.add(subtitle);
          }
        }
      }
      keepAlive.close();
      return (
        [Video(path!, episode.name!, path, subtitles: subtitles)],
        true,
        infoHashes,
        mpvDirectory,
      );
    }
    final source = getSource(
      episode.manga.value!.lang!,
      episode.manga.value!.source!,
      episode.manga.value!.sourceId,
    );
    final proxyServer = ref.read(androidProxyServerStateProvider);

    final isMihonTorrent =
        source?.sourceCodeLanguage == SourceCodeLanguage.mihon &&
        source!.name!.contains("(Torrent");
    if ((source?.isTorrent ?? false) ||
        episode.manga.value!.source == "torrent" ||
        isMihonTorrent) {
      List<Video> list = [];

      List<Video> torrentList = [];
      if (episode.archivePath?.isNotEmpty ?? false) {
        final (videos, infohash) = await MTorrentServer().getTorrentPlaylist(
          episode.url,
          episode.archivePath,
        );
        keepAlive.close();
        return (videos, false, [infohash ?? ""], mpvDirectory);
      }

      try {
        list = await getIsolateService.get<List<Video>>(
          url: episode.url!,
          source: source,
          serviceType: 'getVideoList',
          proxyServer: proxyServer,
        );
      } catch (e) {
        list = [Video(episode.url!, episode.name!, episode.url!)];
      }

      for (var v in list) {
        final (videos, infohash) = await MTorrentServer().getTorrentPlaylist(
          v.url,
          episode.archivePath,
        );
        for (var video in videos) {
          torrentList.add(
            video..quality = video.quality.substringBeforeLast("."),
          );
          if (infohash != null) {
            infoHashes.add(infohash);
          }
        }
      }
      keepAlive.close();
      return (
        _applyPreferredStreamOrder(torrentList, source),
        false,
        infoHashes,
        mpvDirectory,
      );
    }

    List<Video> list = await getIsolateService.get<List<Video>>(
      url: episode.url!,
      source: source,
      serviceType: 'getVideoList',
      proxyServer: proxyServer,
    );
    List<Video> videos = [];

    for (var video in list) {
      if (!videos.any((element) => element.quality == video.quality)) {
        videos.add(video);
      }
    }

    videos = _applyPreferredStreamOrder(videos, source);
    result = (videos, false, infoHashes, mpvDirectory);

    keepAlive.close();
    return result;
  } catch (e) {
    keepAlive.close();
    rethrow;
  }
}
