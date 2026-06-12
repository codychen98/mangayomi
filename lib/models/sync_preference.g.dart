// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_preference.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSyncPreferenceCollection on Isar {
  IsarCollection<SyncPreference> get syncPreferences => this.collection();
}

const SyncPreferenceSchema = CollectionSchema(
  name: r'Sync Preference',
  id: 2788277548653279925,
  properties: {
    r'authToken': PropertySchema(
      id: 0,
      name: r'authToken',
      type: IsarType.string,
    ),
    r'autoSyncFrequency': PropertySchema(
      id: 1,
      name: r'autoSyncFrequency',
      type: IsarType.long,
    ),
    r'email': PropertySchema(id: 2, name: r'email', type: IsarType.string),
    r'lastSyncEtag': PropertySchema(
      id: 3,
      name: r'lastSyncEtag',
      type: IsarType.string,
    ),
    r'lastSyncHistory': PropertySchema(
      id: 4,
      name: r'lastSyncHistory',
      type: IsarType.long,
    ),
    r'lastSyncManga': PropertySchema(
      id: 5,
      name: r'lastSyncManga',
      type: IsarType.long,
    ),
    r'lastSyncUpdate': PropertySchema(
      id: 6,
      name: r'lastSyncUpdate',
      type: IsarType.long,
    ),
    r'server': PropertySchema(id: 7, name: r'server', type: IsarType.string),
    r'syncHistories': PropertySchema(
      id: 8,
      name: r'syncHistories',
      type: IsarType.bool,
    ),
    r'syncOn': PropertySchema(id: 9, name: r'syncOn', type: IsarType.bool),
    r'syncServiceType': PropertySchema(
      id: 10,
      name: r'syncServiceType',
      type: IsarType.byte,
      enumMap: _SyncPreferencesyncServiceTypeEnumValueMap,
    ),
    r'syncSettings': PropertySchema(
      id: 11,
      name: r'syncSettings',
      type: IsarType.bool,
    ),
    r'syncUpdates': PropertySchema(
      id: 12,
      name: r'syncUpdates',
      type: IsarType.bool,
    ),
    r'webDavFolder': PropertySchema(
      id: 13,
      name: r'webDavFolder',
      type: IsarType.string,
    ),
    r'webDavPassword': PropertySchema(
      id: 14,
      name: r'webDavPassword',
      type: IsarType.string,
    ),
    r'webDavUrl': PropertySchema(
      id: 15,
      name: r'webDavUrl',
      type: IsarType.string,
    ),
    r'webDavUsername': PropertySchema(
      id: 16,
      name: r'webDavUsername',
      type: IsarType.string,
    ),
    r'syncOnChapterSeen': PropertySchema(
      id: 17,
      name: r'syncOnChapterSeen',
      type: IsarType.bool,
    ),
    r'syncOnChapterOpen': PropertySchema(
      id: 18,
      name: r'syncOnChapterOpen',
      type: IsarType.bool,
    ),
    r'syncOnAppStart': PropertySchema(
      id: 19,
      name: r'syncOnAppStart',
      type: IsarType.bool,
    ),
    r'syncOnAppResume': PropertySchema(
      id: 20,
      name: r'syncOnAppResume',
      type: IsarType.bool,
    ),
  },

  estimateSize: _syncPreferenceEstimateSize,
  serialize: _syncPreferenceSerialize,
  deserialize: _syncPreferenceDeserialize,
  deserializeProp: _syncPreferenceDeserializeProp,
  idName: r'syncId',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _syncPreferenceGetId,
  getLinks: _syncPreferenceGetLinks,
  attach: _syncPreferenceAttach,
  version: '3.3.2',
);

