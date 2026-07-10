import 'package:mangayomi/models/settings.dart';

/// Settings fields that must stay on each device and never sync via WebDAV.
const deviceLocalSettingsFields = <String>[
  'downloadLocation',
  'autoBackupLocation',
];

Settings stripDeviceLocalSettings(Settings settings) {
  final copy = Settings.fromJson(settings.toJson());
  copy.downloadLocation = '';
  copy.autoBackupLocation = '';
  return copy;
}

Settings preserveDeviceLocalSettings(Settings merged, Settings local) {
  final copy = Settings.fromJson(merged.toJson());
  copy.downloadLocation = local.downloadLocation;
  copy.autoBackupLocation = local.autoBackupLocation;
  return copy;
}
