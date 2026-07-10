import 'package:isar_community/isar.dart';
import 'package:mangayomi/eval/model/source_preference.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/category.dart';
import 'package:mangayomi/models/chapter.dart';
import 'package:mangayomi/models/feed_saved_search.dart';
import 'package:mangayomi/models/history.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/saved_search.dart';
import 'package:mangayomi/models/settings.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/models/sync_preference.dart';
import 'package:mangayomi/models/track.dart';
import 'package:mangayomi/models/update.dart';
import 'package:mangayomi/services/sync/device_local_settings.dart';
import 'package:mangayomi/services/sync/library_category_sort_sync.dart';
import 'package:mangayomi/services/sync/sync_tombstone.dart';

/// JSON snapshot of local library data for WebDAV sync.
class SyncSnapshot {
  static const String snapshotVersion = '4';

  final String version;
  final List<Manga> manga;
  final List<Category> categories;
  final List<Chapter> chapters;
  final List<Track> tracks;
  final List<History> history;
  final List<Update> updates;
  final List<Settings> settings;
  final List<SourcePreference> extensionsPreferences;
  final List<SourcePreferenceStringValue> extensionsPreferenceStringValues;
  final List<Source> extensions;
  final List<SavedSearch> savedSearches;
  final List<FeedSavedSearch> feedSavedSearches;
  final List<SyncTombstone> tombstones;
  final List<LibraryCategorySortEntry> libraryCategorySorts;

  const SyncSnapshot({
    this.version = snapshotVersion,
    this.manga = const [],
    this.categories = const [],
    this.chapters = const [],
    this.tracks = const [],
    this.history = const [],
    this.updates = const [],
    this.settings = const [],
    this.extensionsPreferences = const [],
    this.extensionsPreferenceStringValues = const [],
    this.extensions = const [],
    this.savedSearches = const [],
    this.feedSavedSearches = const [],
    this.tombstones = const [],
    this.libraryCategorySorts = const [],
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
      extensionsPreferences: _parseExtensionsPreferencesList(
        json['extensions_preferences'],
      ),
      extensionsPreferenceStringValues:
          _parseExtensionsPreferenceStringValuesList(
        json['extensions_preference_string_values'],
      ),
      extensions: _parseExtensionsList(json['extensions']),
      savedSearches: _parseSavedSearchList(json['savedSearches']),
      feedSavedSearches: _parseFeedSavedSearchList(json['feedSavedSearches']),
      tombstones: _parseTombstoneList(json['tombstones']),
      libraryCategorySorts: parseLibraryCategorySortList(
        json['libraryCategorySorts'],
      ),
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
    if (extensionsPreferences.isNotEmpty) {
      json['extensions_preferences'] =
          extensionsPreferences.map((e) => e.toJson()).toList();
    }
    if (extensionsPreferenceStringValues.isNotEmpty) {
      json['extensions_preference_string_values'] =
          extensionsPreferenceStringValues.map((e) => e.toJson()).toList();
    }
    if (extensions.isNotEmpty) {
      json['extensions'] = extensions.map((e) => e.toJson()).toList();
    }
    if (savedSearches.isNotEmpty) {
      json['savedSearches'] = savedSearches.map((e) => e.toJson()).toList();
    }
    if (feedSavedSearches.isNotEmpty) {
      json['feedSavedSearches'] =
          feedSavedSearches.map((e) => e.toJson()).toList();
    }
    if (tombstones.isNotEmpty) {
      json['tombstones'] = tombstones.map((e) => e.toJson()).toList();
    }
    if (libraryCategorySorts.isNotEmpty) {
      json['libraryCategorySorts'] =
          libraryCategorySorts.map((e) => e.toJson()).toList();
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

  static List<SourcePreference> _parseExtensionsPreferencesList(Object? raw) {
    return (raw as List?)
            ?.map(
              (e) => SourcePreference.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        [];
  }

  static List<SourcePreferenceStringValue>
  _parseExtensionsPreferenceStringValuesList(Object? raw) {
    return (raw as List?)
            ?.map(
              (e) => SourcePreferenceStringValue.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList() ??
        [];
  }

  static List<Source> _parseExtensionsList(Object? raw) {
    return (raw as List?)
            ?.map(
              (e) => Source.fromJson(e as Map<String, dynamic>)
                ..itemType = _itemTypeFromJson(e),
            )
            .toList() ??
        [];
  }

  static List<SavedSearch> _parseSavedSearchList(Object? raw) {
    return (raw as List?)
            ?.map((e) => SavedSearch.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  static List<FeedSavedSearch> _parseFeedSavedSearchList(Object? raw) {
    return (raw as List?)
            ?.map((e) => FeedSavedSearch.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  static List<SyncTombstone> _parseTombstoneList(Object? raw) {
    return (raw as List?)
            ?.map((e) => SyncTombstone.fromJson(e as Map<String, dynamic>))
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
SyncSnapshot buildLocalSnapshot(
  SyncPreference prefs, {
  List<SyncTombstone> tombstones = const [],
}) {
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

  final extensionsPreferences = isar.sourcePreferences
      .filter()
      .idIsNotNull()
      .findAllSync()
      .map((e) => SourcePreference.fromJson(e.toJson()))
      .toList();

  final extensionsPreferenceStringValues = isar.sourcePreferenceStringValues
      .where()
      .anyId()
      .findAllSync()
      .map(
        (e) => SourcePreferenceStringValue.fromJson({
          'id': e.id,
          'sourceId': e.sourceId,
          'key': e.key,
          'value': e.value,
        }),
      )
      .toList();

  final extensions = isar.sources
      .filter()
      .isAddedEqualTo(true)
      .findAllSync()
      .map((e) => Source.fromJson(e.toJson())..itemType = e.itemType)
      .toList();

  final savedSearches = isar.savedSearchs
      .filter()
      .idIsNotNull()
      .findAllSync()
      .map((e) => SavedSearch.fromJson(e.toJson()))
      .toList();

  final feedSavedSearches = isar.feedSavedSearchs
      .filter()
      .idIsNotNull()
      .findAllSync()
      .map((e) => FeedSavedSearch.fromJson(e.toJson()))
      .toList();

  return SyncSnapshot(
    manga: manga,
    categories: categories,
    chapters: chapters,
    tracks: tracks,
    history: history,
    updates: updates,
    settings: settings,
    extensionsPreferences: extensionsPreferences,
    extensionsPreferenceStringValues: extensionsPreferenceStringValues,
    extensions: extensions,
    savedSearches: savedSearches,
    feedSavedSearches: feedSavedSearches,
    tombstones: tombstones,
    libraryCategorySorts: exportLibraryCategorySorts(),
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
  return stripDeviceLocalSettings(settings);
}
