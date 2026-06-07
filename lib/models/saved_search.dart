import 'package:isar_community/isar.dart';
import 'package:mangayomi/models/manga.dart';
part 'saved_search.g.dart';

@collection
@Name("SavedSearch")
class SavedSearch {
  Id? id;

  int sourceId;

  @enumerated
  late ItemType itemType;

  String name;

  String? query;

  String? filtersJson;

  int? updatedAt;

  SavedSearch({
    this.id = Isar.autoIncrement,
    required this.sourceId,
    required this.itemType,
    required this.name,
    this.query,
    this.filtersJson,
    this.updatedAt = 0,
  });

  SavedSearch.fromJson(Map<String, dynamic> json)
    : sourceId = json['sourceId'] as int,
      itemType = ItemType.values[json['itemType'] as int? ?? 0],
      name = json['name'] as String,
      query = json['query'] as String?,
      filtersJson = json['filtersJson'] as String?,
      updatedAt = json['updatedAt'] as int? ?? 0 {
    id = json['id'] as int?;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sourceId': sourceId,
    'itemType': itemType.index,
    'name': name,
    'query': query,
    'filtersJson': filtersJson,
    'updatedAt': updatedAt ?? 0,
  };
}
