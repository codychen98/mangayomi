import 'package:hive/hive.dart';
import 'package:isar_community/isar.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/manga.dart';

const defaultLibraryCategoryBoxName = 'default_library_category_v1';

/// Stored when the uncategorized library tab should be used.
const uncategorizedDefaultLibraryCategoryId = 0;

Future<void> openDefaultLibraryCategoryBox() {
  return Hive.openBox(defaultLibraryCategoryBoxName);
}

Box _box() => Hive.box(defaultLibraryCategoryBoxName);

String _defaultCategoryKey(ItemType itemType) => 'default_${itemType.index}';

int? readDefaultLibraryCategory(ItemType itemType) {
  if (!Hive.isBoxOpen(defaultLibraryCategoryBoxName)) return null;
  final stored = _box().get(_defaultCategoryKey(itemType));
  return stored is int ? stored : null;
}

void writeDefaultLibraryCategory(ItemType itemType, int? categoryId) {
  if (!Hive.isBoxOpen(defaultLibraryCategoryBoxName)) return;
  final key = _defaultCategoryKey(itemType);
  if (categoryId == null) {
    _box().delete(key);
  } else {
    _box().put(key, categoryId);
  }
}

bool isDefaultLibraryCategoryConfigured(ItemType itemType) {
  return readDefaultLibraryCategory(itemType) != null;
}

bool isValidDefaultLibraryCategory(int categoryId, ItemType itemType) {
  if (categoryId == uncategorizedDefaultLibraryCategoryId) return true;
  return isar.categorys.getSync(categoryId)?.forItemType == itemType;
}

/// Returns the configured default when still valid, otherwise null.
int? resolveDefaultLibraryCategoryId(ItemType itemType) {
  final configured = readDefaultLibraryCategory(itemType);
  if (configured == null) return null;
  if (!isValidDefaultLibraryCategory(configured, itemType)) return null;
  return configured;
}

List<int> categoryIdsForDefaultLibraryCategory(int defaultCategoryId) {
  if (defaultCategoryId == uncategorizedDefaultLibraryCategoryId) {
    return [];
  }
  return [defaultCategoryId];
}

void setDefaultLibraryCategory(ItemType itemType, int? categoryId) {
  writeDefaultLibraryCategory(itemType, categoryId);
}

void clearDefaultLibraryCategoryIfDeleted(int categoryId, ItemType itemType) {
  if (readDefaultLibraryCategory(itemType) != categoryId) return;
  writeDefaultLibraryCategory(itemType, null);
}

bool hasLibraryCategories(ItemType itemType) {
  return isar.categorys
      .filter()
      .idIsNotNull()
      .and()
      .forItemTypeEqualTo(itemType)
      .isNotEmptySync();
}

void addMangaToLibrary(Manga manga, List<int> categoryIds) {
  isar.writeTxnSync(() {
    manga
      ..favorite = true
      ..categories = categoryIds
      ..dateAdded = DateTime.now().millisecondsSinceEpoch
      ..updatedAt = DateTime.now().millisecondsSinceEpoch;
    isar.mangas.putSync(manga);
  });
}
