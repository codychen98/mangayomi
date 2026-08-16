import 'package:isar_community/isar.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/settings.dart';
import 'package:mangayomi/modules/library/library_source_group.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'isar_providers.g.dart';

@riverpod
Stream<List<Manga>> getAllMangaStream(
  Ref ref, {
  required int? categoryId,
  required ItemType itemType,
}) async* {
  yield* categoryId == null
      ? isar.mangas
            .filter()
            .idIsNotNull()
            .favoriteEqualTo(true)
            .and()
            .itemTypeEqualTo(itemType)
            .watch(fireImmediately: true)
      : isar.mangas
            .filter()
            .idIsNotNull()
            .favoriteEqualTo(true)
            .categoriesIsNotEmpty()
            .categoriesElementEqualTo(categoryId)
            .and()
            .itemTypeEqualTo(itemType)
            .watch(fireImmediately: true);
}

@riverpod
Stream<List<Manga>> getAllMangaWithoutCategoriesStream(
  Ref ref, {
  required ItemType itemType,
}) async* {
  yield* isar.mangas
      .filter()
      .idIsNotNull()
      .favoriteEqualTo(true)
      .categoriesIsEmpty()
      .and()
      .itemTypeEqualTo(itemType)
      .or()
      .idIsNotNull()
      .categoriesIsNull()
      .favoriteEqualTo(true)
      .and()
      .itemTypeEqualTo(itemType)
      .watch(fireImmediately: true);
}

/// Favorites for [itemType] matching a library source tab group.
@riverpod
Stream<List<Manga>> getMangaByLibrarySourceStream(
  Ref ref, {
  required ItemType itemType,
  required LibrarySourceGroup sourceGroup,
}) async* {
  if (sourceGroup.isLocal) {
    yield* isar.mangas
        .filter()
        .idIsNotNull()
        .favoriteEqualTo(true)
        .itemTypeEqualTo(itemType)
        .isLocalArchiveEqualTo(true)
        .watch(fireImmediately: true);
    return;
  }

  if (sourceGroup.sourceId != null) {
    yield* isar.mangas
        .filter()
        .idIsNotNull()
        .favoriteEqualTo(true)
        .itemTypeEqualTo(itemType)
        .sourceIdEqualTo(sourceGroup.sourceId!)
        .watch(fireImmediately: true);
    return;
  }

  yield* isar.mangas
      .filter()
      .idIsNotNull()
      .favoriteEqualTo(true)
      .itemTypeEqualTo(itemType)
      .sourceIdIsNull()
      .sourceEqualTo(sourceGroup.source)
      .langEqualTo(sourceGroup.lang)
      .watch(fireImmediately: true)
      .map(
        (list) => list
            .where((manga) => manga.isLocalArchive != true)
            .toList(growable: false),
      );
}

@riverpod
Stream<List<Settings>> getSettingsStream(Ref ref) async* {
  yield* isar.settings
      .filter()
      .idIsNotNull()
      .and()
      .idEqualTo(227)
      .watch(fireImmediately: true);
}
