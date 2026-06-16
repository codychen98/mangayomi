import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangayomi/models/library_update_preferences.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/services/library_update_preferences_service.dart';

final libraryUpdatePreferencesProvider =
    StreamProvider<LibraryUpdatePreferences>((ref) {
      return watchLibraryUpdatePreferences();
    });

int totalUnseenUpdatesCount(
  LibraryUpdatePreferences preferences,
  List<String> hideItems,
) {
  var total = 0;
  if (!hideItems.contains('/MangaLibrary')) {
    total += preferences.unseenUpdatesCountManga;
  }
  if (!hideItems.contains('/AnimeLibrary')) {
    total += preferences.unseenUpdatesCountAnime;
  }
  if (!hideItems.contains('/NovelLibrary')) {
    total += preferences.unseenUpdatesCountNovel;
  }
  return total;
}

int unseenUpdatesCountForItemType(
  LibraryUpdatePreferences preferences,
  ItemType itemType,
) {
  return unseenUpdatesCountFor(preferences, itemType);
}
