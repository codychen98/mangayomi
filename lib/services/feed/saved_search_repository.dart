import 'package:isar_community/isar.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/feed_saved_search.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/saved_search.dart';

class SavedSearchRepository {
  static const SavedSearchRepository instance = SavedSearchRepository._();
  const SavedSearchRepository._();

  Future<SavedSearch?> getById(int id) {
    return isar.savedSearchs.get(id);
  }

  Future<List<SavedSearch>> getBySourceId({
    required int sourceId,
    required ItemType itemType,
  }) {
    return isar.savedSearchs
        .filter()
        .sourceIdEqualTo(sourceId)
        .and()
        .itemTypeEqualTo(itemType)
        .findAll();
  }

  Stream<List<SavedSearch>> watchBySourceId({
    required int sourceId,
    required ItemType itemType,
  }) {
    return isar.savedSearchs
        .filter()
        .sourceIdEqualTo(sourceId)
        .and()
        .itemTypeEqualTo(itemType)
        .watch(fireImmediately: true);
  }

  Future<void> delete(int id) async {
    await isar.writeTxn(() async {
      final feedRefs = await isar.feedSavedSearchs
          .filter()
          .savedSearchIdEqualTo(id)
          .findAll();
      final feedIds = feedRefs
          .map((feed) => feed.id)
          .whereType<Id>()
          .toList();
      if (feedIds.isNotEmpty) {
        await isar.feedSavedSearchs.deleteAll(feedIds);
      }
      await isar.savedSearchs.delete(id);
    });
  }

  Future<Id> insert(SavedSearch savedSearch) async {
    return isar.writeTxn(() async {
      var query = isar.savedSearchs
          .filter()
          .sourceIdEqualTo(savedSearch.sourceId)
          .and()
          .itemTypeEqualTo(savedSearch.itemType)
          .and()
          .nameEqualTo(savedSearch.name);
      query = savedSearch.query == null
          ? query.and().queryIsNull()
          : query.and().queryEqualTo(savedSearch.query!);
      query = savedSearch.filtersJson == null
          ? query.and().filtersJsonIsNull()
          : query.and().filtersJsonEqualTo(savedSearch.filtersJson!);
      final existing = await query.findFirst();
      if (existing?.id != null) {
        return existing!.id!;
      }
      return isar.savedSearchs.put(
        SavedSearch(
          sourceId: savedSearch.sourceId,
          itemType: savedSearch.itemType,
          name: savedSearch.name,
          query: savedSearch.query,
          filtersJson: savedSearch.filtersJson,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    });
  }

  Future<void> insertAll(List<SavedSearch> savedSearches) async {
    for (final savedSearch in savedSearches) {
      await insert(savedSearch);
    }
  }
}
