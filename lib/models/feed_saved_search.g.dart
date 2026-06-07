// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_saved_search.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetFeedSavedSearchCollection on Isar {
  IsarCollection<FeedSavedSearch> get feedSavedSearchs => this.collection();
}

const FeedSavedSearchSchema = CollectionSchema(
  name: r'FeedSavedSearch',
  id: -279896339983334165,
  properties: {
    r'feedOrder': PropertySchema(
      id: 0,
      name: r'feedOrder',
      type: IsarType.long,
    ),
    r'global': PropertySchema(id: 1, name: r'global', type: IsarType.bool),
    r'itemType': PropertySchema(
      id: 2,
      name: r'itemType',
      type: IsarType.byte,
      enumMap: _FeedSavedSearchitemTypeEnumValueMap,
    ),
    r'savedSearchId': PropertySchema(
      id: 3,
      name: r'savedSearchId',
      type: IsarType.long,
    ),
    r'sourceId': PropertySchema(id: 4, name: r'sourceId', type: IsarType.long),
    r'updatedAt': PropertySchema(
      id: 5,
      name: r'updatedAt',
      type: IsarType.long,
    ),
  },

  estimateSize: _feedSavedSearchEstimateSize,
  serialize: _feedSavedSearchSerialize,
  deserialize: _feedSavedSearchDeserialize,
  deserializeProp: _feedSavedSearchDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _feedSavedSearchGetId,
  getLinks: _feedSavedSearchGetLinks,
  attach: _feedSavedSearchAttach,
  version: '3.3.2',
);

int _feedSavedSearchEstimateSize(
  FeedSavedSearch object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _feedSavedSearchSerialize(
  FeedSavedSearch object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.feedOrder);
  writer.writeBool(offsets[1], object.global);
  writer.writeByte(offsets[2], object.itemType.index);
  writer.writeLong(offsets[3], object.savedSearchId);
  writer.writeLong(offsets[4], object.sourceId);
  writer.writeLong(offsets[5], object.updatedAt);
}

FeedSavedSearch _feedSavedSearchDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = FeedSavedSearch(
    feedOrder: reader.readLongOrNull(offsets[0]) ?? 0,
    global: reader.readBool(offsets[1]),
    id: id,
    itemType:
        _FeedSavedSearchitemTypeValueEnumMap[reader.readByteOrNull(
          offsets[2],
        )] ??
        ItemType.manga,
    savedSearchId: reader.readLongOrNull(offsets[3]),
    sourceId: reader.readLong(offsets[4]),
    updatedAt: reader.readLongOrNull(offsets[5]),
  );
  return object;
}

P _feedSavedSearchDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (_FeedSavedSearchitemTypeValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              ItemType.manga)
          as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _FeedSavedSearchitemTypeEnumValueMap = {
  'manga': 0,
  'anime': 1,
  'novel': 2,
};
const _FeedSavedSearchitemTypeValueEnumMap = {
  0: ItemType.manga,
  1: ItemType.anime,
  2: ItemType.novel,
};

