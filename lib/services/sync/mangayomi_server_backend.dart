import 'dart:convert';

import 'package:flutter_qjs/quickjs/ffi.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:mangayomi/eval/model/m_bridge.dart';
import 'package:mangayomi/l10n/generated/app_localizations.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/category.dart';
import 'package:mangayomi/models/changed.dart';
import 'package:mangayomi/models/chapter.dart';
import 'package:mangayomi/models/history.dart';
import 'package:mangayomi/models/manga.dart';
import 'package:mangayomi/models/settings.dart';
import 'package:mangayomi/models/track.dart';
import 'package:mangayomi/models/update.dart';
import 'package:mangayomi/modules/more/settings/appearance/providers/blend_level_state_provider.dart';
import 'package:mangayomi/modules/more/settings/appearance/providers/flex_scheme_color_state_provider.dart';
import 'package:mangayomi/modules/more/settings/appearance/providers/pure_black_dark_mode_state_provider.dart';
import 'package:mangayomi/modules/more/settings/appearance/providers/theme_mode_state_provider.dart';
import 'package:mangayomi/modules/more/settings/browse/providers/browse_state_provider.dart';
import 'package:mangayomi/modules/more/settings/sync/providers/sync_providers.dart';
import 'package:mangayomi/providers/l10n_providers.dart';
import 'package:mangayomi/services/http/m_client.dart';
import 'package:mangayomi/services/sync/sync_backend.dart';

/// Delta sync backend for the mangayomi-server HTTP API.
class MangayomiServerBackend implements SyncBackend {
  MangayomiServerBackend({required this.syncId});

  final int syncId;
  final http = MClient.init(reqcopyWith: {'useDartHttpClient': true});

  static const String _loginUrl = '/login';
  static const String _syncMangaUrl = '/sync/manga';
  static const String _syncHistoryUrl = '/sync/histories';
  static const String _syncUpdateUrl = '/sync/updates';
  static const String _syncSettingsUrl = '/sync/settings';

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
    server = server.isNotEmpty && server[server.length - 1] == '/'
        ? server.substring(0, server.length - 1)
        : server;
    try {
      final response = await http.post(
        Uri.parse('$server$_loginUrl'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': username, 'password': password}),
      );
      final cookieHeader = response.headers['set-cookie'];
      final startIdx = cookieHeader?.indexOf('id=') ?? -1;
      final endIdx = cookieHeader?.indexOf(';', startIdx) ?? -1;
      if (startIdx == -1 || endIdx == -1) {
        return (false, 'Auth failed');
      }
      final authToken = cookieHeader!.substring(startIdx + 3, endIdx);
      ref
          .read(synchingProvider(syncId: syncId).notifier)
          .login(server, username, authToken);
      botToast(l10n.sync_logged);
      return (true, '');
    } catch (e) {
      return (false, e.toString());
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
    if (!silent) {
      botToast(l10n.sync_starting, second: 500);
    }
    try {
      final syncPreference = ref.read(synchingProvider(syncId: syncId));
      final syncNotifier = ref.read(synchingProvider(syncId: syncId).notifier);

      final resultManga = await _syncManga(
        ref,
        l10n,
        syncNotifier,
        download: download,
        upload: upload,
      );
      if (!resultManga) {
        botToast(l10n.sync_failed, second: 5);
        return;
      }
      if (syncPreference.syncHistories) {
        final resultHistory = await _syncHistory(
          ref,
          l10n,
          syncNotifier,
          download: download,
          upload: upload,
        );
        if (!resultHistory) {
          botToast(l10n.sync_failed, second: 5);
          return;
        }
      }
      if (syncPreference.syncUpdates) {
        final resultUpdate = await _syncUpdate(
          ref,
          l10n,
          syncNotifier,
          download: download,
          upload: upload,
        );
        if (!resultUpdate) {
          botToast(l10n.sync_failed, second: 5);
          return;
        }
      }
      if (syncPreference.syncSettings) {
        final resultSettings = await _syncSettings(
          ref,
          l10n,
          download: download,
          upload: upload,
        );
        if (!resultSettings) {
          botToast(l10n.sync_failed, second: 5);
          return;
        }
      }

      ref.invalidate(synchingProvider(syncId: syncId));
      if (!silent) {
        botToast(l10n.sync_finished, second: 2);
      }
    } catch (error) {
      botToast(error.toString(), second: 5);
    }
  }

  Future<bool> _syncManga(
    Ref ref,
    AppLocalizations l10n,
    Synching syncNotifier, {
    bool upload = false,
    bool download = false,
  }) async {
    final mangaData = _getMangaData(ref, upload: upload, download: download);
    final accessToken = _getAccessToken(ref);
    final response = await http.post(
      Uri.parse('${_getServer(ref)}$_syncMangaUrl'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'id=$accessToken',
      },
      body: mangaData,
    );
    if (response.statusCode != 200) {
      botToast(l10n.sync_failed, second: 5);
      return false;
    }

    if (!upload) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      await _upsertCategories(jsonData, syncNotifier);
      await _upsertManga(jsonData, syncNotifier);
      await _upsertChapters(jsonData, syncNotifier);
      await _upsertTracks(jsonData, syncNotifier);
    } else {
      await syncNotifier.clearChangedParts([
        ActionType.removeCategory,
        ActionType.removeItem,
        ActionType.removeChapter,
        ActionType.removeTrack,
      ], true);
    }

    syncNotifier.setLastSyncManga(DateTime.now().millisecondsSinceEpoch);

    return true;
  }

