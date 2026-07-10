import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:riverpod/riverpod.dart';
import 'package:mangayomi/l10n/generated/app_localizations.dart';
import 'package:mangayomi/models/sync_preference.dart';
import 'package:mangayomi/modules/more/settings/sync/providers/sync_providers.dart';
import 'package:mangayomi/providers/l10n_providers.dart';
import 'package:mangayomi/router/router.dart';
import 'package:mangayomi/services/sync/sync_backend.dart';
import 'package:mangayomi/services/sync/sync_coordinator.dart';
import 'package:mangayomi/services/sync/sync_tombstone.dart';

enum SyncTriggerEvent {
  chapterSeen,
  chapterOpen,
  appStart,
  appResume,
}

const syncTriggerDebounce = Duration(seconds: 30);

typedef SyncTriggerRead = T Function<T>(ProviderListenable<T> provider);

DateTime? _lastTriggerSyncAt;

bool isSyncTriggerEnabled(SyncPreference prefs, SyncTriggerEvent event) {
  if (!prefs.syncOn || !isSyncConfigured(prefs)) {
    return false;
  }
  return switch (event) {
    SyncTriggerEvent.chapterSeen => prefs.syncOnChapterSeen,
    SyncTriggerEvent.chapterOpen => prefs.syncOnChapterOpen,
    SyncTriggerEvent.appStart => prefs.syncOnAppStart,
    SyncTriggerEvent.appResume => prefs.syncOnAppResume,
  };
}

bool isSyncTriggerDebounced(
  DateTime now, {
  DateTime? lastAt,
  Duration debounce = syncTriggerDebounce,
}) {
  final last = lastAt ?? _lastTriggerSyncAt;
  if (last == null) {
    return false;
  }
  return now.difference(last) < debounce;
}

Future<void> maybeTriggerSync(SyncTriggerRead read, SyncTriggerEvent event) async {
  final prefs = read(synchingProvider(syncId: 1));
  if (!isSyncTriggerEnabled(prefs, event)) {
    return;
  }
  final now = DateTime.now();
  if (isSyncTriggerDebounced(now)) {
    return;
  }
  _lastTriggerSyncAt = now;
  final locale = read(l10nLocaleStateProvider);
  final l10n = lookupAppLocalizations(locale);
  await read(syncCoordinatorProvider(syncId: 1).notifier).startSync(l10n, true);
}

/// Triggers a debounced sync when extensions, feeds, or saved filters change.
Future<void> maybeTriggerMetadataSync() async {
  final context = navigatorKey.currentContext;
  if (context == null) {
    return;
  }
  final container = ProviderScope.containerOf(context);
  await maybeTriggerMetadataSyncRead(container.read);
}

Future<void> maybeTriggerMetadataSyncRead(SyncTriggerRead read) async {
  final prefs = read(synchingProvider(syncId: 1));
  if (!prefs.syncOn || !isSyncConfigured(prefs)) {
    return;
  }
  final now = DateTime.now();
  if (isSyncTriggerDebounced(now)) {
    return;
  }
  _lastTriggerSyncAt = now;
  final locale = read(l10nLocaleStateProvider);
  final l10n = lookupAppLocalizations(locale);
  await read(syncCoordinatorProvider(syncId: 1).notifier).startSync(l10n, true);
}

Future<void> onExtensionInstalled(int sourceId) async {
  await SyncTombstoneStore.clearKeys([
    '${SyncTombstoneEntity.extension.index}|$sourceId',
  ]);
  await maybeTriggerMetadataSync();
}

Future<void> onExtensionUninstalled(int sourceId) async {
  await SyncTombstoneStore.recordExtensionDeleted(sourceId);
  await maybeTriggerMetadataSync();
}
