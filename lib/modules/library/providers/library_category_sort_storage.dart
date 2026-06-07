import 'package:hive/hive.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/settings.dart';

const libraryCategorySortBoxName = 'library_category_sort_v1';

Future<void> openLibraryCategorySortBox() {
  return Hive.openBox(libraryCategorySortBoxName);
}

Box _box() => Hive.box(libraryCategorySortBoxName);

String _sortKey({required int categoryId, required ItemType itemType}) {
  return '${itemType.index}_$categoryId';
}

SortLibraryManga? readCategorySort({
  required int categoryId,
  required ItemType itemType,
}) {
  if (!Hive.isBoxOpen(libraryCategorySortBoxName)) return null;

  final stored = _box().get(_sortKey(categoryId: categoryId, itemType: itemType));
  if (stored is! Map) return null;

  final index = stored['index'];
  final reverse = stored['reverse'];
  if (index is! int) return null;

  return SortLibraryManga(
    index: index,
    reverse: reverse is bool ? reverse : false,
  );
}

Future<void> writeCategorySort({
  required int categoryId,
  required ItemType itemType,
  required int index,
  required bool reverse,
}) async {
  if (!Hive.isBoxOpen(libraryCategorySortBoxName)) {
    await openLibraryCategorySortBox();
  }

  await _box().put(_sortKey(categoryId: categoryId, itemType: itemType), {
    'index': index,
    'reverse': reverse,
  });
}
