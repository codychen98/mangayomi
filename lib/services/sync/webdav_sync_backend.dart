import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangayomi/eval/model/m_bridge.dart';
import 'package:mangayomi/l10n/generated/app_localizations.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/sync_preference.dart';
import 'package:mangayomi/modules/more/settings/sync/providers/sync_providers.dart';
import 'package:mangayomi/services/sync/sync_backend.dart';
import 'package:mangayomi/services/sync/sync_merger.dart';
import 'package:mangayomi/services/sync/sync_snapshot.dart';
import 'package:mangayomi/services/sync/webdav_client.dart';

/// Snapshot size above which a progress toast is shown before upload/download.
const int webDavLargeSnapshotThresholdBytes = 1024 * 1024;

/// Orchestrates WebDAV pull, merge, push, and local apply.
class WebDavSyncBackend implements SyncBackend {
  WebDavSyncBackend({
    WebDavClient Function(SyncPreference prefs)? clientFactory,
  }) : _clientFactory = clientFactory ?? _defaultClientFactory;

  final WebDavClient Function(SyncPreference prefs) _clientFactory;

  static WebDavClient _defaultClientFactory(SyncPreference prefs) {
    return WebDavClient(
      url: prefs.webDavUrl ?? '',
      username: prefs.webDavUsername ?? '',
      password: prefs.webDavPassword ?? '',
      folder: prefs.webDavFolder,
    );
  }

  @override
  Future<(bool, String)> authenticate({
    required Ref ref,
    required AppLocalizations l10n,
    required int syncId,
    required String server,
    required String username,
    required String password,
    String? folder,
  }) async {
    final client = WebDavClient(
      url: server,
      username: username,
      password: password,
      folder: folder ?? 'mangayomi',
    );
    try {
      final validationError = client.validateSettings();
      if (validationError != null) {
        return (false, validationError);
      }
      final notifier = ref.read(synchingProvider(syncId: syncId).notifier);
      notifier.setWebDavUrl(server.trim());
      notifier.setWebDavUsername(username);
      notifier.setWebDavPassword(password);
      if (folder != null && folder.isNotEmpty) {
        notifier.setWebDavFolder(folder);
      }
      botToast(l10n.sync_logged);
      return (true, '');
    } finally {
      client.close();
    }
  }

  @override
  Future<void> startSync({
    required Ref ref,
    required AppLocalizations l10n,
    required int syncId,
    required bool silent,
    bool upload = false,
    bool download = false,
  }) async {
    await sync(
      ref,
      l10n,
      syncId: syncId,
      uploadOnly: upload,
      downloadOnly: download,
      silent: silent,
    );
  }

  Future<void> sync(
    Ref ref,
    AppLocalizations l10n, {
    int syncId = 1,
    bool uploadOnly = false,
    bool downloadOnly = false,
    bool silent = false,
  }) async {
    if (!silent) {
      botToast(l10n.sync_starting, second: 500);
    }

    final prefs = ref.read(synchingProvider(syncId: syncId));
    final syncNotifier = ref.read(synchingProvider(syncId: syncId).notifier);
    final client = _clientFactory(prefs);

    try {
      final validationError = client.validateSettings();
      if (validationError != null) {
        _showError(l10n, l10n.webdav_not_configured);
        return;
      }

      await client.ensureFolderExists();

      if (downloadOnly) {
        await _downloadOnly(
          ref: ref,
          l10n: l10n,
          client: client,
          syncNotifier: syncNotifier,
          prefs: prefs,
          syncId: syncId,
          silent: silent,
        );
        return;
      }

      final localSnapshot = buildLocalSnapshot(prefs);

      if (uploadOnly) {
        await _uploadOnly(
          l10n: l10n,
          client: client,
          syncNotifier: syncNotifier,
          prefs: prefs,
          syncId: syncId,
          localSnapshot: localSnapshot,
          silent: silent,
        );
        return;
      }

      await _bidirectionalSync(
        ref: ref,
        l10n: l10n,
        client: client,
        syncNotifier: syncNotifier,
        prefs: prefs,
        syncId: syncId,
        localSnapshot: localSnapshot,
        silent: silent,
      );
    } on WebDavException catch (error) {
      _showError(l10n, messageForWebDavException(l10n, error));
    } catch (error) {
      _showError(l10n, 'Network error: $error');
    } finally {
      client.close();
    }
  }

  Future<void> _bidirectionalSync({
    required Ref ref,
    required AppLocalizations l10n,
    required WebDavClient client,
    required Synching syncNotifier,
    required SyncPreference prefs,
    required int syncId,
    required SyncSnapshot localSnapshot,
    required bool silent,
  }) async {
    final pullResult = await client.pull(ifNoneMatch: prefs.lastSyncEtag);
    final mergedSnapshot = resolveSnapshotForBidirectionalSync(
      local: localSnapshot,
      pullResult: pullResult,
    );
    final ifMatch = ifMatchEtagForPush(pullResult: pullResult, prefs: prefs);
    final mergedBody = encodeSyncSnapshot(mergedSnapshot);
    _maybeShowLargeSyncToast(l10n, mergedBody.length, silent);

    final pushResult = await client.push(
      mergedBody,
      ifMatch: ifMatch,
    );
    if (pushResult.conflict) {
      _showError(l10n, l10n.webdav_sync_conflict);
      return;
    }
    if (!pushResult.success) {
      _showError(l10n, l10n.sync_failed);
      return;
    }

    await applySyncSnapshotToDatabase(mergedSnapshot, ref);
    _storeEtag(syncNotifier, pushResult.newEtag ?? pullResult.etag ?? prefs.lastSyncEtag);
    _updateSyncTimestamps(syncNotifier, prefs);
    ref.invalidate(synchingProvider(syncId: syncId));

    if (!silent) {
      botToast(l10n.sync_finished, second: 2);
    }
  }

