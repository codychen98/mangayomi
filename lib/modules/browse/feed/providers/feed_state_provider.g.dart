// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(feedGlobalStream)
final feedGlobalStreamProvider = FeedGlobalStreamFamily._();

final class FeedGlobalStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FeedSavedSearch>>,
          List<FeedSavedSearch>,
          Stream<List<FeedSavedSearch>>
        >
    with
        $FutureModifier<List<FeedSavedSearch>>,
        $StreamProvider<List<FeedSavedSearch>> {
  FeedGlobalStreamProvider._({
    required FeedGlobalStreamFamily super.from,
    required ItemType super.argument,
  }) : super(
         retry: null,
         name: r'feedGlobalStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$feedGlobalStreamHash();

  @override
  String toString() {
    return r'feedGlobalStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<FeedSavedSearch>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FeedSavedSearch>> create(Ref ref) {
    final argument = this.argument as ItemType;
    return feedGlobalStream(ref, itemType: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedGlobalStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$feedGlobalStreamHash() => r'50df04821e7c260499421501638c4fccc5242388';

final class FeedGlobalStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<FeedSavedSearch>>, ItemType> {
  FeedGlobalStreamFamily._()
    : super(
        retry: null,
        name: r'feedGlobalStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FeedGlobalStreamProvider call({required ItemType itemType}) =>
      FeedGlobalStreamProvider._(argument: itemType, from: this);

  @override
  String toString() => r'feedGlobalStreamProvider';
}

@ProviderFor(feedBySourceStream)
final feedBySourceStreamProvider = FeedBySourceStreamFamily._();

final class FeedBySourceStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FeedSavedSearch>>,
          List<FeedSavedSearch>,
          Stream<List<FeedSavedSearch>>
        >
    with
        $FutureModifier<List<FeedSavedSearch>>,
        $StreamProvider<List<FeedSavedSearch>> {
  FeedBySourceStreamProvider._({
    required FeedBySourceStreamFamily super.from,
    required ({int sourceId, ItemType itemType}) super.argument,
  }) : super(
         retry: null,
         name: r'feedBySourceStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$feedBySourceStreamHash();

  @override
  String toString() {
    return r'feedBySourceStreamProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<FeedSavedSearch>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FeedSavedSearch>> create(Ref ref) {
    final argument = this.argument as ({int sourceId, ItemType itemType});
    return feedBySourceStream(
      ref,
      sourceId: argument.sourceId,
      itemType: argument.itemType,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FeedBySourceStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$feedBySourceStreamHash() =>
    r'4854ea22431d0167772e33ba14c9a66dccc9f666';

final class FeedBySourceStreamFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<FeedSavedSearch>>,
          ({int sourceId, ItemType itemType})
        > {
  FeedBySourceStreamFamily._()
    : super(
        retry: null,
        name: r'feedBySourceStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FeedBySourceStreamProvider call({
    required int sourceId,
    required ItemType itemType,
  }) => FeedBySourceStreamProvider._(
    argument: (sourceId: sourceId, itemType: itemType),
    from: this,
  );

  @override
  String toString() => r'feedBySourceStreamProvider';
}

@ProviderFor(feedGlobalCount)
final feedGlobalCountProvider = FeedGlobalCountFamily._();

final class FeedGlobalCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  FeedGlobalCountProvider._({
    required FeedGlobalCountFamily super.from,
    required ItemType super.argument,
  }) : super(
         retry: null,
         name: r'feedGlobalCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$feedGlobalCountHash();

  @override
  String toString() {
    return r'feedGlobalCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as ItemType;
    return feedGlobalCount(ref, itemType: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedGlobalCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$feedGlobalCountHash() => r'e0e4a7aa715ffda03b13132c65ece122cda90db5';

final class FeedGlobalCountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, ItemType> {
  FeedGlobalCountFamily._()
    : super(
        retry: null,
        name: r'feedGlobalCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FeedGlobalCountProvider call({required ItemType itemType}) =>
      FeedGlobalCountProvider._(argument: itemType, from: this);

  @override
  String toString() => r'feedGlobalCountProvider';
}

@ProviderFor(feedBySourceCount)
final feedBySourceCountProvider = FeedBySourceCountFamily._();

final class FeedBySourceCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  FeedBySourceCountProvider._({
    required FeedBySourceCountFamily super.from,
    required ({int sourceId, ItemType itemType}) super.argument,
  }) : super(
         retry: null,
         name: r'feedBySourceCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$feedBySourceCountHash();

  @override
  String toString() {
    return r'feedBySourceCountProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as ({int sourceId, ItemType itemType});
    return feedBySourceCount(
      ref,
      sourceId: argument.sourceId,
      itemType: argument.itemType,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FeedBySourceCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$feedBySourceCountHash() => r'87ea9e3ab6459c932fd3f66d5dbbd9ca36573fe1';

final class FeedBySourceCountFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<int>,
          ({int sourceId, ItemType itemType})
        > {
  FeedBySourceCountFamily._()
    : super(
        retry: null,
        name: r'feedBySourceCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FeedBySourceCountProvider call({
    required int sourceId,
    required ItemType itemType,
  }) => FeedBySourceCountProvider._(
    argument: (sourceId: sourceId, itemType: itemType),
    from: this,
  );

  @override
  String toString() => r'feedBySourceCountProvider';
}

@ProviderFor(hasTooManyGlobalFeeds)
final hasTooManyGlobalFeedsProvider = HasTooManyGlobalFeedsFamily._();

final class HasTooManyGlobalFeedsProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  HasTooManyGlobalFeedsProvider._({
    required HasTooManyGlobalFeedsFamily super.from,
    required ItemType super.argument,
  }) : super(
         retry: null,
         name: r'hasTooManyGlobalFeedsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hasTooManyGlobalFeedsHash();

  @override
  String toString() {
    return r'hasTooManyGlobalFeedsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as ItemType;
    return hasTooManyGlobalFeeds(ref, itemType: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HasTooManyGlobalFeedsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hasTooManyGlobalFeedsHash() =>
    r'ef4c114ab27091d2fcf8f8c27b749e3ac91de2fc';

final class HasTooManyGlobalFeedsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, ItemType> {
  HasTooManyGlobalFeedsFamily._()
    : super(
        retry: null,
        name: r'hasTooManyGlobalFeedsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HasTooManyGlobalFeedsProvider call({required ItemType itemType}) =>
      HasTooManyGlobalFeedsProvider._(argument: itemType, from: this);

  @override
  String toString() => r'hasTooManyGlobalFeedsProvider';
}

@ProviderFor(savedSearchBySourceStream)
final savedSearchBySourceStreamProvider = SavedSearchBySourceStreamFamily._();

final class SavedSearchBySourceStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SavedSearch>>,
          List<SavedSearch>,
          Stream<List<SavedSearch>>
        >
    with
        $FutureModifier<List<SavedSearch>>,
        $StreamProvider<List<SavedSearch>> {
  SavedSearchBySourceStreamProvider._({
    required SavedSearchBySourceStreamFamily super.from,
    required ({int sourceId, ItemType itemType}) super.argument,
  }) : super(
         retry: null,
         name: r'savedSearchBySourceStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$savedSearchBySourceStreamHash();

  @override
  String toString() {
    return r'savedSearchBySourceStreamProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<SavedSearch>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SavedSearch>> create(Ref ref) {
    final argument = this.argument as ({int sourceId, ItemType itemType});
    return savedSearchBySourceStream(
      ref,
      sourceId: argument.sourceId,
      itemType: argument.itemType,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SavedSearchBySourceStreamProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$savedSearchBySourceStreamHash() =>
    r'06439a7ddaaee4a95c3cecab21719ef6219b3beb';

final class SavedSearchBySourceStreamFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<SavedSearch>>,
          ({int sourceId, ItemType itemType})
        > {
  SavedSearchBySourceStreamFamily._()
    : super(
        retry: null,
        name: r'savedSearchBySourceStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SavedSearchBySourceStreamProvider call({
    required int sourceId,
    required ItemType itemType,
  }) => SavedSearchBySourceStreamProvider._(
    argument: (sourceId: sourceId, itemType: itemType),
    from: this,
  );

  @override
  String toString() => r'savedSearchBySourceStreamProvider';
}

@ProviderFor(deleteFeedItem)
final deleteFeedItemProvider = DeleteFeedItemFamily._();

final class DeleteFeedItemProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  DeleteFeedItemProvider._({
    required DeleteFeedItemFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'deleteFeedItemProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deleteFeedItemHash();

  @override
  String toString() {
    return r'deleteFeedItemProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as int;
    return deleteFeedItem(ref, feedId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteFeedItemProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deleteFeedItemHash() => r'dce30f61b93ba7619a31ad1a2d9cb1c983cdbc87';

final class DeleteFeedItemFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, int> {
  DeleteFeedItemFamily._()
    : super(
        retry: null,
        name: r'deleteFeedItemProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeleteFeedItemProvider call({required int feedId}) =>
      DeleteFeedItemProvider._(argument: feedId, from: this);

  @override
  String toString() => r'deleteFeedItemProvider';
}

@ProviderFor(insertFeedItem)
final insertFeedItemProvider = InsertFeedItemFamily._();

final class InsertFeedItemProvider
    extends $FunctionalProvider<AsyncValue<Id>, Id, FutureOr<Id>>
    with $FutureModifier<Id>, $FutureProvider<Id> {
  InsertFeedItemProvider._({
    required InsertFeedItemFamily super.from,
    required FeedSavedSearch super.argument,
  }) : super(
         retry: null,
         name: r'insertFeedItemProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$insertFeedItemHash();

  @override
  String toString() {
    return r'insertFeedItemProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Id> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Id> create(Ref ref) {
    final argument = this.argument as FeedSavedSearch;
    return insertFeedItem(ref, feed: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is InsertFeedItemProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$insertFeedItemHash() => r'a109858f68af32e6c9b3ed6c2044c9e48050b291';

final class InsertFeedItemFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Id>, FeedSavedSearch> {
  InsertFeedItemFamily._()
    : super(
        retry: null,
        name: r'insertFeedItemProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InsertFeedItemProvider call({required FeedSavedSearch feed}) =>
      InsertFeedItemProvider._(argument: feed, from: this);

  @override
  String toString() => r'insertFeedItemProvider';
}

@ProviderFor(reorderFeedItem)
final reorderFeedItemProvider = ReorderFeedItemFamily._();

final class ReorderFeedItemProvider
    extends
        $FunctionalProvider<
          AsyncValue<FeedReorderResult>,
          FeedReorderResult,
          FutureOr<FeedReorderResult>
        >
    with
        $FutureModifier<FeedReorderResult>,
        $FutureProvider<FeedReorderResult> {
  ReorderFeedItemProvider._({
    required ReorderFeedItemFamily super.from,
    required ({FeedSavedSearch feed, int newIndex, bool global}) super.argument,
  }) : super(
         retry: null,
         name: r'reorderFeedItemProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$reorderFeedItemHash();

  @override
  String toString() {
    return r'reorderFeedItemProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<FeedReorderResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FeedReorderResult> create(Ref ref) {
    final argument =
        this.argument as ({FeedSavedSearch feed, int newIndex, bool global});
    return reorderFeedItem(
      ref,
      feed: argument.feed,
      newIndex: argument.newIndex,
      global: argument.global,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ReorderFeedItemProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$reorderFeedItemHash() => r'6deb4efc84785b471c4b0516b5e7fa1aca9c0107';

final class ReorderFeedItemFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<FeedReorderResult>,
          ({FeedSavedSearch feed, int newIndex, bool global})
        > {
  ReorderFeedItemFamily._()
    : super(
        retry: null,
        name: r'reorderFeedItemProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ReorderFeedItemProvider call({
    required FeedSavedSearch feed,
    required int newIndex,
    required bool global,
  }) => ReorderFeedItemProvider._(
    argument: (feed: feed, newIndex: newIndex, global: global),
    from: this,
  );

  @override
  String toString() => r'reorderFeedItemProvider';
}

@ProviderFor(insertSavedSearch)
final insertSavedSearchProvider = InsertSavedSearchFamily._();

final class InsertSavedSearchProvider
    extends $FunctionalProvider<AsyncValue<Id>, Id, FutureOr<Id>>
    with $FutureModifier<Id>, $FutureProvider<Id> {
  InsertSavedSearchProvider._({
    required InsertSavedSearchFamily super.from,
    required SavedSearch super.argument,
  }) : super(
         retry: null,
         name: r'insertSavedSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$insertSavedSearchHash();

  @override
  String toString() {
    return r'insertSavedSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Id> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Id> create(Ref ref) {
    final argument = this.argument as SavedSearch;
    return insertSavedSearch(ref, savedSearch: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is InsertSavedSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$insertSavedSearchHash() => r'3e73aed93b244c0ad1e7a99ba5221a24f51d939f';

final class InsertSavedSearchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Id>, SavedSearch> {
  InsertSavedSearchFamily._()
    : super(
        retry: null,
        name: r'insertSavedSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InsertSavedSearchProvider call({required SavedSearch savedSearch}) =>
      InsertSavedSearchProvider._(argument: savedSearch, from: this);

  @override
  String toString() => r'insertSavedSearchProvider';
}

@ProviderFor(deleteSavedSearch)
final deleteSavedSearchProvider = DeleteSavedSearchFamily._();

final class DeleteSavedSearchProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  DeleteSavedSearchProvider._({
    required DeleteSavedSearchFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'deleteSavedSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deleteSavedSearchHash();

  @override
  String toString() {
    return r'deleteSavedSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as int;
    return deleteSavedSearch(ref, savedSearchId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteSavedSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deleteSavedSearchHash() => r'3bb857d8974462351fbf84a0eae1e60b52c18623';

final class DeleteSavedSearchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, int> {
  DeleteSavedSearchFamily._()
    : super(
        retry: null,
        name: r'deleteSavedSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeleteSavedSearchProvider call({required int savedSearchId}) =>
      DeleteSavedSearchProvider._(argument: savedSearchId, from: this);

  @override
  String toString() => r'deleteSavedSearchProvider';
}
