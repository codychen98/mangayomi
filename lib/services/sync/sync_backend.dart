import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangayomi/l10n/generated/app_localizations.dart';
import 'package:mangayomi/models/sync_preference.dart';
import 'package:mangayomi/services/sync/sync_service_type.dart';

/// Contract for sync backends (mangayomi-server HTTP API or WebDAV).
abstract class SyncBackend {
  Future<(bool, String)> authenticate({
    required Ref ref,
    required AppLocalizations l10n,
    required int syncId,
    required String server,
    required String username,
    required String password,
    String? folder,
  });

  Future<void> startSync({
    required Ref ref,
    required AppLocalizations l10n,
    required int syncId,
    required bool silent,
    bool upload = false,
    bool download = false,
  });
}

/// Whether the active sync service has enough credentials to sync.
bool isSyncConfigured(SyncPreference prefs) {
  switch (prefs.syncServiceType) {
    case SyncServiceType.mangayomiServer:
      return prefs.authToken?.isNotEmpty ?? false;
    case SyncServiceType.webDav:
      return (prefs.webDavUrl?.trim().isNotEmpty ?? false) &&
          (prefs.webDavUsername?.isNotEmpty ?? false) &&
          (prefs.webDavPassword?.isNotEmpty ?? false);
  }
}
