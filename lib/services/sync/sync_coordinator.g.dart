// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SyncCoordinator)
final syncCoordinatorProvider = SyncCoordinatorFamily._();

final class SyncCoordinatorProvider
    extends $NotifierProvider<SyncCoordinator, void> {
  SyncCoordinatorProvider._({
    required SyncCoordinatorFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'syncCoordinatorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$syncCoordinatorHash();

  @override
  String toString() {
    return r'syncCoordinatorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SyncCoordinator create() => SyncCoordinator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SyncCoordinatorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$syncCoordinatorHash() => r'a3f8c2e91b4d7056e8c1f2a9b0d3e5f7c8a1b2d4';

final class SyncCoordinatorFamily extends $Family
    with $ClassFamilyOverride<SyncCoordinator, void, void, void, int> {
  SyncCoordinatorFamily._()
    : super(
        retry: null,
        name: r'syncCoordinatorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SyncCoordinatorProvider call({required int syncId}) =>
      SyncCoordinatorProvider._(argument: syncId, from: this);

  @override
  String toString() => r'syncCoordinatorProvider';
}

abstract class _$SyncCoordinator extends $Notifier<void> {
  late final _$args = ref.$arg as int;
  int get syncId => _$args;

  void build({required int syncId});
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(syncId: _$args));
  }
}
