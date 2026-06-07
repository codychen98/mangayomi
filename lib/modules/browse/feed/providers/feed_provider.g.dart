// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(feedRow)
final feedRowProvider = FeedRowFamily._();

final class FeedRowProvider
    extends
        $FunctionalProvider<
          AsyncValue<FeedRowState>,
          FeedRowState,
          FutureOr<FeedRowState>
        >
    with $FutureModifier<FeedRowState>, $FutureProvider<FeedRowState> {
  FeedRowProvider._({
    required FeedRowFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'feedRowProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$feedRowHash();

  @override
  String toString() {
    return r'feedRowProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<FeedRowState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FeedRowState> create(Ref ref) {
    final argument = this.argument as int;
    return feedRow(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedRowProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$feedRowHash() => r'f8a2c1d4e5b6a7c8d9e0f1a2b3c4d5e6f7a8b9c0';

final class FeedRowFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<FeedRowState>, int> {
  FeedRowFamily._()
    : super(
        retry: null,
        name: r'feedRowProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FeedRowProvider call(int feedId) =>
      FeedRowProvider._(argument: feedId, from: this);

  @override
  String toString() => r'feedRowProvider';
}

@ProviderFor(refreshFeedRows)
final refreshFeedRowsProvider = RefreshFeedRowsFamily._();

final class RefreshFeedRowsProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  RefreshFeedRowsProvider._({
    required RefreshFeedRowsFamily super.from,
    required ItemType super.argument,
  }) : super(
         retry: null,
         name: r'refreshFeedRowsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$refreshFeedRowsHash();

  @override
  String toString() {
    return r'refreshFeedRowsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as ItemType;
    return refreshFeedRows(ref, itemType: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RefreshFeedRowsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$refreshFeedRowsHash() => r'a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0';

final class RefreshFeedRowsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, ItemType> {
  RefreshFeedRowsFamily._()
    : super(
        retry: null,
        name: r'refreshFeedRowsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RefreshFeedRowsProvider call({required ItemType itemType}) =>
      RefreshFeedRowsProvider._(argument: itemType, from: this);

  @override
  String toString() => r'refreshFeedRowsProvider';
}