  Future<void> _uploadOnly({
    required AppLocalizations l10n,
    required WebDavClient client,
    required Synching syncNotifier,
    required SyncPreference prefs,
    required int syncId,
    required SyncSnapshot localSnapshot,
    required bool silent,
  }) async {
    final pullResult = await client.pull(ifNoneMatch: prefs.lastSyncEtag);
    final ifMatch = pullResult.notFound
        ? null
        : ifMatchEtagForPush(pullResult: pullResult, prefs: prefs);
    final localBody = encodeSyncSnapshot(localSnapshot);
    _maybeShowLargeSyncToast(l10n, localBody.length, silent);

    final pushResult = await client.push(
      localBody,
      ifMatch: ifMatch,
    );
    if (pushResult.conflict) {
      _showError(l10n, l10n.webdav_sync_conflict);
      return;
    }
    if (!pushResult.success) {
      _showError(l10n, l10n.sync_failed);
      return;
    }

    _storeEtag(syncNotifier, pushResult.newEtag ?? pullResult.etag ?? prefs.lastSyncEtag);
    _updateSyncTimestamps(syncNotifier, prefs);

    if (!silent) {
      botToast(l10n.sync_finished, second: 2);
    }
  }

  Future<void> _downloadOnly({
    required Ref ref,
    required AppLocalizations l10n,
    required WebDavClient client,
    required Synching syncNotifier,
    required SyncPreference prefs,
    required int syncId,
    required bool silent,
  }) async {
    final pullResult = await client.pull();
    if (pullResult.notFound) {
      _showError(l10n, 'No remote sync file found');
      return;
    }
    if (pullResult.notModified || pullResult.bytes == null) {
      _showError(l10n, l10n.sync_failed);
      return;
    }

    _maybeShowLargeSyncToast(l10n, pullResult.bytes!.length, silent);

    final remoteSnapshot = decodeSyncSnapshot(pullResult.bytes!);
    await applySyncSnapshotToDatabase(remoteSnapshot, ref);
    _storeEtag(syncNotifier, pullResult.etag);
    _updateSyncTimestamps(syncNotifier, prefs);
    ref.invalidate(synchingProvider(syncId: syncId));

    if (!silent) {
      botToast(l10n.sync_finished, second: 2);
    }
  }

  void _storeEtag(Synching syncNotifier, String? etag) {
    if (etag != null && etag.isNotEmpty) {
      syncNotifier.setLastSyncEtag(etag);
    }
  }

  void _updateSyncTimestamps(Synching syncNotifier, SyncPreference prefs) {
    final now = DateTime.now().millisecondsSinceEpoch;
    syncNotifier.setLastSyncManga(now);
    if (prefs.syncHistories) {
      syncNotifier.setLastSyncHistory(now);
    }
    if (prefs.syncUpdates) {
      syncNotifier.setLastSyncUpdate(now);
    }
  }

  void _showError(AppLocalizations l10n, String message) {
    botToast(message, second: 5);
  }

  void _maybeShowLargeSyncToast(
    AppLocalizations l10n,
    int byteLength,
    bool silent,
  ) {
    if (!silent && byteLength >= webDavLargeSnapshotThresholdBytes) {
      botToast(l10n.webdav_sync_large, second: 2);
    }
  }
}

/// Maps [WebDavException] to a user-facing message.
String messageForWebDavException(
  AppLocalizations l10n,
  WebDavException error,
) {
  if (error.statusCode == 401) {
    return l10n.webdav_invalid_credentials;
  }
  return error.message;
}

/// Resolves the merged snapshot for bidirectional sync from a pull result.
SyncSnapshot resolveSnapshotForBidirectionalSync({
  required SyncSnapshot local,
  required WebDavPullResult pullResult,
}) {
  if (pullResult.notFound || pullResult.notModified) {
    return local;
  }
  final bytes = pullResult.bytes;
  if (bytes == null) {
    return local;
  }
  final remote = decodeSyncSnapshot(bytes);
  return mergeSyncSnapshots(local, remote);
}

/// ETag to send with PUT for optimistic locking.
String? ifMatchEtagForPush({
  required WebDavPullResult pullResult,
  required SyncPreference prefs,
}) {
  if (pullResult.notFound) {
    return null;
  }
  return pullResult.etag ?? prefs.lastSyncEtag;
}

Uint8List encodeSyncSnapshot(SyncSnapshot snapshot) {
  return Uint8List.fromList(utf8.encode(jsonEncode(snapshot.toJson())));
}

SyncSnapshot decodeSyncSnapshot(Uint8List bytes) {
  final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
  return SyncSnapshot.fromJson(json);
}
