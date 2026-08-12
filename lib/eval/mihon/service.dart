import 'dart:convert';
import 'dart:math';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:mangayomi/eval/javascript/http.dart';
import 'package:mangayomi/eval/model/filter.dart';
import 'package:mangayomi/eval/model/m_chapter.dart';
import 'package:mangayomi/eval/model/m_manga.dart';
import 'package:mangayomi/eval/model/m_pages.dart';
import 'package:mangayomi/eval/model/source_preference.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/page.dart';
import 'package:mangayomi/models/settings.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/models/video.dart';
import 'package:mangayomi/services/http/m_client.dart';
import 'package:mangayomi/utils/extensions/string_extensions.dart';
import 'package:mangayomi/utils/log/logger.dart';

import '../../models/manga.dart';
import '../interface.dart';
import 'models.dart';

class MihonExtensionService implements ExtensionService {
  late String androidProxyServer;
  @override
  late Source source;
  late final InterceptedClient client = MClient.init();

  MihonExtensionService(this.source, this.androidProxyServer);

  @override
  void dispose() {}

  @override
  Map<String, String> getHeaders() {
    return source.headers != null && source.headers!.isNotEmpty
        ? (jsonDecode(source.headers!) as Map?)?.toMapStringString ?? {}
        : {};
  }

  @override
  bool get supportsLatest {
    return source.supportLatest ?? false;
  }

  @override
  String get sourceBaseUrl {
    return source.baseUrl!;
  }

  void _logCall(String method, String detail) {
    AppLogger.log(
      '[MIHON] $method source=${source.name} base=${source.baseUrl} $detail',
    );
  }

  /// Strip a stored absolute or doubled-host URL down to path+query so Mihon
  /// extensions that do `GET(baseUrl + url)` do not produce `hosthttps://host`.
  String _urlForMihon(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;

    final base = (source.baseUrl ?? '').trim();
    final baseNoSlash = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;

    var candidate = trimmed;
    if (baseNoSlash.isNotEmpty && candidate.startsWith(baseNoSlash)) {
      candidate = candidate.substring(baseNoSlash.length);
      if (candidate.isEmpty) return trimmed;
      if (!candidate.startsWith('http://') &&
          !candidate.startsWith('https://')) {
        if (!candidate.startsWith('/')) {
          candidate = '/$candidate';
        }
        _logNormalized(trimmed, candidate);
        return candidate;
      }
    }

    if (candidate.startsWith('http://') || candidate.startsWith('https://')) {
      try {
        final path = candidate.getUrlWithoutDomain;
        if (path.isNotEmpty) {
          _logNormalized(trimmed, path);
          return path;
        }
      } catch (_) {}
    }

    return trimmed;
  }

  void _logNormalized(String from, String to) {
    if (from == to) return;
    AppLogger.log('[MIHON] normalized url from=$from to=$to');
  }

  @override
  Future<MPages> getPopular(int page) async {
    final name = source.itemType == ItemType.anime ? "Anime" : "Manga";
    _logCall("getPopular$name", "page=${page + 1}");
    final res = await client.post(
      Uri.parse("$androidProxyServer/dalvik"),
      body: jsonEncode({
        "method": "getPopular$name",
        "page": page + 1,
        "search": "",
        "preferences": getSourcePreferences(),
        "data": source.sourceCode,
      }),
      headers: getCookie(),
    );
    hasError(res, context: "getPopular$name");
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final pages = MangaPages.fromJson(data, source.itemType);
    return MPages(
      list: pages.list
          .map(
            (e) => MManga(
              name: e.title,
              link: e.url,
              artist: e.artist,
              author: e.author,
              description: e.description,
              genre: e.genre,
              status: e.status,
              imageUrl: e.thumbnailUrl,
              chapters: [],
            ),
          )
          .toList(),
      hasNextPage: pages.hasNextPage,
    );
  }

  @override
  Future<MPages> getLatestUpdates(int page) async {
    final name = source.itemType == ItemType.anime ? "Anime" : "Manga";
    _logCall("getLatest$name", "page=${page + 1}");
    final res = await client.post(
      Uri.parse("$androidProxyServer/dalvik"),
      body: jsonEncode({
        "method": "getLatest$name",
        "page": page + 1,
        "search": "",
        "preferences": getSourcePreferences(),
        "data": source.sourceCode,
      }),
      headers: getCookie(),
    );
    hasError(res, context: "getLatest$name");
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final pages = MangaPages.fromJson(data, source.itemType);
    return MPages(
      list: pages.list
          .map(
            (e) => MManga(
              name: e.title,
              link: e.url,
              artist: e.artist,
              author: e.author,
              description: e.description,
              genre: e.genre,
              status: e.status,
              imageUrl: e.thumbnailUrl,
              chapters: [],
            ),
          )
          .toList(),
      hasNextPage: pages.hasNextPage,
    );
  }