int _syncPreferenceEstimateSize(
  SyncPreference object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.authToken;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.email;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastSyncEtag;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.server;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.webDavFolder.length * 3;
  {
    final value = object.webDavPassword;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.webDavUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.webDavUsername;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _syncPreferenceSerialize(
  SyncPreference object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.authToken);
  writer.writeLong(offsets[1], object.autoSyncFrequency);
  writer.writeString(offsets[2], object.email);
  writer.writeString(offsets[3], object.lastSyncEtag);
  writer.writeLong(offsets[4], object.lastSyncHistory);
  writer.writeLong(offsets[5], object.lastSyncManga);
  writer.writeLong(offsets[6], object.lastSyncUpdate);
  writer.writeString(offsets[7], object.server);
  writer.writeBool(offsets[8], object.syncHistories);
  writer.writeBool(offsets[9], object.syncOn);
  writer.writeByte(offsets[10], object.syncServiceType.index);
  writer.writeBool(offsets[11], object.syncSettings);
  writer.writeBool(offsets[12], object.syncUpdates);
  writer.writeString(offsets[13], object.webDavFolder);
  writer.writeString(offsets[14], object.webDavPassword);
  writer.writeString(offsets[15], object.webDavUrl);
  writer.writeString(offsets[16], object.webDavUsername);
  writer.writeBool(offsets[17], object.syncOnChapterSeen);
  writer.writeBool(offsets[18], object.syncOnChapterOpen);
  writer.writeBool(offsets[19], object.syncOnAppStart);
  writer.writeBool(offsets[20], object.syncOnAppResume);
}

SyncPreference _syncPreferenceDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SyncPreference(
    authToken: reader.readStringOrNull(offsets[0]),
    autoSyncFrequency: reader.readLongOrNull(offsets[1]) ?? 0,
    email: reader.readStringOrNull(offsets[2]),
    lastSyncEtag: reader.readStringOrNull(offsets[3]),
    lastSyncHistory: reader.readLongOrNull(offsets[4]),
    lastSyncManga: reader.readLongOrNull(offsets[5]),
    lastSyncUpdate: reader.readLongOrNull(offsets[6]),
    server: reader.readStringOrNull(offsets[7]),
    syncId: id,
    syncOn: reader.readBoolOrNull(offsets[9]) ?? false,
    syncServiceType:
        _SyncPreferencesyncServiceTypeValueEnumMap[reader.readByteOrNull(
          offsets[10],
        )] ??
        SyncServiceType.mangayomiServer,
    webDavFolder: reader.readStringOrNull(offsets[13]) ?? 'mangayomi',
    webDavPassword: reader.readStringOrNull(offsets[14]),
    webDavUrl: reader.readStringOrNull(offsets[15]),
    webDavUsername: reader.readStringOrNull(offsets[16]),
  );
  object.syncHistories = reader.readBool(offsets[8]);
  object.syncSettings = reader.readBool(offsets[11]);
  object.syncUpdates = reader.readBool(offsets[12]);
  object.syncOnChapterSeen = reader.readBoolOrNull(offsets[17]) ?? false;
  object.syncOnChapterOpen = reader.readBoolOrNull(offsets[18]) ?? false;
  object.syncOnAppStart = reader.readBoolOrNull(offsets[19]) ?? false;
  object.syncOnAppResume = reader.readBoolOrNull(offsets[20]) ?? false;
  return object;
}

P _syncPreferenceDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 10:
      return (_SyncPreferencesyncServiceTypeValueEnumMap[reader.readByteOrNull(
                offset,
              )] ??
              SyncServiceType.mangayomiServer)
          as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset) ?? 'mangayomi') as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 18:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 19:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 20:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SyncPreferencesyncServiceTypeEnumValueMap = {
  'mangayomiServer': 0,
  'webDav': 1,
};
const _SyncPreferencesyncServiceTypeValueEnumMap = {
  0: SyncServiceType.mangayomiServer,
  1: SyncServiceType.webDav,
};

