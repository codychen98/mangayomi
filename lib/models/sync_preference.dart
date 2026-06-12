import 'package:isar_community/isar.dart';
import 'package:mangayomi/services/sync/sync_service_type.dart';
part 'sync_preference.g.dart';

@collection
@Name("Sync Preference")
class SyncPreference {
  Id? syncId;

  String? email;

  String? authToken;

  int? lastSyncManga;

  int? lastSyncHistory;

  int? lastSyncUpdate;

  String? server;

  bool syncOn = false;

  int autoSyncFrequency = 0;

  bool syncHistories = false;

  bool syncUpdates = false;

  bool syncSettings = false;

  @enumerated
  SyncServiceType syncServiceType = SyncServiceType.mangayomiServer;

  String? webDavUrl;

  String? webDavUsername;

  String? webDavPassword;

  String webDavFolder = 'mangayomi';

  String? lastSyncEtag;

  bool syncOnChapterSeen = false;

  bool syncOnChapterOpen = false;

  bool syncOnAppStart = false;

  bool syncOnAppResume = false;

  SyncPreference({
    this.syncId,
    this.email,
    this.authToken,
    this.lastSyncManga,
    this.lastSyncHistory,
    this.lastSyncUpdate,
    this.server,
    this.syncOn = false,
    this.autoSyncFrequency = 0,
    this.syncServiceType = SyncServiceType.mangayomiServer,
    this.webDavUrl,
    this.webDavUsername,
    this.webDavPassword,
    this.webDavFolder = 'mangayomi',
    this.lastSyncEtag,
    this.syncOnChapterSeen = false,
    this.syncOnChapterOpen = false,
    this.syncOnAppStart = false,
    this.syncOnAppResume = false,
  });

  SyncPreference.fromJson(Map<String, dynamic> json) {
    syncId = json['syncId'];
    email = json['email'];
    authToken = json['authToken'];
    lastSyncManga = json['lastSyncManga'];
    lastSyncHistory = json['lastSyncHistory'];
    lastSyncUpdate = json['lastSyncUpdate'];
    server = json['server'];
    syncOn = json['syncOn'] ?? false;
    autoSyncFrequency = json['autoSyncFrequency'] ?? 0;
    syncHistories = json['syncHistories'] ?? false;
    syncUpdates = json['syncUpdates'] ?? false;
    syncSettings = json['syncSettings'] ?? false;
    syncServiceType = SyncServiceType.values[json['syncServiceType'] ?? 0];
    webDavUrl = json['webDavUrl'];
    webDavUsername = json['webDavUsername'];
    webDavPassword = json['webDavPassword'];
    webDavFolder = json['webDavFolder'] ?? 'mangayomi';
    lastSyncEtag = json['lastSyncEtag'];
    syncOnChapterSeen = json['syncOnChapterSeen'] ?? false;
    syncOnChapterOpen = json['syncOnChapterOpen'] ?? false;
    syncOnAppStart = json['syncOnAppStart'] ?? false;
    syncOnAppResume = json['syncOnAppResume'] ?? false;
  }

  Map<String, dynamic> toJson() => {
    'syncId': syncId,
    'email': email,
    'authToken': authToken,
    'lastSyncManga': lastSyncManga,
    'lastSyncHistory': lastSyncHistory,
    'lastSyncUpdate': lastSyncUpdate,
    'server': server,
    'syncOn': syncOn,
    'autoSyncFrequency': autoSyncFrequency,
    'syncHistories': syncHistories,
    'syncUpdates': syncUpdates,
    'syncSettings': syncSettings,
    'syncServiceType': syncServiceType.index,
    'webDavUrl': webDavUrl,
    'webDavUsername': webDavUsername,
    'webDavPassword': webDavPassword,
    'webDavFolder': webDavFolder,
    'lastSyncEtag': lastSyncEtag,
    'syncOnChapterSeen': syncOnChapterSeen,
    'syncOnChapterOpen': syncOnChapterOpen,
    'syncOnAppStart': syncOnAppStart,
    'syncOnAppResume': syncOnAppResume,
  };
}
