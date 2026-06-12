import 'package:isar_community/isar.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/category.dart';
import 'package:mangayomi/models/chapter.dart';
import 'package:mangayomi/models/history.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/settings.dart';
import 'package:mangayomi/models/sync_preference.dart';
import 'package:mangayomi/models/track.dart';
import 'package:mangayomi/models/update.dart';

/// JSON snapshot of local library data for WebDAV sync (backup v2 shape).
class SyncSnapshot {
  static const String snapshotVersion = '2';

  final String version;
  final List<Manga> manga;
  final List<Category> categories;
  final List<Chapter> chapters;
  final List<Track> tracks;
  final List<History> history;
  final List<Update> updates;
  final List<Settings> settings;

  const SyncSnapshot({
    this.version = snapshotVersion,
    this.manga = const [],
    this.categories = const [],
    this.chapters = const [],
    this.tracks = const [],
    this.history = const [],
    this.updates = const [],
    this.settings = const [],
  });

  factory SyncSnapshot.fromJson(Map<String, dynamic> json) {
    return SyncSnapshot(
      version: json['version'] as String? ?? snapshotVersion,
      manga: _parseMangaList(json['manga']),
      categories: _parseCategoryList(json['categories']),
      chapters: _parseChapterList(json['chapters']),
      tracks: _parseTrackList(json['tracks']),
      history: _parseHistoryList(json['history']),
      updates: _parseUpdateList(json['updates']),
      settings: _parseSettingsList(json['settings']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'version': version,
      'manga': manga.map((e) => e.toJson()).toList(),
      'categories': categories.map((e) => e.toJson()).toList(),
      'chapters': chapters.map((e) => e.toJson()).toList(),
      'tracks': tracks.map((e) => e.toJson()).toList(),
    };
    if (history.isNotEmpty) {
      json['history'] = history.map((e) => e.toJson()).toList();
    }
    if (updates.isNotEmpty) {
      json['updates'] = updates.map((e) => e.toJson()).toList();
    }
    if (settings.isNotEmpty) {
      json['settings'] = settings.map((e) => e.toJson()).toList();
    }
    return json;
  }

  static List<Manga> _parseMangaList(Object? raw) {
    return (raw as List?)
            ?.map(
              (e) => Manga.fromJson(e as Map<String, dynamic>)
                ..itemType = _itemTypeFromJson(e),
            )
            .toList() ??
        [];
  }

  static List<Category> _parseCategoryList(Object? raw) {
    return (raw as List?)
            ?.map(
              (e) => Category.fromJson(e as Map<String, dynamic>)
                ..forItemType = _categoryItemTypeFromJson(e),
            )
            .toList() ??
        [];
  }

  static List<Chapter> _parseChapterList(Object? raw) {
    return (raw as List?)
            ?.map((e) => Chapter.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  static List<Track> _parseTrackList(Object? raw) {
    return (raw as List?)
            ?.map(
              (e) => Track.fromJson(e as Map<String, dynamic>)
                ..itemType = _itemTypeFromJson(e),
            )
            .toList() ??
        [];
  }

  static List<History> _parseHistoryList(Object? raw) {
    return (raw as List?)
            ?.map(
              (e) => History.fromJson(e as Map<String, dynamic>)
                ..itemType = _itemTypeFromJson(e),
            )
            .toList() ??
        [];
  }

  static List<Update> _parseUpdateList(Object? raw) {
    return (raw as List?)
            ?.map((e) => Update.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  static List<Settings> _parseSettingsList(Object? raw) {
    if (raw is Map<String, dynamic>) {
      return [Settings.fromJson(raw)];
    }
    return (raw as List?)
            ?.map((e) => Settings.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  static ItemType _itemTypeFromJson(Map<String, dynamic> json) {
    final isManga = json['isManga'];
    if (isManga == null) {
      return ItemType.values[json['itemType'] as int? ?? 0];
    }
    return isManga ? ItemType.manga : ItemType.anime;
  }

  static ItemType _categoryItemTypeFromJson(Map<String, dynamic> json) {
    final forManga = json['forManga'];
    if (forManga == null) {
      return ItemType.values[json['forItemType'] as int? ?? 0];
    }
    return forManga ? ItemType.manga : ItemType.anime;
  }
}

/// Builds a full local snapshot from Isar using [sync_server.dart] scope.
SyncSnapshot buildLocalSnapshot(SyncPreference prefs) {
  final manga = isar.mangas
      .filter()
      .idIsNotNull()
      .findAllSync()
      .map(_mangaToSnapshotJson)
      .map(Manga.fromJson)
      .toList();

  final categories = isar.categorys
      .filter()
      .idIsNotNull()
      .findAllSync()
      .map((e) => e.toJson())
      .map(Category.fromJson)
      .toList();

  final chapters = isar.chapters
      .filter()
      .idIsNotNull()
      .findAllSync()
      .map((e) => e.toJson())
      .map(Chapter.fromJson)
      .toList();

  final tracks = isar.tracks
      .filter()
      .idIsNotNull()
      .findAllSync()
      .map((e) => e.toJson())
      .map(Track.fromJson)
      .toList();

  final history = prefs.syncHistories
      ? isar.historys
            .filter()
            .idIsNotNull()
            .findAllSync()
            .map((e) => e.toJson())
            .map(History.fromJson)
            .toList()
      : <History>[];

  final updates = prefs.syncUpdates
      ? isar.updates
            .filter()
            .idIsNotNull()
            .findAllSync()
            .map((e) => e.toJson())
            .map(Update.fromJson)
            .toList()
      : <Update>[];

  final settings = prefs.syncSettings
      ? [_settingsToSnapshotJson()]
      : <Settings>[];

  return SyncSnapshot(
    manga: manga,
    categories: categories,
    chapters: chapters,
    tracks: tracks,
    history: history,
    updates: updates,
    settings: settings,
  );
}

Map<String, dynamic> _mangaToSnapshotJson(Manga manga) {
  final json = manga.toJson();
  json.remove('customCoverImage');
  return json;
}

Settings _settingsToSnapshotJson() {
  final settings = Settings.fromJson(
    isar.settings.getSync(227)!.toJson(),
  );
  settings.updatedAt ??= DateTime.now().millisecondsSinceEpoch;
  settings.cookiesList = [];
  return settings;
}
