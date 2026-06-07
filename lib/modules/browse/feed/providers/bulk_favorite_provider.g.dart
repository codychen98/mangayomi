// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bulk_favorite_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FeedBulkSelectionMode)
final feedBulkSelectionModeProvider = FeedBulkSelectionModeFamily._();

final class FeedBulkSelectionModeProvider
    extends $NotifierProvider<FeedBulkSelectionMode, bool> {
  FeedBulkSelectionModeProvider._({
    required FeedBulkSelectionModeFamily super.from,
    required FeedBulkScope super.argument,
  }) : super(
         retry: null,
         name: r'feedBulkSelectionModeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$feedBulkSelectionModeHash();

  @override
  String toString() {
    return r'feedBulkSelectionModeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FeedBulkSelectionMode create() => FeedBulkSelectionMode();

  @override
  bool operator ==(Object other) {
    return other is FeedBulkSelectionModeProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode => argument.hashCode;
}

String _$feedBulkSelectionModeHash() =>
    r'a1b2c3d4e5f6789012345678feedbulkmode01';

final class FeedBulkSelectionModeFamily extends $Family
    with $ClassFamilyOverride<FeedBulkSelectionMode, bool, bool, bool, FeedBulkScope> {
  FeedBulkSelectionModeFamily._()
    : super(
        retry: null,
        name: r'feedBulkSelectionModeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FeedBulkSelectionModeProvider call(FeedBulkScope scope) =>
      FeedBulkSelectionModeProvider._(argument: scope, from: this);

  @override
  String toString() => r'feedBulkSelectionModeProvider';
}

abstract class _$FeedBulkSelectionMode extends $Notifier<bool> {
  late final _$args = ref.$arg as FeedBulkScope;
  FeedBulkScope get scope => _$args;

  bool build(FeedBulkScope scope);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(FeedBulkSelection)
final feedBulkSelectionProvider = FeedBulkSelectionFamily._();

final class FeedBulkSelectionProvider
    extends $NotifierProvider<FeedBulkSelection, Map<String, FeedSelectionEntry>> {
  FeedBulkSelectionProvider._({
    required FeedBulkSelectionFamily super.from,
    required FeedBulkScope super.argument,
  }) : super(
         retry: null,
         name: r'feedBulkSelectionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$feedBulkSelectionHash();

  @override
  String toString() {
    return r'feedBulkSelectionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FeedBulkSelection create() => FeedBulkSelection();

  @override
  bool operator ==(Object other) {
    return other is FeedBulkSelectionProvider && other.argument == argument;
  }

  @override
  int get hashCode => argument.hashCode;
}

String _$feedBulkSelectionHash() =>
    r'b2c3d4e5f6789012345678feedbulkselect02';

final class FeedBulkSelectionFamily extends $Family
    with
        $ClassFamilyOverride<
          FeedBulkSelection,
          Map<String, FeedSelectionEntry>,
          Map<String, FeedSelectionEntry>,
          Map<String, FeedSelectionEntry>,
          FeedBulkScope
        > {
  FeedBulkSelectionFamily._()
    : super(
        retry: null,
        name: r'feedBulkSelectionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FeedBulkSelectionProvider call(FeedBulkScope scope) =>
      FeedBulkSelectionProvider._(argument: scope, from: this);

  @override
  String toString() => r'feedBulkSelectionProvider';
}

abstract class _$FeedBulkSelection
    extends $Notifier<Map<String, FeedSelectionEntry>> {
  late final _$args = ref.$arg as FeedBulkScope;
  FeedBulkScope get scope => _$args;

  Map<String, FeedSelectionEntry> build(FeedBulkScope scope);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, FeedSelectionEntry>, Map<String, FeedSelectionEntry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, FeedSelectionEntry>,
                Map<String, FeedSelectionEntry>
              >,
              Map<String, FeedSelectionEntry>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(FeedBulkFavoriteRunning)
final feedBulkFavoriteRunningProvider = FeedBulkFavoriteRunningFamily._();

final class FeedBulkFavoriteRunningProvider
    extends $NotifierProvider<FeedBulkFavoriteRunning, bool> {
  FeedBulkFavoriteRunningProvider._({
    required FeedBulkFavoriteRunningFamily super.from,
    required FeedBulkScope super.argument,
  }) : super(
         retry: null,
         name: r'feedBulkFavoriteRunningProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$feedBulkFavoriteRunningHash();

  @override
  String toString() {
    return r'feedBulkFavoriteRunningProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FeedBulkFavoriteRunning create() => FeedBulkFavoriteRunning();

  @override
  bool operator ==(Object other) {
    return other is FeedBulkFavoriteRunningProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode => argument.hashCode;
}

String _$feedBulkFavoriteRunningHash() =>
    r'c3d4e5f6789012345678feedbulkrunning03';

final class FeedBulkFavoriteRunningFamily extends $Family
    with $ClassFamilyOverride<FeedBulkFavoriteRunning, bool, bool, bool, FeedBulkScope> {
  FeedBulkFavoriteRunningFamily._()
    : super(
        retry: null,
        name: r'feedBulkFavoriteRunningProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FeedBulkFavoriteRunningProvider call(FeedBulkScope scope) =>
      FeedBulkFavoriteRunningProvider._(argument: scope, from: this);

  @override
  String toString() => r'feedBulkFavoriteRunningProvider';
}

abstract class _$FeedBulkFavoriteRunning extends $Notifier<bool> {
  late final _$args = ref.$arg as FeedBulkScope;
  FeedBulkScope get scope => _$args;

  bool build(FeedBulkScope scope);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
