import 'package:hive/hive.dart';
import 'package:isar_community/isar.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/category.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/settings.dart';
import 'package:mangayomi/modules/library/providers/library_category_sort_storage.dart';

String _normalizeSyncKeyPart(String? value) => (value ?? '').trim().toLowerCase();

String categorySyncKey(Category category) =>
    '${category.forItemType.index}|${_normalizeSyncKeyPart(category.name)}';

class LibraryCategorySortEntry {
  final String categoryKey;
  final int index;
  final bool reverse;
  final int updatedAt;

  const LibraryCategorySortEntry({
    required this.categoryKey,
    required this.index,
    required this.reverse,
    required this.updatedAt,
  });

  factory LibraryCategorySortEntry.fromJson(Map<String, dynamic> json) {
    return LibraryCategorySortEntry(
      categoryKey: json['categoryKey'] as String? ?? '',
      index: json['index'] as int? ?? 0,
      reverse: json['reverse'] as bool? ?? false,
      updatedAt: json['updatedAt'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'categoryKey': categoryKey,
    'index': index,
    'reverse': reverse,
    'updatedAt': updatedAt,
  };
}

List<LibraryCategorySortEntry> exportLibraryCategorySorts() {
  if (!Hive.isBoxOpen(libraryCategorySortBoxName)) {
    return const [];
  }

  final box = Hive.box(libraryCategorySortBoxName);
  final categories = isar.categorys.filter().idIsNotNull().findAllSync();
  final categoryIdToKey = <int, String>{
    for (final category in categories)
      if (category.id != null) category.id!: categorySyncKey(category),
  };

  final entries = <LibraryCategorySortEntry>[];
  for (final rawKey in box.keys) {
    if (rawKey is! String) continue;

    final parts = rawKey.split('_');
    if (parts.length != 2) continue;

    final categoryId = int.tryParse(parts[1]);
    if (categoryId == null) continue;

    final categoryKey = categoryIdToKey[categoryId];
    if (categoryKey == null) continue;

    final stored = box.get(rawKey);
    if (stored is! Map) continue;

    final index = stored['index'];
    if (index is! int) continue;

    entries.add(
      LibraryCategorySortEntry(
        categoryKey: categoryKey,
        index: index,
        reverse: stored['reverse'] is bool ? stored['reverse'] as bool : false,
        updatedAt: stored['updatedAt'] is int ? stored['updatedAt'] as int : 0,
      ),
    );
  }

  return entries;
}

Future<void> applyLibraryCategorySorts(
  List<LibraryCategorySortEntry> entries,
) async {
  if (entries.isEmpty) return;

  if (!Hive.isBoxOpen(libraryCategorySortBoxName)) {
    await openLibraryCategorySortBox();
  }

  final categories = isar.categorys.filter().idIsNotNull().findAllSync();
  final keyToCategoryId = <String, int>{
    for (final category in categories)
      if (category.id != null) categorySyncKey(category): category.id!,
  };

  final box = Hive.box(libraryCategorySortBoxName);
  for (final entry in entries) {
    final categoryId = keyToCategoryId[entry.categoryKey];
    if (categoryId == null) continue;

    final itemTypeIndex = int.tryParse(entry.categoryKey.split('|').first);
    if (itemTypeIndex == null) continue;

    await box.put('${itemTypeIndex}_$categoryId', {
      'index': entry.index,
      'reverse': entry.reverse,
      'updatedAt': entry.updatedAt,
    });
  }
}

List<LibraryCategorySortEntry> parseLibraryCategorySortList(Object? raw) {
  return (raw as List?)
          ?.map(
            (e) => LibraryCategorySortEntry.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [];
}