Id _feedSavedSearchGetId(FeedSavedSearch object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _feedSavedSearchGetLinks(FeedSavedSearch object) {
  return [];
}

void _feedSavedSearchAttach(
  IsarCollection<dynamic> col,
  Id id,
  FeedSavedSearch object,
) {
  object.id = id;
}

extension FeedSavedSearchQueryWhereSort
    on QueryBuilder<FeedSavedSearch, FeedSavedSearch, QWhere> {
  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension FeedSavedSearchQueryWhere
    on QueryBuilder<FeedSavedSearch, FeedSavedSearch, QWhereClause> {
  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterWhereClause>
  idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension FeedSavedSearchQueryFilter
    on QueryBuilder<FeedSavedSearch, FeedSavedSearch, QFilterCondition> {
  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  feedOrderEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'feedOrder', value: value),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  feedOrderGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'feedOrder',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  feedOrderLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'feedOrder',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  feedOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'feedOrder',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  globalEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'global', value: value),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'id'),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'id'),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  idEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  idGreaterThan(Id? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  idLessThan(Id? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  idBetween(
    Id? lower,
    Id? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  itemTypeEqualTo(ItemType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'itemType', value: value),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  itemTypeGreaterThan(ItemType value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'itemType',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  itemTypeLessThan(ItemType value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'itemType',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  itemTypeBetween(
    ItemType lower,
    ItemType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'itemType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  savedSearchIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'savedSearchId'),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  savedSearchIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'savedSearchId'),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  savedSearchIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'savedSearchId', value: value),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  savedSearchIdGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'savedSearchId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  savedSearchIdLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'savedSearchId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  savedSearchIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'savedSearchId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  sourceIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sourceId', value: value),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  sourceIdGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sourceId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  sourceIdLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sourceId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  sourceIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sourceId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  updatedAtEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  updatedAtGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  updatedAtLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'updatedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterFilterCondition>
  updatedAtBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'updatedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension FeedSavedSearchQueryObject
    on QueryBuilder<FeedSavedSearch, FeedSavedSearch, QFilterCondition> {}

extension FeedSavedSearchQueryLinks
    on QueryBuilder<FeedSavedSearch, FeedSavedSearch, QFilterCondition> {}

extension FeedSavedSearchQuerySortBy
    on QueryBuilder<FeedSavedSearch, FeedSavedSearch, QSortBy> {
  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy>
  sortByFeedOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedOrder', Sort.asc);
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy>
  sortByFeedOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedOrder', Sort.desc);
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy> sortByGlobal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'global', Sort.asc);
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy>
  sortByGlobalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'global', Sort.desc);
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy>
  sortByItemType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemType', Sort.asc);
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy>
  sortByItemTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemType', Sort.desc);
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy>
  sortBySavedSearchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedSearchId', Sort.asc);
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy>
  sortBySavedSearchIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedSearchId', Sort.desc);
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy>
  sortBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.asc);
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy>
  sortBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.desc);
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy>
  sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy>
  sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension FeedSavedSearchQuerySortThenBy
    on QueryBuilder<FeedSavedSearch, FeedSavedSearch, QSortThenBy> {
  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy>
  thenByFeedOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedOrder', Sort.asc);
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy>
  thenByFeedOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'feedOrder', Sort.desc);
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy> thenByGlobal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'global', Sort.asc);
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy>
  thenByGlobalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'global', Sort.desc);
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy>
  thenByItemType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemType', Sort.asc);
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy>
  thenByItemTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemType', Sort.desc);
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy>
  thenBySavedSearchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedSearchId', Sort.asc);
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy>
  thenBySavedSearchIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'savedSearchId', Sort.desc);
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy>
  thenBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.asc);
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy>
  thenBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.desc);
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy>
  thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QAfterSortBy>
  thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension FeedSavedSearchQueryWhereDistinct
    on QueryBuilder<FeedSavedSearch, FeedSavedSearch, QDistinct> {
  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QDistinct>
  distinctByFeedOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'feedOrder');
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QDistinct> distinctByGlobal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'global');
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QDistinct>
  distinctByItemType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemType');
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QDistinct>
  distinctBySavedSearchId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'savedSearchId');
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QDistinct>
  distinctBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceId');
    });
  }

  QueryBuilder<FeedSavedSearch, FeedSavedSearch, QDistinct>
  distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension FeedSavedSearchQueryProperty
    on QueryBuilder<FeedSavedSearch, FeedSavedSearch, QQueryProperty> {
  QueryBuilder<FeedSavedSearch, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<FeedSavedSearch, int, QQueryOperations> feedOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'feedOrder');
    });
  }

  QueryBuilder<FeedSavedSearch, bool, QQueryOperations> globalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'global');
    });
  }

  QueryBuilder<FeedSavedSearch, ItemType, QQueryOperations> itemTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemType');
    });
  }

  QueryBuilder<FeedSavedSearch, int?, QQueryOperations>
  savedSearchIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'savedSearchId');
    });
  }

  QueryBuilder<FeedSavedSearch, int, QQueryOperations> sourceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceId');
    });
  }

  QueryBuilder<FeedSavedSearch, int?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