  @override
  Future<MPages> search(String query, int page, List<dynamic> filters) async {
    final name = source.itemType == ItemType.anime ? "Anime" : "Manga";
    _logCall("getSearch$name", "page=${max(1, page)} query=$query");
    final res = await client.post(
      Uri.parse("$androidProxyServer/dalvik"),
      body: jsonEncode({
        "method": "getSearch$name",
        "page": max(1, page),
        "search": query,
        "filterList": _convertFilters(filters),
        "preferences": getSourcePreferences(),
        "data": source.sourceCode,
      }),
      headers: getCookie(),
    );
    hasError(res, context: "getSearch$name");
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final pages = MangaPages.fromJson(data, source.itemType);
    return MPages(
      list: pages.list
          .map(
            (e) => MManga(
              name: e.title,
              link: e.url,
              artist: e.artist,
              author: e.author,
              description: e.description,
              genre: e.genre,
              status: e.status,
              imageUrl: e.thumbnailUrl,
              chapters: [],
            ),
          )
          .toList(),
      hasNextPage: pages.hasNextPage,
    );
  }

  @override
  Future<MManga> getDetail(String url) async {
    url = _urlForMihon(url);
    final name = source.itemType == ItemType.anime ? "Anime" : "Manga";
    _logCall("getDetails$name", "url=$url");
    final res = await client.post(
      Uri.parse("$androidProxyServer/dalvik"),
      body: jsonEncode({
        "method": "getDetails$name",
        if (source.itemType == ItemType.manga) "mangaData": {"url": url},
        if (source.itemType == ItemType.anime) "animeData": {"url": url},
        "preferences": getSourcePreferences(),
        "data": source.sourceCode,
      }),
      headers: getCookie(),
    );
    hasError(res, context: "getDetails$name");
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    _logCall("getDetails$name", "responseUrl=${data['url']}");
    final chapters = await getChapterList(url);
    return MManga(
      name: data['title'],
      link: data['url'],
      artist: data['artist'],
      author: data['author'],
      description: data['description'],
      genre: (data['genres'] as List?)?.map((e) => e.toString()).toList() ?? [],
      status: switch (data['status'] as int?) {
        1 => Status.ongoing,
        2 => Status.completed,
        4 => Status.publishingFinished,
        5 => Status.canceled,
        6 => Status.onHiatus,
        _ => Status.unknown,
      },
      imageUrl: data['thumbnail_url'],
      chapters: chapters,
    );
  }

  Future<List<MChapter>> getChapterList(String url) async {
    url = _urlForMihon(url);
    final listMethod = source.itemType == ItemType.anime
        ? "getEpisodeList"
        : "getChapterList";
    _logCall(listMethod, "url=$url");
    final res = await client.post(
      Uri.parse("$androidProxyServer/dalvik"),
      body: jsonEncode({
        "method": source.itemType == ItemType.anime
            ? "getEpisodeList"
            : "getChapterList",
        if (source.itemType == ItemType.manga) "mangaData": {"url": url},
        if (source.itemType == ItemType.anime) "animeData": {"url": url},
        "preferences": getSourcePreferences(),
        "data": source.sourceCode,
      }),
      headers: getCookie(),
    );
    hasError(res, context: listMethod);
    final data = jsonDecode(res.body) as List;
    return data
        .map(
          (e) => MChapter(
            name: e['name'],
            url: e['url'],
            dateUpload:
                (e['date_upload'] as int?)?.toString() ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            scanlator: e['scanlator'],
          ),
        )
        .toList();
  }

  @override
  Future<List<PageUrl>> getPageList(String url) async {
    url = _urlForMihon(url);
    _logCall("getPageList", "url=$url");
    final res = await client.post(
      Uri.parse("$androidProxyServer/dalvik"),
      body: jsonEncode({
        "method": "getPageList",
        "chapterData": {"url": url},
        "preferences": getSourcePreferences(),
        "data": source.sourceCode,
      }),
      headers: getCookie(),
    );
    hasError(res, context: "getPageList");
    final data = jsonDecode(res.body) as List;
    return data.map((e) => PageUrl(e['imageUrl'])).toList();
  }

