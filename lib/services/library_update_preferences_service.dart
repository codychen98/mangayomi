import 'package:isar_community/isar.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/library_update_preferences.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/services/library_update_category_filter.dart';

LibraryUpdatePreferences getLibraryUpdatePreferences() {
  return isar.libraryUpdatePreferences.getSync(libraryUpdatePreferencesRecordId) ??
      LibraryUpdatePreferences();
}

Future<void> ensureLibraryUpdatePreferences() async {
  final existing = await isar.libraryUpdatePreferences.get(
    libraryUpdatePreferencesRecordId,
  );
  if (existing != null) return;
  await isar.writeTxn(
    () => isar.libraryUpdatePreferences.put(LibraryUpdatePreferences()),
  );
}

void saveLibraryUpdatePreferences(LibraryUpdatePreferences preferences) {
  isar.writeTxnSync(() => isar.libraryUpdatePreferences.putSync(preferences));
}

Stream<LibraryUpdatePreferences> watchLibraryUpdatePreferences() {
  return isar.libraryUpdatePreferences
      .filter()
      .idEqualTo(libraryUpdatePreferencesRecordId)
      .watch(fireImmediately: true)
      .map(
        (entries) =>
            entries.firstOrNull ?? LibraryUpdatePreferences(),
      );
}

int unseenUpdatesCountFor(
  LibraryUpdatePreferences preferences,
  ItemType itemType,
) {
  return switch (itemType) {
    ItemType.manga => preferences.unseenUpdatesCountManga,
    ItemType.anime => preferences.unseenUpdatesCountAnime,
    ItemType.novel => preferences.unseenUpdatesCountNovel,
  };
}

void incrementUnseenUpdatesCount(ItemType itemType, int count) {
  if (count <= 0) return;
  final preferences = getLibraryUpdatePreferences();
  switch (itemType) {
    case ItemType.manga:
      preferences.unseenUpdatesCountManga += count;
    case ItemType.anime:
      preferences.unseenUpdatesCountAnime += count;
    case ItemType.novel:
      preferences.unseenUpdatesCountNovel += count;
  }
  saveLibraryUpdatePreferences(preferences);
}

void resetUnseenUpdatesCount() {
  final preferences = getLibraryUpdatePreferences();
  preferences
    ..unseenUpdatesCountManga = 0
    ..unseenUpdatesCountAnime = 0
    ..unseenUpdatesCountNovel = 0;
  saveLibraryUpdatePreferences(preferences);
}

void setUpdateCategories({
  required ItemType itemType,
  required List<int> include,
  required List<int> exclude,
}) {
  final preferences = getLibraryUpdatePreferences();
  switch (itemType) {
    case ItemType.manga:
      preferences
        ..mangaUpdateCategoriesInclude = include
        ..mangaUpdateCategoriesExclude = exclude;
    case ItemType.anime:
      preferences
        ..animeUpdateCategoriesInclude = include
        ..animeUpdateCategoriesExclude = exclude;
    case ItemType.novel:
      preferences
        ..novelUpdateCategoriesInclude = include
        ..novelUpdateCategoriesExclude = exclude;
  }
  saveLibraryUpdatePreferences(preferences);
}

void setShowUpdatesTabBadge(bool value) {
  final preferences = getLibraryUpdatePreferences();
  preferences.showUpdatesTabBadge = value;
  saveLibraryUpdatePreferences(preferences);
}

List<Manga> filterLibraryEntriesForUpdate({
  required List<Manga> entries,
  required ItemType itemType,
  LibraryUpdatePreferences? preferences,
}) {
  final prefs = preferences ?? getLibraryUpdatePreferences();
  return filterMangaForLibraryUpdate(
    entries: entries,
    includeCategoryIds: includeCategoryIdsFor(itemType, prefs),
    excludeCategoryIds: excludeCategoryIdsFor(itemType, prefs),
  );
}