Id _syncPreferenceGetId(SyncPreference object) {
  return object.syncId ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _syncPreferenceGetLinks(SyncPreference object) {
  return [];
}

void _syncPreferenceAttach(
  IsarCollection<dynamic> col,
  Id id,
  SyncPreference object,
) {
  object.syncId = id;
}

extension SyncPreferenceQueryWhereSort
    on QueryBuilder<SyncPreference, SyncPreference, QWhere> {
  QueryBuilder<SyncPreference, SyncPreference, QAfterWhere> anySyncId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SyncPreferenceQueryWhere
    on QueryBuilder<SyncPreference, SyncPreference, QWhereClause> {
  QueryBuilder<SyncPreference, SyncPreference, QAfterWhereClause> syncIdEqualTo(
    Id syncId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(lower: syncId, upper: syncId),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterWhereClause>
  syncIdNotEqualTo(Id syncId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: syncId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: syncId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: syncId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: syncId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterWhereClause>
  syncIdGreaterThan(Id syncId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: syncId, includeLower: include),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterWhereClause>
  syncIdLessThan(Id syncId, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: syncId, includeUpper: include),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterWhereClause> syncIdBetween(
    Id lowerSyncId,
    Id upperSyncId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerSyncId,
          includeLower: includeLower,
          upper: upperSyncId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SyncPreferenceQueryFilter
    on QueryBuilder<SyncPreference, SyncPreference, QFilterCondition> {
  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  authTokenIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'authToken'),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  authTokenIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'authToken'),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  authTokenEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'authToken',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  authTokenGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'authToken',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  authTokenLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'authToken',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  authTokenBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'authToken',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  authTokenStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'authToken',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  authTokenEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'authToken',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  authTokenContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'authToken',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  authTokenMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'authToken',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  authTokenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'authToken', value: ''),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  authTokenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'authToken', value: ''),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  autoSyncFrequencyEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'autoSyncFrequency', value: value),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  autoSyncFrequencyGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'autoSyncFrequency',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  autoSyncFrequencyLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'autoSyncFrequency',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  autoSyncFrequencyBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'autoSyncFrequency',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  emailIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'email'),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  emailIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'email'),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  emailEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'email',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  emailGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'email',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  emailLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'email',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  emailBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'email',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  emailStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'email',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  emailEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'email',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  emailContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'email',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  emailMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'email',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  emailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'email', value: ''),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  emailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'email', value: ''),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncEtagIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastSyncEtag'),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncEtagIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastSyncEtag'),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncEtagEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lastSyncEtag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncEtagGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastSyncEtag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncEtagLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastSyncEtag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncEtagBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastSyncEtag',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncEtagStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'lastSyncEtag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncEtagEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'lastSyncEtag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncEtagContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'lastSyncEtag',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncEtagMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'lastSyncEtag',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncEtagIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastSyncEtag', value: ''),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncEtagIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'lastSyncEtag', value: ''),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncHistoryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastSyncHistory'),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncHistoryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastSyncHistory'),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncHistoryEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastSyncHistory', value: value),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncHistoryGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastSyncHistory',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncHistoryLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastSyncHistory',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncHistoryBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastSyncHistory',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncMangaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastSyncManga'),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncMangaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastSyncManga'),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncMangaEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastSyncManga', value: value),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncMangaGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastSyncManga',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncMangaLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastSyncManga',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncMangaBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastSyncManga',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncUpdateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastSyncUpdate'),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncUpdateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastSyncUpdate'),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncUpdateEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastSyncUpdate', value: value),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncUpdateGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastSyncUpdate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncUpdateLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastSyncUpdate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  lastSyncUpdateBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastSyncUpdate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  serverIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'server'),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  serverIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'server'),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  serverEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'server',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  serverGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'server',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  serverLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'server',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  serverBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'server',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  serverStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'server',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  serverEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'server',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  serverContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'server',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  serverMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'server',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  serverIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'server', value: ''),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  serverIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'server', value: ''),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  syncHistoriesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncHistories', value: value),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  syncIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'syncId'),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  syncIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'syncId'),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  syncIdEqualTo(Id? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncId', value: value),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  syncIdGreaterThan(Id? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'syncId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  syncIdLessThan(Id? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'syncId',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  syncIdBetween(
    Id? lower,
    Id? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'syncId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  syncOnEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncOn', value: value),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  syncServiceTypeEqualTo(SyncServiceType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncServiceType', value: value),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  syncServiceTypeGreaterThan(SyncServiceType value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'syncServiceType',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  syncServiceTypeLessThan(SyncServiceType value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'syncServiceType',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  syncServiceTypeBetween(
    SyncServiceType lower,
    SyncServiceType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'syncServiceType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  syncSettingsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncSettings', value: value),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  syncUpdatesEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'syncUpdates', value: value),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavFolderEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'webDavFolder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavFolderGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'webDavFolder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavFolderLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'webDavFolder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavFolderBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'webDavFolder',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavFolderStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'webDavFolder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavFolderEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'webDavFolder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavFolderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'webDavFolder',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavFolderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'webDavFolder',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavFolderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'webDavFolder', value: ''),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavFolderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'webDavFolder', value: ''),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavPasswordIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'webDavPassword'),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavPasswordIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'webDavPassword'),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavPasswordEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'webDavPassword',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavPasswordGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'webDavPassword',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavPasswordLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'webDavPassword',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavPasswordBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'webDavPassword',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavPasswordStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'webDavPassword',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavPasswordEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'webDavPassword',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavPasswordContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'webDavPassword',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavPasswordMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'webDavPassword',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavPasswordIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'webDavPassword', value: ''),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavPasswordIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'webDavPassword', value: ''),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'webDavUrl'),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'webDavUrl'),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavUrlEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'webDavUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'webDavUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'webDavUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'webDavUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'webDavUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'webDavUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'webDavUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'webDavUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'webDavUrl', value: ''),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'webDavUrl', value: ''),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavUsernameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'webDavUsername'),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavUsernameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'webDavUsername'),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavUsernameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'webDavUsername',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavUsernameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'webDavUsername',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavUsernameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'webDavUsername',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavUsernameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'webDavUsername',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavUsernameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'webDavUsername',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavUsernameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'webDavUsername',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavUsernameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'webDavUsername',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavUsernameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'webDavUsername',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavUsernameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'webDavUsername', value: ''),
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterFilterCondition>
  webDavUsernameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'webDavUsername', value: ''),
      );
    });
  }
}

