import 'package:isar_community/isar.dart';
import 'package:mangayomi/models/manga.dart';
part 'feed_saved_search.g.dart';

@collection
@Name("FeedSavedSearch")
class FeedSavedSearch {
  Id? id;

  int sourceId;

  @enumerated
  late ItemType itemType;

  /// Null means Latest (with Popular fallback when source lacks Latest support).
  int? savedSearchId;

  bool global;

  int feedOrder;

  int? updatedAt;

  FeedSavedSearch({
    this.id = Isar.autoIncrement,
    required this.sourceId,
    required this.itemType,
    this.savedSearchId,
    required this.global,
    this.feedOrder = 0,
    this.updatedAt = 0,
  });

  FeedSavedSearch.fromJson(Map<String, dynamic> json)
    : sourceId = json['sourceId'] as int,
      itemType = ItemType.values[json['itemType'] as int? ?? 0],
      savedSearchId = json['savedSearchId'] as int?,
      global = json['global'] as bool,
      feedOrder = json['feedOrder'] as int? ?? 0,
      updatedAt = json['updatedAt'] as int? ?? 0 {
    id = json['id'] as int?;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'sourceId': sourceId,
    'itemType': itemType.index,
    'savedSearchId': savedSearchId,
    'global': global,
    'feedOrder': feedOrder,
    'updatedAt': updatedAt ?? 0,
  };
}