  Future<bool> _syncHistory(
    Ref ref,
    AppLocalizations l10n,
    Synching syncNotifier, {
    bool upload = false,
    bool download = false,
  }) async {
    final historyData = _getHistoryData(
      ref,
      upload: upload,
      download: download,
    );
    final accessToken = _getAccessToken(ref);
    final response = await http.post(
      Uri.parse('${_getServer(ref)}$_syncHistoryUrl'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'id=$accessToken',
      },
      body: historyData,
    );
    if (response.statusCode != 200) {
      botToast(l10n.sync_failed, second: 5);
      return false;
    }

    if (!upload) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      await _upsertHistories(jsonData, syncNotifier);
    } else {
      await syncNotifier.clearChangedParts([ActionType.removeHistory], true);
    }

    syncNotifier.setLastSyncHistory(DateTime.now().millisecondsSinceEpoch);

    return true;
  }

  Future<bool> _syncUpdate(
    Ref ref,
    AppLocalizations l10n,
    Synching syncNotifier, {
    bool upload = false,
    bool download = false,
  }) async {
    final updateData = _getUpdateData(ref, upload: upload, download: download);
    final accessToken = _getAccessToken(ref);
    final response = await http.post(
      Uri.parse('${_getServer(ref)}$_syncUpdateUrl'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'id=$accessToken',
      },
      body: updateData,
    );
    if (response.statusCode != 200) {
      botToast(l10n.sync_failed, second: 5);
      return false;
    }

    if (!upload) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      await _upsertUpdates(jsonData, syncNotifier);
    } else {
      await syncNotifier.clearChangedParts([ActionType.removeUpdate], true);
    }

    syncNotifier.setLastSyncUpdate(DateTime.now().millisecondsSinceEpoch);

    return true;
  }

  Future<bool> _syncSettings(
    Ref ref,
    AppLocalizations l10n, {
    bool upload = false,
    bool download = false,
  }) async {
    final settingsData = _getSettingsData(download: download);
    final accessToken = _getAccessToken(ref);
    final response = await http.post(
      Uri.parse('${_getServer(ref)}$_syncSettingsUrl'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'id=$accessToken',
      },
      body: settingsData,
    );
    if (response.statusCode != 200) {
      botToast(l10n.sync_failed, second: 5);
      return false;
    }

    if (!upload) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      await _upsertSettings(ref, jsonData);
    }

    return true;
  }

  Future<void> _upsertCategories(
    Map<String, dynamic> jsonData,
    Synching syncNotifier,
  ) async {
    final categories =
        (jsonData['categories'] as List?)
            ?.map((e) => Category.fromJson(e))
            .toList() ??
        [];
    await isar.writeTxn(() async {
      for (final category
          in await isar.categorys.filter().idIsNotNull().findAll()) {
        final temp = categories.firstWhereOrNull((e) => e.id == category.id);
        if (temp != null) {
          if ((category.updatedAt ?? 0) < (temp.updatedAt ?? 1)) {
            await isar.categorys.put(temp);
          }
          categories.remove(temp);
        } else {
          await isar.categorys.delete(category.id!);
        }
      }
      for (final category in categories) {
        await isar.categorys.put(category);
      }
      await syncNotifier.clearChangedParts([ActionType.removeCategory], false);
    });
  }

  Future<void> _upsertManga(
    Map<String, dynamic> jsonData,
    Synching syncNotifier,
  ) async {
    final mangas =
        (jsonData['manga'] as List?)?.map((e) => Manga.fromJson(e)).toList() ??
        [];
    await isar.writeTxn(() async {
      for (final manga in await isar.mangas.filter().idIsNotNull().findAll()) {
        final temp = mangas.firstWhereOrNull((e) => e.id == manga.id);
        if (temp != null) {
          if ((manga.updatedAt ?? 0) < (temp.updatedAt ?? 1)) {
            await isar.mangas.put(temp);
          }
          mangas.remove(temp);
        } else {
          await isar.mangas.delete(manga.id!);
        }
      }
      for (final manga in mangas) {
        await isar.mangas.put(manga);
      }
      await syncNotifier.clearChangedParts([ActionType.removeItem], false);
    });
  }

  Future<void> _upsertChapters(
    Map<String, dynamic> jsonData,
    Synching syncNotifier,
  ) async {
    final chapters =
        (jsonData['chapters'] as List?)
            ?.map((e) => Chapter.fromJson(e))
            .toList() ??
        [];
    await isar.writeTxn(() async {
      for (final chapter
          in await isar.chapters.filter().idIsNotNull().findAll()) {
        final temp = chapters.firstWhereOrNull((e) => e.id == chapter.id);
        if (temp != null) {
          final manga = await isar.mangas.get(temp.mangaId!);
          if (manga != null &&
              (chapter.updatedAt ?? 0) < (temp.updatedAt ?? 1)) {
            await isar.chapters.put(temp..manga.value = manga);
            await temp.manga.save();
          }
          chapters.remove(temp);
        } else {
          await isar.chapters.delete(chapter.id!);
        }
      }
      for (final chapter in chapters) {
        final manga = await isar.mangas.get(chapter.mangaId!);
        if (manga != null) {
          await isar.chapters.put(chapter..manga.value = manga);
          await chapter.manga.save();
        }
      }
      await syncNotifier.clearChangedParts([ActionType.removeChapter], false);
    });
  }

  Future<void> _upsertTracks(
    Map<String, dynamic> jsonData,
    Synching syncNotifier,
  ) async {
    final tracks =
        (jsonData['tracks'] as List?)?.map((e) => Track.fromJson(e)).toList() ??
        [];
    await isar.writeTxn(() async {
      for (final track in await isar.tracks.filter().idIsNotNull().findAll()) {
        final temp = tracks.firstWhereOrNull((e) => e.id == track.id);
        if (temp != null) {
          if ((track.updatedAt ?? 0) < (temp.updatedAt ?? 1)) {
            await isar.tracks.put(temp);
          }
          tracks.remove(temp);
        } else {
          await isar.tracks.delete(track.id!);
        }
      }
      for (final track in tracks) {
        await isar.tracks.put(track);
      }
      await syncNotifier.clearChangedParts([ActionType.removeTrack], false);
    });
  }

  Future<void> _upsertHistories(
    Map<String, dynamic> jsonData,
    Synching syncNotifier,
  ) async {
    final histories =
        (jsonData['histories'] as List?)
            ?.map((e) => History.fromJson(e))
            .toList() ??
        [];
    await isar.writeTxn(() async {
      for (final history
          in await isar.historys.filter().idIsNotNull().findAll()) {
        final temp = histories.firstWhereOrNull((e) => e.id == history.id);
        if (temp != null) {
          final chapter = await isar.chapters.get(temp.chapterId!);
          if (chapter != null &&
              (history.updatedAt ?? 0) < (temp.updatedAt ?? 1)) {
            await isar.historys.put(temp..chapter.value = chapter);
            await temp.chapter.save();
          }
          histories.remove(temp);
        } else {
          await isar.historys.delete(history.id!);
        }
      }
      for (final history in histories) {
        final chapter = await isar.chapters.get(history.chapterId!);
        if (chapter != null) {
          await isar.historys.put(history..chapter.value = chapter);
          await history.chapter.save();
        }
      }
      await syncNotifier.clearChangedParts([ActionType.removeHistory], false);
    });
  }

  Future<void> _upsertUpdates(
    Map<String, dynamic> jsonData,
    Synching syncNotifier,
  ) async {
    final updates =
        (jsonData['updates'] as List?)
            ?.map((e) => Update.fromJson(e))
            .toList() ??
        [];
    await isar.writeTxn(() async {
      for (final update in await isar.updates.filter().idIsNotNull().findAll()) {
        final temp = updates.firstWhereOrNull((e) => e.id == update.id);
        if (temp != null) {
          final chapter = await isar.chapters
              .filter()
              .mangaIdEqualTo(temp.mangaId)
              .nameEqualTo(temp.chapterName)
              .findFirst();
          if (chapter != null &&
              (update.updatedAt ?? 0) < (temp.updatedAt ?? 1)) {
            await isar.updates.put(temp..chapter.value = chapter);
            await temp.chapter.save();
          }
          updates.remove(temp);
        } else {
          await isar.updates.delete(update.id!);
        }
      }
      for (final update in updates) {
        final chapter = await isar.chapters
            .filter()
            .mangaIdEqualTo(update.mangaId)
            .nameEqualTo(update.chapterName)
            .findFirst();
        if (chapter != null) {
          await isar.updates.put(update..chapter.value = chapter);
          await update.chapter.save();
        }
      }
      await syncNotifier.clearChangedParts([ActionType.removeUpdate], false);
    });
  }

  Future<void> _upsertSettings(
    Ref ref,
    Map<String, dynamic> jsonData,
  ) async {
    final oldSettings = isar.settings.getSync(227)!;
    final settings = Settings.fromJson(jsonData['settings']);
    await isar.writeTxn(() async {
      await isar.settings.put(settings..cookiesList = oldSettings.cookiesList);
      ref.invalidate(followSystemThemeStateProvider);
      ref.invalidate(themeModeStateProvider);
      ref.invalidate(blendLevelStateProvider);
      ref.invalidate(flexSchemeColorStateProvider);
      ref.invalidate(pureBlackDarkModeStateProvider);
      ref.invalidate(l10nLocaleStateProvider);
      ref.invalidate(extensionsRepoStateProvider(ItemType.manga));
      ref.invalidate(extensionsRepoStateProvider(ItemType.anime));
      ref.invalidate(extensionsRepoStateProvider(ItemType.novel));
    });
  }

  String _getMangaData(
    Ref ref, {
    bool upload = false,
    bool download = false,
  }) {
    final data = <String, dynamic>{};
    data['categories'] = download ? [] : _getCategories();
    data['deleted_categories'] = download
        ? []
        : _getDeletedObjects(ref, ActionType.removeCategory);
    data['manga'] = download ? [] : _getManga();
    data['deleted_manga'] = download
        ? []
        : _getDeletedObjects(ref, ActionType.removeItem);
    data['chapters'] = download ? [] : _getChapters();
    data['deleted_chapters'] = download
        ? []
        : _getDeletedObjects(ref, ActionType.removeChapter);
    data['tracks'] = download ? [] : _getTracks();
    data['deleted_tracks'] = download
        ? []
        : _getDeletedObjects(ref, ActionType.removeTrack);
    if (upload) {
      data['resetAll'] = true;
    }
    return jsonEncode(data);
  }

  String _getHistoryData(
    Ref ref, {
    bool upload = false,
    bool download = false,
  }) {
    final data = <String, dynamic>{};
    data['histories'] = download ? [] : _getHistories();
    data['deleted_histories'] = download
        ? []
        : _getDeletedObjects(ref, ActionType.removeHistory);
    if (upload) {
      data['resetAll'] = true;
    }
    return jsonEncode(data);
  }

  String _getUpdateData(
    Ref ref, {
    bool upload = false,
    bool download = false,
  }) {
    final data = <String, dynamic>{};
    data['updates'] = download ? [] : _getUpdates();
    data['deleted_updates'] = download
        ? []
        : _getDeletedObjects(ref, ActionType.removeUpdate);
    if (upload) {
      data['resetAll'] = true;
    }
    return jsonEncode(data);
  }

  String _getSettingsData({bool download = false}) {
    final data = <String, dynamic>{};
    if (!download) {
      data['settings'] = isar.settings.getSync(227)!
        ..updatedAt ??= DateTime.now().millisecondsSinceEpoch
        ..cookiesList = [];
    }
    return jsonEncode(data);
  }

  List<int> _getDeletedObjects(Ref ref, ActionType actionType) {
    return ref
        .read(synchingProvider(syncId: syncId).notifier)
        .getChangedParts([actionType])
        .map((e) => e.isarId)
        .nonNulls
        .toList();
  }

  List<Map<String, dynamic>> _getManga() {
    return isar.mangas
        .filter()
        .idIsNotNull()
        .findAllSync()
        .map((e) => (e..customCoverImage = null).toJson())
        .toList();
  }

  List<Map<String, dynamic>> _getCategories() {
    return isar.categorys
        .filter()
        .idIsNotNull()
        .findAllSync()
        .map((e) => e.toJson())
        .toList();
  }

  List<Map<String, dynamic>> _getChapters() {
    return isar.chapters
        .filter()
        .idIsNotNull()
        .findAllSync()
        .map((e) => e.toJson())
        .toList();
  }

  List<Map<String, dynamic>> _getTracks() {
    return isar.tracks
        .filter()
        .idIsNotNull()
        .findAllSync()
        .map((e) => e.toJson())
        .toList();
  }

  List<Map<String, dynamic>> _getHistories() {
    return isar.historys
        .filter()
        .idIsNotNull()
        .findAllSync()
        .map((e) => e.toJson())
        .toList();
  }

  List<Map<String, dynamic>> _getUpdates() {
    return isar.updates
        .filter()
        .idIsNotNull()
        .findAllSync()
        .map((e) => e.toJson())
        .toList();
  }

  String _getAccessToken(Ref ref) {
    final syncPrefs = ref.read(synchingProvider(syncId: syncId));
    return syncPrefs.authToken ?? '';
  }

  String _getServer(Ref ref) {
    final syncPrefs = ref.read(synchingProvider(syncId: syncId));
    return syncPrefs.server ?? '';
  }
}
