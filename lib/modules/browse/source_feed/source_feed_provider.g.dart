// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'source_feed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ensureSourceFeedDefaults)
final ensureSourceFeedDefaultsProvider = EnsureSourceFeedDefaultsFamily._();

final class EnsureSourceFeedDefaultsProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  EnsureSourceFeedDefaultsProvider._({
    required EnsureSourceFeedDefaultsFamily super.from,
    required ({int sourceId, ItemType itemType}) super.argument,
  }) : super(
         retry: null,
         name: r'ensureSourceFeedDefaultsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ensureSourceFeedDefaultsHash();

  @override
  String toString() {
    return r'ensureSourceFeedDefaultsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as ({int sourceId, ItemType itemType});
    return ensureSourceFeedDefaults(
      ref,
      sourceId: argument.sourceId,
      itemType: argument.itemType,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EnsureSourceFeedDefaultsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ensureSourceFeedDefaultsHash() =>
    r'a1b2c3d4e5f6789012345678abcdef01';

final class EnsureSourceFeedDefaultsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<void>,
          ({int sourceId, ItemType itemType})
        > {
  EnsureSourceFeedDefaultsFamily._()
    : super(
        retry: null,
        name: r'ensureSourceFeedDefaultsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EnsureSourceFeedDefaultsProvider call({
    required int sourceId,
    required ItemType itemType,
  }) => EnsureSourceFeedDefaultsProvider._(
    argument: (sourceId: sourceId, itemType: itemType),
    from: this,
  );

  @override
  String toString() => r'ensureSourceFeedDefaultsProvider';
}

@ProviderFor(refreshSourceFeedRows)
final refreshSourceFeedRowsProvider = RefreshSourceFeedRowsFamily._();

final class RefreshSourceFeedRowsProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  RefreshSourceFeedRowsProvider._({
    required RefreshSourceFeedRowsFamily super.from,
    required ({int sourceId, ItemType itemType}) super.argument,
  }) : super(
         retry: null,
         name: r'refreshSourceFeedRowsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$refreshSourceFeedRowsHash();

  @override
  String toString() {
    return r'refreshSourceFeedRowsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as ({int sourceId, ItemType itemType});
    return refreshSourceFeedRows(
      ref,
      sourceId: argument.sourceId,
      itemType: argument.itemType,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RefreshSourceFeedRowsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$refreshSourceFeedRowsHash() =>
    r'b2c3d4e5f6789012345678abcdef012345';

final class RefreshSourceFeedRowsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<void>,
          ({int sourceId, ItemType itemType})
        > {
  RefreshSourceFeedRowsFamily._()
    : super(
        retry: null,
        name: r'refreshSourceFeedRowsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RefreshSourceFeedRowsProvider call({
    required int sourceId,
    required ItemType itemType,
  }) => RefreshSourceFeedRowsProvider._(
    argument: (sourceId: sourceId, itemType: itemType),
    from: this,
  );

  @override
  String toString() => r'refreshSourceFeedRowsProvider';
}
