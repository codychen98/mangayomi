// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getAllMangaStream)
final getAllMangaStreamProvider = GetAllMangaStreamFamily._();

final class GetAllMangaStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Manga>>,
          List<Manga>,
          Stream<List<Manga>>
        >
    with $FutureModifier<List<Manga>>, $StreamProvider<List<Manga>> {
  GetAllMangaStreamProvider._({
    required GetAllMangaStreamFamily super.from,
    required ({int? categoryId, ItemType itemType}) super.argument,
  }) : super(
         retry: null,
         name: r'getAllMangaStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getAllMangaStreamHash();

  @override
  String toString() {
    return r'getAllMangaStreamProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<Manga>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Manga>> create(Ref ref) {
    final argument = this.argument as ({int? categoryId, ItemType itemType});
    return getAllMangaStream(
      ref,
      categoryId: argument.categoryId,
      itemType: argument.itemType,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GetAllMangaStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getAllMangaStreamHash() => r'5e86a22a68ca1a52aefa9c0bc675d284369beac5';

final class GetAllMangaStreamFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<Manga>>,
          ({int? categoryId, ItemType itemType})
        > {
  GetAllMangaStreamFamily._()
    : super(
        retry: null,
        name: r'getAllMangaStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GetAllMangaStreamProvider call({
    required int? categoryId,
    required ItemType itemType,
  }) => GetAllMangaStreamProvider._(
    argument: (categoryId: categoryId, itemType: itemType),
    from: this,
  );

  @override
  String toString() => r'getAllMangaStreamProvider';
}

@ProviderFor(getAllMangaWithoutCategoriesStream)
final getAllMangaWithoutCategoriesStreamProvider =
    GetAllMangaWithoutCategoriesStreamFamily._();

final class GetAllMangaWithoutCategoriesStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Manga>>,
          List<Manga>,
          Stream<List<Manga>>
        >
    with $FutureModifier<List<Manga>>, $StreamProvider<List<Manga>> {
  GetAllMangaWithoutCategoriesStreamProvider._({
    required GetAllMangaWithoutCategoriesStreamFamily super.from,
    required ItemType super.argument,
  }) : super(
         retry: null,
         name: r'getAllMangaWithoutCategoriesStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$getAllMangaWithoutCategoriesStreamHash();

  @override
  String toString() {
    return r'getAllMangaWithoutCategoriesStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Manga>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Manga>> create(Ref ref) {
    final argument = this.argument as ItemType;
    return getAllMangaWithoutCategoriesStream(ref, itemType: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GetAllMangaWithoutCategoriesStreamProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getAllMangaWithoutCategoriesStreamHash() =>
    r'61ea54070c7e87a45aeabce5fd21366faaf4ae6d';

final class GetAllMangaWithoutCategoriesStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Manga>>, ItemType> {
  GetAllMangaWithoutCategoriesStreamFamily._()
    : super(
        retry: null,
        name: r'getAllMangaWithoutCategoriesStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GetAllMangaWithoutCategoriesStreamProvider call({
    required ItemType itemType,
  }) => GetAllMangaWithoutCategoriesStreamProvider._(
    argument: itemType,
    from: this,
  );

  @override
  String toString() => r'getAllMangaWithoutCategoriesStreamProvider';
}

@ProviderFor(getMangaByLibrarySourceStream)
final getMangaByLibrarySourceStreamProvider =
    GetMangaByLibrarySourceStreamFamily._();

final class GetMangaByLibrarySourceStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Manga>>,
          List<Manga>,
          Stream<List<Manga>>
        >
    with $FutureModifier<List<Manga>>, $StreamProvider<List<Manga>> {
  GetMangaByLibrarySourceStreamProvider._({
    required GetMangaByLibrarySourceStreamFamily super.from,
    required ({ItemType itemType, LibrarySourceGroup sourceGroup})
    super.argument,
  }) : super(
         retry: null,
         name: r'getMangaByLibrarySourceStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getMangaByLibrarySourceStreamHash();

  @override
  String toString() {
    return r'getMangaByLibrarySourceStreamProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<Manga>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Manga>> create(Ref ref) {
    final argument =
        this.argument as ({ItemType itemType, LibrarySourceGroup sourceGroup});
    return getMangaByLibrarySourceStream(
      ref,
      itemType: argument.itemType,
      sourceGroup: argument.sourceGroup,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GetMangaByLibrarySourceStreamProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getMangaByLibrarySourceStreamHash() =>
    r'a1b2c3d4e5f6789012345678abcdef0123456789';

final class GetMangaByLibrarySourceStreamFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<Manga>>,
          ({ItemType itemType, LibrarySourceGroup sourceGroup})
        > {
  GetMangaByLibrarySourceStreamFamily._()
    : super(
        retry: null,
        name: r'getMangaByLibrarySourceStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GetMangaByLibrarySourceStreamProvider call({
    required ItemType itemType,
    required LibrarySourceGroup sourceGroup,
  }) => GetMangaByLibrarySourceStreamProvider._(
    argument: (itemType: itemType, sourceGroup: sourceGroup),
    from: this,
  );

  @override
  String toString() => r'getMangaByLibrarySourceStreamProvider';
}

@ProviderFor(getSettingsStream)
final getSettingsStreamProvider = GetSettingsStreamProvider._();

final class GetSettingsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Settings>>,
          List<Settings>,
          Stream<List<Settings>>
        >
    with $FutureModifier<List<Settings>>, $StreamProvider<List<Settings>> {
  GetSettingsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getSettingsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getSettingsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Settings>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Settings>> create(Ref ref) {
    return getSettingsStream(ref);
  }
}

String _$getSettingsStreamHash() => r'c5a51e0e3473b25d2365025832a27ed2cc029b27';
