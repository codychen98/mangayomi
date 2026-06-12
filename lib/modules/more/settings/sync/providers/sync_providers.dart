import 'dart:convert';

import 'package:isar_community/isar.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/changed.dart';
import 'package:mangayomi/models/sync_preference.dart';
import 'package:mangayomi/services/sync/sync_service_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'sync_providers.g.dart';

@riverpod
class Synching extends _$Synching {
  @override
  SyncPreference build({required int? syncId}) {
    ref.keepAlive();
    return isar.syncPreferences.getSync(syncId!) ?? SyncPreference(syncId: 1);
  }

  void login(String server, String email, String authToken) {
    isar.writeTxnSync(() {
      isar.syncPreferences.putSync(
        state
          ..server = server
          ..email = email
          ..authToken = authToken,
      );
    });
    ref.invalidateSelf();
  }

  void logout() {
    isar.writeTxnSync(() {
      if (state.syncServiceType == SyncServiceType.webDav) {
        isar.syncPreferences.putSync(
          state
            ..webDavUrl = null
            ..webDavUsername = null
            ..webDavPassword = null
            ..lastSyncEtag = null,
        );
      } else {
        isar.syncPreferences.putSync(state..authToken = null);
      }
    });
    ref.invalidateSelf();
  }

  void setLastSyncManga(int timestamp) {
    isar.writeTxnSync(() {
      isar.syncPreferences.putSync(state..lastSyncManga = timestamp);
    });
  }

  void setLastSyncHistory(int timestamp) {
    isar.writeTxnSync(() {
      isar.syncPreferences.putSync(state..lastSyncHistory = timestamp);
    });
  }

  void setLastSyncUpdate(int timestamp) {
    isar.writeTxnSync(() {
      isar.syncPreferences.putSync(state..lastSyncUpdate = timestamp);
    });
  }

  void setServer(String? server) {
    isar.writeTxnSync(() {
      isar.syncPreferences.putSync(state..server = server);
    });
  }

  void setSyncOn(bool value) {
    isar.writeTxnSync(() {
      isar.syncPreferences.putSync(state..syncOn = value);
    });
  }

  void setAutoSyncFrequency(int value) {
    isar.writeTxnSync(() {
      isar.syncPreferences.putSync(state..autoSyncFrequency = value);
    });
    ref.invalidateSelf();
  }

  void setSyncHistories(bool value) {
    isar.writeTxnSync(() {
      isar.syncPreferences.putSync(state..syncHistories = value);
    });
    ref.invalidateSelf();
  }

  void setSyncUpdates(bool value) {
    isar.writeTxnSync(() {
      isar.syncPreferences.putSync(state..syncUpdates = value);
    });
    ref.invalidateSelf();
  }

  void setSyncSettings(bool value) {
    isar.writeTxnSync(() {
      isar.syncPreferences.putSync(state..syncSettings = value);
    });
    ref.invalidateSelf();
  }

  void setSyncServiceType(SyncServiceType value) {
    isar.writeTxnSync(() {
      isar.syncPreferences.putSync(state..syncServiceType = value);
    });
    ref.invalidateSelf();
  }

  void setWebDavUrl(String? url) {
    final trimmed = url?.trim();
    final urlChanged = state.webDavUrl != trimmed;
    isar.writeTxnSync(() {
      final next = state..webDavUrl = trimmed;
      if (urlChanged) {
        next.lastSyncEtag = null;
      }
      isar.syncPreferences.putSync(next);
    });
    ref.invalidateSelf();
  }

  void setWebDavUsername(String? username) {
    isar.writeTxnSync(() {
      isar.syncPreferences.putSync(state..webDavUsername = username);
    });
    ref.invalidateSelf();
  }

  void setWebDavPassword(String? password) {
    isar.writeTxnSync(() {
      isar.syncPreferences.putSync(state..webDavPassword = password);
    });
    ref.invalidateSelf();
  }

  void setWebDavFolder(String folder) {
    final trimmed = folder.trim();
    final folderChanged = state.webDavFolder != trimmed;
    isar.writeTxnSync(() {
      final next = state..webDavFolder = trimmed;
      if (folderChanged) {
        next.lastSyncEtag = null;
      }
      isar.syncPreferences.putSync(next);
    });
    ref.invalidateSelf();
  }

