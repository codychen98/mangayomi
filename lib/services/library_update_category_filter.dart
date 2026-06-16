import 'package:mangayomi/models/library_update_preferences.dart';
import 'package:mangayomi/models/manga.dart';

List<Manga> filterMangaForLibraryUpdate({
  required List<Manga> entries,
  required List<int> includeCategoryIds,
  required List<int> excludeCategoryIds,
}) {
  var result = entries;

  if (includeCategoryIds.isNotEmpty) {
    final includeSet = includeCategoryIds.toSet();
    result = result
        .where((manga) {
          final categoryIds = manga.categories ?? [];
          if (categoryIds.isEmpty) {
            return false;
          }
          return categoryIds.any(includeSet.contains);
        })
        .toList();
  }

  if (excludeCategoryIds.isNotEmpty) {
    final excludeSet = excludeCategoryIds.toSet();
    result = result
        .where((manga) {
          final categoryIds = manga.categories ?? [];
          return !categoryIds.any(excludeSet.contains);
        })
        .toList();
  }

  return result;
}

List<int> includeCategoryIdsFor(
  ItemType itemType,
  LibraryUpdatePreferences preferences,
) {
  return switch (itemType) {
    ItemType.manga => preferences.mangaUpdateCategoriesInclude,
    ItemType.anime => preferences.animeUpdateCategoriesInclude,
    ItemType.novel => preferences.novelUpdateCategoriesInclude,
  };
}

List<int> excludeCategoryIdsFor(
  ItemType itemType,
  LibraryUpdatePreferences preferences,
) {
  return switch (itemType) {
    ItemType.manga => preferences.mangaUpdateCategoriesExclude,
    ItemType.anime => preferences.animeUpdateCategoriesExclude,
    ItemType.novel => preferences.novelUpdateCategoriesExclude,
  };
}
