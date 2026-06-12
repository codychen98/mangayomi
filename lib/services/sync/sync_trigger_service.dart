import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangayomi/l10n/generated/app_localizations.dart';
import 'package:mangayomi/models/sync_preference.dart';
import 'package:mangayomi/modules/more/settings/sync/providers/sync_providers.dart';
import 'package:mangayomi/providers/l10n_providers.dart';
import 'package:mangayomi/services/sync/sync_backend.dart';
import 'package:mangayomi/services/sync/sync_coordinator.dart';

enum SyncTriggerEvent {
  chapterSeen,
  chapterOpen,
  appStart,
  appResume,
}

const syncTriggerDebounce = Duration(seconds: 30);

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

Future<void> maybeTriggerSync(Ref ref, SyncTriggerEvent event) async {
  final prefs = ref.read(synchingProvider(syncId: 1));
  if (!isSyncTriggerEnabled(prefs, event)) {
    return;
  }
  final now = DateTime.now();
  if (isSyncTriggerDebounced(now)) {
    return;
  }
  _lastTriggerSyncAt = now;
  final locale = ref.read(l10nLocaleStateProvider);
  final l10n = lookupAppLocalizations(locale);
  await ref
      .read(syncCoordinatorProvider(syncId: 1).notifier)
      .startSync(l10n, true);
}
