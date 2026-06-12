import 'package:mangayomi/l10n/generated/app_localizations.dart';
import 'package:mangayomi/services/sync/sync_coordinator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_server.g.dart';

/// Deprecated — use [syncCoordinatorProvider] instead.
@Deprecated('Use syncCoordinatorProvider instead')
@riverpod
class SyncServer extends _$SyncServer {
  @override
  void build({required int syncId}) {
    ref.keepAlive();
  }

  Future<(bool, String)> login(
    AppLocalizations l10n,
    String server,
    String username,
    String password,
  ) {
    return ref
        .read(syncCoordinatorProvider(syncId: syncId).notifier)
        .authenticate(l10n, server, username, password);
  }

  Future<void> startSync(
    AppLocalizations l10n,
    bool silent, {
    bool upload = false,
    bool download = false,
  }) {
    return ref
        .read(syncCoordinatorProvider(syncId: syncId).notifier)
        .startSync(
          l10n,
          silent,
          upload: upload,
          download: download,
        );
  }
}
