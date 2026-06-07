// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_search.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSavedSearchCollection on Isar {
  IsarCollection<SavedSearch> get savedSearchs => this.collection();
}

const SavedSearchSchema = CollectionSchema(
  name: r'SavedSearch',
  id: -4038919227263572545,
  properties: {
    r'filtersJson': PropertySchema(
      id: 0,
      name: r'filtersJson',
      type: IsarType.string,
    ),
    r'itemType': PropertySchema(
      id: 1,
      name: r'itemType',
      type: IsarType.byte,
      enumMap: _SavedSearchitemTypeEnumValueMap,
    ),
    r'name': PropertySchema(id: 2, name: r'name', type: IsarType.string),
    r'query': PropertySchema(id: 3, name: r'query', type: IsarType.string),
    r'sourceId': PropertySchema(id: 4, name: r'sourceId', type: IsarType.long),
    r'updatedAt': PropertySchema(
      id: 5,
      name: r'updatedAt',
      type: IsarType.long,
    ),
  },

  estimateSize: _savedSearchEstimateSize,
  serialize: _savedSearchSerialize,
  deserialize: _savedSearchDeserialize,
  deserializeProp: _savedSearchDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _savedSearchGetId,
  getLinks: _savedSearchGetLinks,
  attach: _savedSearchAttach,
  version: '3.3.2',
);

int _savedSearchEstimateSize(
  SavedSearch object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.filtersJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.query;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _savedSearchSerialize(
  SavedSearch object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.filtersJson);
  writer.writeByte(offsets[1], object.itemType.index);
  writer.writeString(offsets[2], object.name);
  writer.writeString(offsets[3], object.query);
  writer.writeLong(offsets[4], object.sourceId);
  writer.writeLong(offsets[5], object.updatedAt);
}

SavedSearch _savedSearchDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SavedSearch(
    filtersJson: reader.readStringOrNull(offsets[0]),
    id: id,
    itemType:
        _SavedSearchitemTypeValueEnumMap[reader.readByteOrNull(offsets[1])] ??
        ItemType.manga,
    name: reader.readString(offsets[2]),
    query: reader.readStringOrNull(offsets[3]),
    sourceId: reader.readLong(offsets[4]),
    updatedAt: reader.readLongOrNull(offsets[5]),
  );
  return object;
}

P _savedSearchDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (_SavedSearchitemTypeValueEnumMap[reader.readByteOrNull(offset)] ??
              ItemType.manga)
          as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SavedSearchitemTypeEnumValueMap = {'manga': 0, 'anime': 1, 'novel': 2};
const _SavedSearchitemTypeValueEnumMap = {
  0: ItemType.manga,
  1: ItemType.anime,
  2: ItemType.novel,
};

Id _savedSearchGetId(SavedSearch object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _savedSearchGetLinks(SavedSearch object) {
  return [];
}

void _savedSearchAttach(
  IsarCollection<dynamic> col,
  Id id,
  SavedSearch object,
) {
  object.id = id;
}

extension SavedSearchQueryWhereSort
    on QueryBuilder<SavedSearch, SavedSearch, QWhere> {
  QueryBuilder<SavedSearch, SavedSearch, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SavedSearchQueryWhere
    on QueryBuilder<SavedSearch, SavedSearch, QWhereClause> {
  QueryBuilder<SavedSearch, SavedSearch, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
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

  QueryBuilder<SavedSearch, SavedSearch, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterWhereClause> idBetween(
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

extension SavedSearchQueryFilter
    on QueryBuilder<SavedSearch, SavedSearch, QFilterCondition> {
  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
  filtersJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'filtersJson'),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
  filtersJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'filtersJson'),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
  filtersJsonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'filtersJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
  filtersJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'filtersJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
  filtersJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'filtersJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
  filtersJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'filtersJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
  filtersJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'filtersJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
  filtersJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'filtersJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
  filtersJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'filtersJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
  filtersJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'filtersJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
  filtersJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'filtersJson', value: ''),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
  filtersJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'filtersJson', value: ''),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'id'),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'id'),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> idEqualTo(
    Id? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> idGreaterThan(
    Id? value, {
    bool include = false,
  }) {
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

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> idLessThan(
    Id? value, {
    bool include = false,
  }) {
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

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> itemTypeEqualTo(
    ItemType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'itemType', value: value),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
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

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
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

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> itemTypeBetween(
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

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'name',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> nameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'name',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> nameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'name',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
  nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'name', value: ''),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> queryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'query'),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
  queryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'query'),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> queryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'query',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
  queryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'query',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> queryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'query',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> queryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'query',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> queryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'query',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> queryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'query',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> queryContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'query',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> queryMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'query',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> queryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'query', value: ''),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
  queryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'query', value: ''),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> sourceIdEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sourceId', value: value),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
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

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
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

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition> sourceIdBetween(
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

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
  updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
  updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'updatedAt'),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
  updatedAtEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'updatedAt', value: value),
      );
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
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

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
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

  QueryBuilder<SavedSearch, SavedSearch, QAfterFilterCondition>
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

extension SavedSearchQueryObject
    on QueryBuilder<SavedSearch, SavedSearch, QFilterCondition> {}

extension SavedSearchQueryLinks
    on QueryBuilder<SavedSearch, SavedSearch, QFilterCondition> {}

extension SavedSearchQuerySortBy
    on QueryBuilder<SavedSearch, SavedSearch, QSortBy> {
  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> sortByFiltersJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filtersJson', Sort.asc);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> sortByFiltersJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filtersJson', Sort.desc);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> sortByItemType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemType', Sort.asc);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> sortByItemTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemType', Sort.desc);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> sortByQuery() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'query', Sort.asc);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> sortByQueryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'query', Sort.desc);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> sortBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.asc);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> sortBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.desc);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SavedSearchQuerySortThenBy
    on QueryBuilder<SavedSearch, SavedSearch, QSortThenBy> {
  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> thenByFiltersJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filtersJson', Sort.asc);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> thenByFiltersJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'filtersJson', Sort.desc);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> thenByItemType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemType', Sort.asc);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> thenByItemTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemType', Sort.desc);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> thenByQuery() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'query', Sort.asc);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> thenByQueryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'query', Sort.desc);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> thenBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.asc);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> thenBySourceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceId', Sort.desc);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension SavedSearchQueryWhereDistinct
    on QueryBuilder<SavedSearch, SavedSearch, QDistinct> {
  QueryBuilder<SavedSearch, SavedSearch, QDistinct> distinctByFiltersJson({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'filtersJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QDistinct> distinctByItemType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemType');
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QDistinct> distinctByQuery({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'query', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QDistinct> distinctBySourceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceId');
    });
  }

  QueryBuilder<SavedSearch, SavedSearch, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension SavedSearchQueryProperty
    on QueryBuilder<SavedSearch, SavedSearch, QQueryProperty> {
  QueryBuilder<SavedSearch, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SavedSearch, String?, QQueryOperations> filtersJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'filtersJson');
    });
  }

  QueryBuilder<SavedSearch, ItemType, QQueryOperations> itemTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemType');
    });
  }

  QueryBuilder<SavedSearch, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<SavedSearch, String?, QQueryOperations> queryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'query');
    });
  }

  QueryBuilder<SavedSearch, int, QQueryOperations> sourceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceId');
    });
  }

  QueryBuilder<SavedSearch, int?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