extension SyncPreferenceQueryObject
    on QueryBuilder<SyncPreference, SyncPreference, QFilterCondition> {}

extension SyncPreferenceQueryLinks
    on QueryBuilder<SyncPreference, SyncPreference, QFilterCondition> {}

extension SyncPreferenceQuerySortBy
    on QueryBuilder<SyncPreference, SyncPreference, QSortBy> {
  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy> sortByAuthToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authToken', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortByAuthTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authToken', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortByAutoSyncFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoSyncFrequency', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortByAutoSyncFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoSyncFrequency', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy> sortByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy> sortByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortByLastSyncEtag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncEtag', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortByLastSyncEtagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncEtag', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortByLastSyncHistory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncHistory', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortByLastSyncHistoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncHistory', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortByLastSyncManga() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncManga', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortByLastSyncMangaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncManga', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortByLastSyncUpdate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncUpdate', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortByLastSyncUpdateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncUpdate', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy> sortByServer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'server', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortByServerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'server', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortBySyncHistories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncHistories', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortBySyncHistoriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncHistories', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy> sortBySyncOn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncOn', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortBySyncOnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncOn', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortBySyncServiceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncServiceType', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortBySyncServiceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncServiceType', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortBySyncSettings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncSettings', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortBySyncSettingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncSettings', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortBySyncUpdates() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdates', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortBySyncUpdatesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdates', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortByWebDavFolder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webDavFolder', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortByWebDavFolderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webDavFolder', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortByWebDavPassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webDavPassword', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortByWebDavPasswordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webDavPassword', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy> sortByWebDavUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webDavUrl', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortByWebDavUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webDavUrl', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortByWebDavUsername() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webDavUsername', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  sortByWebDavUsernameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webDavUsername', Sort.desc);
    });
  }
}

extension SyncPreferenceQuerySortThenBy
    on QueryBuilder<SyncPreference, SyncPreference, QSortThenBy> {
  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy> thenByAuthToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authToken', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenByAuthTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'authToken', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenByAutoSyncFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoSyncFrequency', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenByAutoSyncFrequencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autoSyncFrequency', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy> thenByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy> thenByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenByLastSyncEtag() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncEtag', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenByLastSyncEtagDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncEtag', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenByLastSyncHistory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncHistory', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenByLastSyncHistoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncHistory', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenByLastSyncManga() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncManga', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenByLastSyncMangaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncManga', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenByLastSyncUpdate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncUpdate', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenByLastSyncUpdateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncUpdate', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy> thenByServer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'server', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenByServerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'server', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenBySyncHistories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncHistories', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenBySyncHistoriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncHistories', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy> thenBySyncId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncId', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenBySyncIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncId', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy> thenBySyncOn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncOn', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenBySyncOnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncOn', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenBySyncServiceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncServiceType', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenBySyncServiceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncServiceType', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenBySyncSettings() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncSettings', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenBySyncSettingsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncSettings', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenBySyncUpdates() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdates', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenBySyncUpdatesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncUpdates', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenByWebDavFolder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webDavFolder', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenByWebDavFolderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webDavFolder', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenByWebDavPassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webDavPassword', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenByWebDavPasswordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webDavPassword', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy> thenByWebDavUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webDavUrl', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenByWebDavUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webDavUrl', Sort.desc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenByWebDavUsername() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webDavUsername', Sort.asc);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QAfterSortBy>
  thenByWebDavUsernameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'webDavUsername', Sort.desc);
    });
  }
}

