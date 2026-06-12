import 'package:mangayomi/l10n/generated/app_localizations.dart';
import 'package:mangayomi/modules/more/settings/sync/providers/sync_providers.dart';
import 'package:mangayomi/services/sync/mangayomi_server_backend.dart';
import 'package:mangayomi/services/sync/sync_backend.dart';
import 'package:mangayomi/services/sync/sync_service_type.dart';
import 'package:mangayomi/services/sync/webdav_sync_backend.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_coordinator.g.dart';

@riverpod
class SyncCoordinator extends _$SyncCoordinator {
  static bool _syncInProgress = false;

  @override
  void build({required int syncId}) {
    ref.keepAlive();
  }

  Future<(bool, String)> authenticate(
    AppLocalizations l10n,
    String server,
    String username,
    String password, {
    String? folder,
  }) {
    final prefs = ref.read(synchingProvider(syncId: syncId));
    return _backendFor(prefs.syncServiceType).authenticate(
      ref: ref,
      l10n: l10n,
      syncId: syncId,
      server: server,
      username: username,
      password: password,
      folder: folder,
    );
  }

  Future<void> startSync(
    AppLocalizations l10n,
    bool silent, {
    bool upload = false,
    bool download = false,
  }) async {
    if (_syncInProgress) {
      return;
    }
    _syncInProgress = true;
    try {
      final prefs = ref.read(synchingProvider(syncId: syncId));
      await _backendFor(prefs.syncServiceType).startSync(
        ref: ref,
        l10n: l10n,
        syncId: syncId,
        silent: silent,
        upload: upload,
        download: download,
      );
    } finally {
      _syncInProgress = false;
    }
  }

  SyncBackend _backendFor(SyncServiceType type) {
    switch (type) {
      case SyncServiceType.mangayomiServer:
        return MangayomiServerBackend(syncId: syncId);
      case SyncServiceType.webDav:
        return WebDavSyncBackend();
    }
  }
}