  void setLastSyncEtag(String? etag) {
    isar.writeTxnSync(() {
      isar.syncPreferences.putSync(state..lastSyncEtag = etag);
    });
    ref.invalidateSelf();
  }

  void setSyncOnChapterSeen(bool value) {
    isar.writeTxnSync(() {
      isar.syncPreferences.putSync(state..syncOnChapterSeen = value);
    });
    ref.invalidateSelf();
  }

  void setSyncOnChapterOpen(bool value) {
    isar.writeTxnSync(() {
      isar.syncPreferences.putSync(state..syncOnChapterOpen = value);
    });
    ref.invalidateSelf();
  }

  void setSyncOnAppStart(bool value) {
    isar.writeTxnSync(() {
      isar.syncPreferences.putSync(state..syncOnAppStart = value);
    });
    ref.invalidateSelf();
  }

  void setSyncOnAppResume(bool value) {
    isar.writeTxnSync(() {
      isar.syncPreferences.putSync(state..syncOnAppResume = value);
    });
    ref.invalidateSelf();
  }

  List<ChangedPart> getAllChangedParts() {
    return isar.changedParts.filter().idIsNotNull().findAllSync();
  }

  List<ChangedPart> getChangedParts(List<ActionType> actionTypes) {
    var query = isar.changedParts
        .filter()
        .idIsNotNull()
        .and()
        .actionTypeEqualTo(actionTypes.first);
    for (final at in actionTypes.skip(1)) {
      query = query.or().actionTypeEqualTo(at);
    }
    return query.findAllSync();
  }

  void addChangedPart(
    ActionType action,
    int? isarId,
    Object data,
    bool writeTxn,
  ) {
    if (!state.syncOn) {
      return;
    }
    final changedPart = isar.changedParts
        .filter()
        .actionTypeEqualTo(action)
        .isarIdEqualTo(isarId)
        .findFirstSync();
    void putChangedPart() {
      if (changedPart != null) {
        isar.changedParts.putSync(
          changedPart
            ..data = jsonEncode(data)
            ..clientDate = DateTime.now().millisecondsSinceEpoch,
        );
      } else {
        isar.changedParts.putSync(
          ChangedPart(
            actionType: action,
            isarId: isarId,
            data: jsonEncode(data),
            clientDate: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      }
    }

    if (writeTxn) {
      isar.writeTxnSync(putChangedPart);
    } else {
      putChangedPart();
    }
  }

  Future<void> addChangedPartAsync(
    ActionType action,
    int? isarId,
    Object data,
    bool writeTxn,
  ) async {
    if (!state.syncOn) {
      return;
    }
    final changedPart = isar.changedParts
        .filter()
        .actionTypeEqualTo(action)
        .isarIdEqualTo(isarId)
        .findFirstSync();
    Future<void> putChangedPart() async {
      if (changedPart != null) {
        await isar.changedParts.put(
          changedPart
            ..data = jsonEncode(data)
            ..clientDate = DateTime.now().millisecondsSinceEpoch,
        );
      } else {
        await isar.changedParts.put(
          ChangedPart(
            actionType: action,
            isarId: isarId,
            data: jsonEncode(data),
            clientDate: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      }
    }

    if (writeTxn) {
      await isar.writeTxn(putChangedPart);
    } else {
      await putChangedPart();
    }
  }

  Future<void> clearChangedParts(List<ActionType> actions, bool txn) async {
    var temp = isar.changedParts.filter().idIsNotNull().and().actionTypeEqualTo(
      actions.first,
    );
    for (ActionType action in actions.skip(1)) {
      temp = temp.or().actionTypeEqualTo(action);
    }
    final changedParts = (await temp.findAll())
        .map((cp) => cp.id as Id)
        .toList();
    if (txn) {
      await isar.writeTxn(() async {
        await isar.changedParts.deleteAll(changedParts);
      });
    } else {
      await isar.changedParts.deleteAll(changedParts);
    }
  }

  void clearAllChangedParts(bool txn) {
    if (txn) {
      isar.writeTxnSync(() => isar.changedParts.clearSync());
    } else {
      isar.changedParts.clearSync();
    }
  }
}
