// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'library_update_preferences.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

extension GetLibraryUpdatePreferencesCollection on Isar {
  IsarCollection<LibraryUpdatePreferences> get libraryUpdatePreferences =>
      this.collection();
}

const LibraryUpdatePreferencesSchema = CollectionSchema(
  name: r'LibraryUpdatePreferences',
  id: -6728394759283746512,
  properties: {
    r'unseenUpdatesCountManga': PropertySchema(
      id: 0,
      name: r'unseenUpdatesCountManga',
      type: IsarType.long,
    ),
    r'unseenUpdatesCountAnime': PropertySchema(
      id: 1,
      name: r'unseenUpdatesCountAnime',
      type: IsarType.long,
    ),
    r'unseenUpdatesCountNovel': PropertySchema(
      id: 2,
      name: r'unseenUpdatesCountNovel',
      type: IsarType.long,
    ),
    r'showUpdatesTabBadge': PropertySchema(
      id: 3,
      name: r'showUpdatesTabBadge',
      type: IsarType.bool,
    ),
    r'mangaUpdateCategoriesInclude': PropertySchema(
      id: 4,
      name: r'mangaUpdateCategoriesInclude',
      type: IsarType.longList,
    ),
    r'mangaUpdateCategoriesExclude': PropertySchema(
      id: 5,
      name: r'mangaUpdateCategoriesExclude',
      type: IsarType.longList,
    ),
    r'animeUpdateCategoriesInclude': PropertySchema(
      id: 6,
      name: r'animeUpdateCategoriesInclude',
      type: IsarType.longList,
    ),
    r'animeUpdateCategoriesExclude': PropertySchema(
      id: 7,
      name: r'animeUpdateCategoriesExclude',
      type: IsarType.longList,
    ),
    r'novelUpdateCategoriesInclude': PropertySchema(
      id: 8,
      name: r'novelUpdateCategoriesInclude',
      type: IsarType.longList,
    ),
    r'novelUpdateCategoriesExclude': PropertySchema(
      id: 9,
      name: r'novelUpdateCategoriesExclude',
      type: IsarType.longList,
    ),
  },
  estimateSize: _libraryUpdatePreferencesEstimateSize,
  serialize: _libraryUpdatePreferencesSerialize,
  deserialize: _libraryUpdatePreferencesDeserialize,
  deserializeProp: _libraryUpdatePreferencesDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _libraryUpdatePreferencesGetId,
  getLinks: _libraryUpdatePreferencesGetLinks,
  attach: _libraryUpdatePreferencesAttach,
  version: '3.3.2',
);

int _libraryUpdatePreferencesEstimateSize(
  LibraryUpdatePreferences object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.mangaUpdateCategoriesInclude.length * 8;
  bytesCount += 3 + object.mangaUpdateCategoriesExclude.length * 8;
  bytesCount += 3 + object.animeUpdateCategoriesInclude.length * 8;
  bytesCount += 3 + object.animeUpdateCategoriesExclude.length * 8;
  bytesCount += 3 + object.novelUpdateCategoriesInclude.length * 8;
  bytesCount += 3 + object.novelUpdateCategoriesExclude.length * 8;
  return bytesCount;
}

void _libraryUpdatePreferencesSerialize(
  LibraryUpdatePreferences object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.unseenUpdatesCountManga);
  writer.writeLong(offsets[1], object.unseenUpdatesCountAnime);
  writer.writeLong(offsets[2], object.unseenUpdatesCountNovel);
  writer.writeBool(offsets[3], object.showUpdatesTabBadge);
  writer.writeLongList(offsets[4], object.mangaUpdateCategoriesInclude);
  writer.writeLongList(offsets[5], object.mangaUpdateCategoriesExclude);
  writer.writeLongList(offsets[6], object.animeUpdateCategoriesInclude);
  writer.writeLongList(offsets[7], object.animeUpdateCategoriesExclude);
  writer.writeLongList(offsets[8], object.novelUpdateCategoriesInclude);
  writer.writeLongList(offsets[9], object.novelUpdateCategoriesExclude);
}

LibraryUpdatePreferences _libraryUpdatePreferencesDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  return LibraryUpdatePreferences(
    id: id,
    unseenUpdatesCountManga: reader.readLong(offsets[0]),
    unseenUpdatesCountAnime: reader.readLong(offsets[1]),
    unseenUpdatesCountNovel: reader.readLong(offsets[2]),
    showUpdatesTabBadge: reader.readBool(offsets[3]),
    mangaUpdateCategoriesInclude:
        reader.readLongList(offsets[4]) ?? const [],
    mangaUpdateCategoriesExclude:
        reader.readLongList(offsets[5]) ?? const [],
    animeUpdateCategoriesInclude:
        reader.readLongList(offsets[6]) ?? const [],
    animeUpdateCategoriesExclude:
        reader.readLongList(offsets[7]) ?? const [],
    novelUpdateCategoriesInclude:
        reader.readLongList(offsets[8]) ?? const [],
    novelUpdateCategoriesExclude:
        reader.readLongList(offsets[9]) ?? const [],
  );
}

P _libraryUpdatePreferencesDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
    case 1:
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
    case 5:
    case 6:
    case 7:
    case 8:
    case 9:
      return (reader.readLongList(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _libraryUpdatePreferencesGetId(LibraryUpdatePreferences object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _libraryUpdatePreferencesGetLinks(
  LibraryUpdatePreferences object,
) {
  return [];
}

void _libraryUpdatePreferencesAttach(
  IsarCollection<dynamic> col,
  Id id,
  LibraryUpdatePreferences object,
) {
  object.id = id;
}

extension LibraryUpdatePreferencesQueryWhereSort
    on QueryBuilder<LibraryUpdatePreferences, LibraryUpdatePreferences, QWhere> {
  QueryBuilder<LibraryUpdatePreferences, LibraryUpdatePreferences, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LibraryUpdatePreferencesQueryWhere
    on
        QueryBuilder<
          LibraryUpdatePreferences,
          LibraryUpdatePreferences,
          QWhereClause
        > {
  QueryBuilder<LibraryUpdatePreferences, LibraryUpdatePreferences, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }
}