extension SyncPreferenceQueryWhereDistinct
    on QueryBuilder<SyncPreference, SyncPreference, QDistinct> {
  QueryBuilder<SyncPreference, SyncPreference, QDistinct> distinctByAuthToken({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'authToken', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QDistinct>
  distinctByAutoSyncFrequency() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autoSyncFrequency');
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QDistinct> distinctByEmail({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'email', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QDistinct>
  distinctByLastSyncEtag({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncEtag', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QDistinct>
  distinctByLastSyncHistory() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncHistory');
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QDistinct>
  distinctByLastSyncManga() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncManga');
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QDistinct>
  distinctByLastSyncUpdate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncUpdate');
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QDistinct> distinctByServer({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'server', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QDistinct>
  distinctBySyncHistories() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncHistories');
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QDistinct> distinctBySyncOn() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncOn');
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QDistinct>
  distinctBySyncServiceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncServiceType');
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QDistinct>
  distinctBySyncSettings() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncSettings');
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QDistinct>
  distinctBySyncUpdates() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncUpdates');
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QDistinct>
  distinctByWebDavFolder({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'webDavFolder', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QDistinct>
  distinctByWebDavPassword({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'webDavPassword',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QDistinct> distinctByWebDavUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'webDavUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncPreference, SyncPreference, QDistinct>
  distinctByWebDavUsername({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'webDavUsername',
        caseSensitive: caseSensitive,
      );
    });
  }
}

extension SyncPreferenceQueryProperty
    on QueryBuilder<SyncPreference, SyncPreference, QQueryProperty> {
  QueryBuilder<SyncPreference, int, QQueryOperations> syncIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncId');
    });
  }

  QueryBuilder<SyncPreference, String?, QQueryOperations> authTokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'authToken');
    });
  }

  QueryBuilder<SyncPreference, int, QQueryOperations>
  autoSyncFrequencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autoSyncFrequency');
    });
  }

  QueryBuilder<SyncPreference, String?, QQueryOperations> emailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'email');
    });
  }

  QueryBuilder<SyncPreference, String?, QQueryOperations>
  lastSyncEtagProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncEtag');
    });
  }

  QueryBuilder<SyncPreference, int?, QQueryOperations>
  lastSyncHistoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncHistory');
    });
  }

  QueryBuilder<SyncPreference, int?, QQueryOperations> lastSyncMangaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncManga');
    });
  }

  QueryBuilder<SyncPreference, int?, QQueryOperations>
  lastSyncUpdateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncUpdate');
    });
  }

  QueryBuilder<SyncPreference, String?, QQueryOperations> serverProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'server');
    });
  }

  QueryBuilder<SyncPreference, bool, QQueryOperations> syncHistoriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncHistories');
    });
  }

  QueryBuilder<SyncPreference, bool, QQueryOperations> syncOnProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncOn');
    });
  }

  QueryBuilder<SyncPreference, SyncServiceType, QQueryOperations>
  syncServiceTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncServiceType');
    });
  }

  QueryBuilder<SyncPreference, bool, QQueryOperations> syncSettingsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncSettings');
    });
  }

  QueryBuilder<SyncPreference, bool, QQueryOperations> syncUpdatesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncUpdates');
    });
  }

  QueryBuilder<SyncPreference, String, QQueryOperations>
  webDavFolderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'webDavFolder');
    });
  }

  QueryBuilder<SyncPreference, String?, QQueryOperations>
  webDavPasswordProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'webDavPassword');
    });
  }

  QueryBuilder<SyncPreference, String?, QQueryOperations> webDavUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'webDavUrl');
    });
  }

  QueryBuilder<SyncPreference, String?, QQueryOperations>
  webDavUsernameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'webDavUsername');
    });
  }
}