  @override
  Future<List<Video>> getVideoList(String url) async {
    url = _urlForMihon(url);
    _logCall("getVideoList", "url=$url");
    final res = await client.post(
      Uri.parse("$androidProxyServer/dalvik"),
      body: jsonEncode({
        "method": "getVideoList",
        "episodeData": {"url": url},
        "preferences": getSourcePreferences(),
        "data": source.sourceCode,
      }),
      headers: getCookie(),
    );
    hasError(res, context: "getVideoList");
    final data = jsonDecode(res.body) as List;
    final videos = data.map((e) {
      final tempHeaders =
          e['headers']?['namesAndValues\$okhttp'] as List<dynamic>?;
      final Map<String, String> headers = {};
      if (tempHeaders != null) {
        for (var i = 0; i + 1 < tempHeaders.length; i += 2) {
          headers[tempHeaders[i]] = tempHeaders[i + 1];
        }
      }
      return Video(
        e['videoUrl'],
        e['quality'],
        e['url'],
        headers: headers,
        audios:
            (e['audioTracks'] as List?)
                ?.map(
                  (e) => Track(
                    file: e['file'] ?? e['url'],
                    label: e['label'] ?? e['lang'],
                  ),
                )
                .toList() ??
            [],
        subtitles:
            (e['subtitleTracks'] as List?)
                ?.map(
                  (e) => Track(
                    file: e['file'] ?? e['url'],
                    label: e['label'] ?? e['lang'],
                  ),
                )
                .toList() ??
            [],
      );
    }).toList();
    for (final video in videos) {
      final headerKeys = video.headers?.keys.toList() ?? const <String>[];
      AppLogger.log(
        '[MIHON] getVideoList result source=${source.name} '
        'quality=${video.quality} '
        'stream=${video.url.toLogSafeUri()} '
        'original=${video.originalUrl.toLogSafeUri()} '
        'hls=${video.url.looksLikeHls} '
        'headerCount=${headerKeys.length} '
        'headerKeys=${headerKeys.join(',')} '
        'subs=${video.subtitles?.length ?? 0} '
        'audios=${video.audios?.length ?? 0}',
      );
    }
    return videos;
  }

  @override
  Future<String> getHtmlContent(String name, String url) async {
    return "";
  }

  @override
  Future<String> cleanHtmlContent(String html) async {
    return html;
  }

  @override
  FilterList getFilterList() {
    return source.getFilterList() ?? FilterList([]);
  }

  @override
  List<SourcePreference> getSourcePreferences() {
    if (source.preferenceList == null) {
      return [];
    }
    final data = jsonDecode(source.preferenceList!) as List;
    return data.map((e) => SourcePreference.fromJson(e)).toList();
  }

  List<dynamic> _convertFilters(List<dynamic> filters) {
    return filters.expand((e) sync* {
      if (e is TextFilter) {
        yield {"name": e.name, "stateString": e.state, "type": "TextFilter"};
      } else if (e is GroupFilter) {
        yield {
          "name": e.name,
          "stateList": e.state.expand((e) sync* {
            if (e is CheckBoxFilter) {
              yield {
                "name": e.name,
                "stateBoolean": e.state,
                "type": "CheckBoxFilter",
              };
            } else if (e is TriStateFilter) {
              yield {
                "name": e.name,
                "stateInt": e.state,
                "type": "TriStateFilter",
              };
            }
          }).toList(),
          "type": "GroupFilter",
        };
      } else if (e is SelectFilter) {
        yield {"name": e.name, "stateInt": e.state, "type": "SelectFilter"};
      } else if (e is SortFilter) {
        yield {
          "name": e.name,
          "stateSort": {"ascending": e.state.ascending, "index": e.state.index},
          "type": "SortFilter",
        };
      }
    }).toList();
  }

  Map<String, String> getCookie() {
    final userAgent = isar.settings.getSync(227)!.userAgent;
    return {
      ...MClient.getCookiesPref(source.baseUrl!),
      'user-agent': ?userAgent,
    };
  }
}

void hasError(Response response, {String? context}) {
  try {
    final errorMessage = jsonDecode(response.body)['error'];
    final code = jsonDecode(response.body)['code'];
    if (errorMessage != null && code != null) {
      AppLogger.log(
        '[MIHON] ${context ?? 'bridge'} failed code=$code body=${response.body}',
        logLevel: LogLevel.error,
      );
      if ((code as int) == 403) {
        throw "errorMessage: ${context ?? 'bridge'}: Failed to bypass Cloudflare.\n\n\nYou can try to bypass it manually in the webview \n\n\nstatusCode: 403";
      }
      throw "errorMessage: ${context ?? 'bridge'}: $errorMessage \n\n\nstatusCode: $code";
    }
  } catch (e) {
    if (e.toString().startsWith('errorMessage:')) {
      throw e.toString().replaceFirst('errorMessage: ', '');
    }
  }
}
