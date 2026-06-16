import 'package:isar_community/isar.dart';

part 'library_update_preferences.g.dart';

const libraryUpdatePreferencesRecordId = 1;

@collection
@Name('LibraryUpdatePreferences')
class LibraryUpdatePreferences {
  Id id;

  int unseenUpdatesCountManga;

  int unseenUpdatesCountAnime;

  int unseenUpdatesCountNovel;

  bool showUpdatesTabBadge;

  List<int> mangaUpdateCategoriesInclude;

  List<int> mangaUpdateCategoriesExclude;

  List<int> animeUpdateCategoriesInclude;

  List<int> animeUpdateCategoriesExclude;

  List<int> novelUpdateCategoriesInclude;

  List<int> novelUpdateCategoriesExclude;

  LibraryUpdatePreferences({
    this.id = libraryUpdatePreferencesRecordId,
    this.unseenUpdatesCountManga = 0,
    this.unseenUpdatesCountAnime = 0,
    this.unseenUpdatesCountNovel = 0,
    this.showUpdatesTabBadge = true,
    this.mangaUpdateCategoriesInclude = const [],
    this.mangaUpdateCategoriesExclude = const [],
    this.animeUpdateCategoriesInclude = const [],
    this.animeUpdateCategoriesExclude = const [],
    this.novelUpdateCategoriesInclude = const [],
    this.novelUpdateCategoriesExclude = const [],
  });

  LibraryUpdatePreferences.fromJson(Map<String, dynamic> json)
    : id = json['id'] ?? libraryUpdatePreferencesRecordId,
      unseenUpdatesCountManga = json['unseenUpdatesCountManga'] ?? 0,
      unseenUpdatesCountAnime = json['unseenUpdatesCountAnime'] ?? 0,
      unseenUpdatesCountNovel = json['unseenUpdatesCountNovel'] ?? 0,
      showUpdatesTabBadge = json['showUpdatesTabBadge'] ?? true,
      mangaUpdateCategoriesInclude =
          (json['mangaUpdateCategoriesInclude'] as List?)?.cast<int>() ?? const [],
      mangaUpdateCategoriesExclude =
          (json['mangaUpdateCategoriesExclude'] as List?)?.cast<int>() ?? const [],
      animeUpdateCategoriesInclude =
          (json['animeUpdateCategoriesInclude'] as List?)?.cast<int>() ?? const [],
      animeUpdateCategoriesExclude =
          (json['animeUpdateCategoriesExclude'] as List?)?.cast<int>() ?? const [],
      novelUpdateCategoriesInclude =
          (json['novelUpdateCategoriesInclude'] as List?)?.cast<int>() ?? const [],
      novelUpdateCategoriesExclude =
          (json['novelUpdateCategoriesExclude'] as List?)?.cast<int>() ?? const [];

  Map<String, dynamic> toJson() => {
    'id': id,
    'unseenUpdatesCountManga': unseenUpdatesCountManga,
    'unseenUpdatesCountAnime': unseenUpdatesCountAnime,
    'unseenUpdatesCountNovel': unseenUpdatesCountNovel,
    'showUpdatesTabBadge': showUpdatesTabBadge,
    'mangaUpdateCategoriesInclude': mangaUpdateCategoriesInclude,
    'mangaUpdateCategoriesExclude': mangaUpdateCategoriesExclude,
    'animeUpdateCategoriesInclude': animeUpdateCategoriesInclude,
    'animeUpdateCategoriesExclude': animeUpdateCategoriesExclude,
    'novelUpdateCategoriesInclude': novelUpdateCategoriesInclude,
    'novelUpdateCategoriesExclude': novelUpdateCategoriesExclude,
  };
}
