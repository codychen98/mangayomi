import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';
import 'package:mangayomi/eval/model/m_bridge.dart';
import 'package:mangayomi/l10n/generated/app_localizations.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/modules/more/settings/sync/providers/sync_providers.dart';
import 'package:mangayomi/utils/date.dart';
import 'package:mangayomi/models/sync_preference.dart';
import 'package:mangayomi/modules/more/settings/sync/widgets/sync_listile.dart';
import 'package:mangayomi/providers/l10n_providers.dart';
import 'package:mangayomi/services/sync/sync_backend.dart';
import 'package:mangayomi/services/sync/sync_coordinator.dart';
import 'package:mangayomi/services/sync/sync_service_type.dart';
import 'package:mangayomi/utils/extensions/build_context_extensions.dart';
import 'package:mangayomi/utils/log/logger.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:url_launcher/url_launcher.dart';

class SyncScreen extends ConsumerWidget {
  static const serverUrl = "https://github.com/Schnitzel5/mangayomi-server";

  const SyncScreen({super.key});

  static String _formatLastSyncTimestamp({
    required int? timestamp,
    required WidgetRef ref,
    required BuildContext context,
    required AppLocalizations l10n,
  }) {
    if (timestamp == null || timestamp <= 0) {
      return l10n.last_sync_never;
    }
    return '${dateFormat(timestamp.toString(), ref: ref, context: context)} ${dateFormatHour(timestamp.toString(), context)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = l10nLocalizations(context)!;
    final autoSyncOptions = {
      l10n.sync_auto_off: 0,
      l10n.sync_auto_5_minutes: 300,
      l10n.sync_auto_10_minutes: 600,
      l10n.sync_auto_30_minutes: 1800,
      l10n.sync_auto_1_hour: 3600,
      l10n.sync_auto_3_hours: 10800,
      l10n.sync_auto_6_hours: 21600,
      l10n.sync_auto_12_hours: 43200,
    };
    return Scaffold(
      appBar: AppBar(title: Text(l10nLocalizations(context)!.syncing)),
      body: SingleChildScrollView(
        child: StreamBuilder(
          stream: isar.syncPreferences.filter().syncIdIsNotNull().watch(
            fireImmediately: true,
          ),
          builder: (context, snapshot) {
            SyncPreference syncPreference = snapshot.data?.isNotEmpty ?? false
                ? snapshot.data?.first ?? SyncPreference()
                : SyncPreference();
            final bool isLogged = isSyncConfigured(syncPreference);
            final bool isWebDav =
                syncPreference.syncServiceType == SyncServiceType.webDav;
            return Column(
              children: [
                SwitchListTile(
                  value: syncPreference.syncOn,
                  title: Text(context.l10n.sync_on),
                  onChanged: (value) {
                    ref
                        .read(synchingProvider(syncId: 1).notifier)
                        .setSyncOn(value);
                    if (!value) {
                      ref
                          .read(synchingProvider(syncId: 1).notifier)
                          .setAutoSyncFrequency(0);
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.sync_service,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<SyncServiceType>(
                        emptySelectionAllowed: false,
                        showSelectedIcon: false,
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        segments: [
                          ButtonSegment(
                            value: SyncServiceType.mangayomiServer,
                            label: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                              child: Text(l10n.sync_service_mangayomi_server),
                            ),
                          ),
                          ButtonSegment(
                            value: SyncServiceType.webDav,
                            label: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                              child: Text(l10n.sync_service_webdav),
                            ),
                          ),
                        ],
                        selected: {syncPreference.syncServiceType},
                        onSelectionChanged: syncPreference.syncOn
                            ? (selection) {
                                if (selection.isEmpty) {
                                  return;
                                }
                                ref
                                    .read(synchingProvider(syncId: 1).notifier)
                                    .setSyncServiceType(selection.first);
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
                ListTile(
                  enabled: syncPreference.syncOn,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(l10n.sync_auto),
                          content: SizedBox(
                            width: context.width(0.8),
                            child: RadioGroup(
                              groupValue: syncPreference.autoSyncFrequency,
                              onChanged: (value) {
                                ref
                                    .read(synchingProvider(syncId: 1).notifier)
                                    .setAutoSyncFrequency(value!);
                                Navigator.pop(context);
                              },
                              child: SuperListView.builder(
                                shrinkWrap: true,
                                itemCount: autoSyncOptions.length,
                                itemBuilder: (context, index) {
                                  final optionName = autoSyncOptions.keys
                                      .elementAt(index);
                                  final optionValue = autoSyncOptions.values
                                      .elementAt(index);
                                  return RadioListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.all(0),
                                    value: optionValue,
                                    title: Text(optionName),
                                  );
                                },
                              ),
                            ),
                          ),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    l10n.cancel,
                                    style: TextStyle(
                                      color: context.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                  title: Text(l10n.sync_auto),
                  subtitle: Text(
                    autoSyncOptions.entries
                        .where(
                          (o) => o.value == syncPreference.autoSyncFrequency,
                        )
                        .first
                        .key,
                    style: TextStyle(
                      fontSize: 11,
                      color: context.secondaryColor,
                    ),
                  ),
                ),
                ListTile(
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_outlined,
                          color: context.secondaryColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.sync_auto_warning,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: 11,
                              color: context.secondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SwitchListTile(
                  value: syncPreference.syncHistories,
                  title: Text(context.l10n.sync_enable_histories),
                  onChanged: syncPreference.syncOn
                      ? (value) {
                          ref
                              .read(synchingProvider(syncId: 1).notifier)
                              .setSyncHistories(value);
                        }
                      : null,
                ),
                SwitchListTile(
                  value: syncPreference.syncUpdates,
                  title: Text(context.l10n.sync_enable_updates),
                  onChanged: syncPreference.syncOn
                      ? (value) {
                          ref
                              .read(synchingProvider(syncId: 1).notifier)
                              .setSyncUpdates(value);
                        }
                      : null,
                ),
                SwitchListTile(
                  value: syncPreference.syncSettings,
                  title: Text(context.l10n.sync_enable_settings),
                  onChanged: syncPreference.syncOn
                      ? (value) {
                          ref
                              .read(synchingProvider(syncId: 1).notifier)
                              .setSyncSettings(value);
                        }
                      : null,
                ),
                ListTile(
                  enabled: syncPreference.syncOn,
                  onTap: syncPreference.syncOn
                      ? () => context.push('/syncTriggers')
                      : null,
                  title: Text(l10n.sync_triggers),
                  trailing: const Icon(Icons.chevron_right),
                ),
                if (!isWebDav)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      bottom: 10,
                      top: 10,
                    ),
                    child: Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            if (!await launchUrl(
                              Uri.parse(serverUrl),
                              mode: LaunchMode.externalApplication,
                            )) {
                              AppLogger.log(
                                'Could not launch $serverUrl',
                                logLevel: LogLevel.error,
                              );
                              botToast('Could not launch $serverUrl');
                            }
                          },
                          label: Text(l10n.get_sync_server),
                          icon: const Icon(Icons.download_outlined),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                    bottom: 10,
                    top: 5,
                  ),
                  child: Row(
                    children: [
                      Text(
                        l10n.services,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SyncListile(
                  enabled: syncPreference.syncOn,
                  onTap: () async {
                    if (isWebDav) {
                      _showDialogWebDav(context, ref, syncPreference);
                    } else {
                      _showDialogLogin(context, ref, syncPreference);
                    }
                  },
                  id: 1,
                  preference: syncPreference,
                ),
                ListTile(
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: context.secondaryColor,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isWebDav
                                ? l10n.webdav_sync_subtitle
                                : l10n.syncing_subtitle,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: 11,
                              color: context.secondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.sync, color: context.secondaryColor),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            const SizedBox(width: 20),
                            Text(
                              "${l10n.last_sync_manga}${_formatLastSyncTimestamp(timestamp: syncPreference.lastSyncManga, ref: ref, context: context, l10n: l10n)}",
                              style: TextStyle(
                                fontSize: 11,
                                color: context.secondaryColor,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              "${l10n.last_sync_history}${_formatLastSyncTimestamp(timestamp: syncPreference.lastSyncHistory, ref: ref, context: context, l10n: l10n)}",
                              style: TextStyle(
                                fontSize: 11,
                                color: context.secondaryColor,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              "${l10n.last_sync_update}${_formatLastSyncTimestamp(timestamp: syncPreference.lastSyncUpdate, ref: ref, context: context, l10n: l10n)}",
                              style: TextStyle(
                                fontSize: 11,
                                color: context.secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 20,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          onPressed: !syncPreference.syncOn || !isLogged
                              ? null
                              : () {
                                  ref
                                      .read(
                                        syncCoordinatorProvider(
                                          syncId: 1,
                                        ).notifier,
                                      )
                                      .startSync(l10n, false);
                                },
                          icon: Icon(
                            Icons.sync,
                            color: !syncPreference.syncOn || !isLogged
                                ? context.secondaryColor
                                : context.primaryColor,
                          ),
                        ),
                        Text(l10n.sync_button_sync),
                      ],
                    ),

                    Column(
                      children: [
                        IconButton(
                          onPressed: !syncPreference.syncOn || !isLogged
                              ? null
                              : () => _showConfirmDialog(context, ref, true),
                          icon: Icon(
                            Icons.file_upload_outlined,
                            color: !syncPreference.syncOn || !isLogged
                                ? context.secondaryColor
                                : context.primaryColor,
                          ),
                        ),
                        Text(l10n.sync_button_upload),
                      ],
                    ),

                    Column(
                      children: [
                        IconButton(
                          onPressed: !syncPreference.syncOn || !isLogged
                              ? null
                              : () => _showConfirmDialog(context, ref, false),
                          icon: Icon(
                            Icons.file_download_outlined,
                            color: !syncPreference.syncOn || !isLogged
                                ? context.secondaryColor
                                : context.primaryColor,
                          ),
                        ),
                        Text(l10n.sync_button_download),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    bool isUpload,
  ) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            isUpload
                ? context.l10n.sync_button_upload_info
                : context.l10n.sync_button_download_info,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.l10n.cancel),
                ),
                const SizedBox(width: 15),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(syncCoordinatorProvider(syncId: 1).notifier)
                        .startSync(
                          context.l10n,
                          false,
                          upload: isUpload,
                          download: !isUpload,
                        );
                    Navigator.pop(context);
                  },
                  child: Text(context.l10n.dialog_confirm),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showDialogLogin(
    BuildContext context,
    WidgetRef ref,
    SyncPreference syncPreference,
  ) {
    final serverController = TextEditingController(text: syncPreference.server);
    final emailController = TextEditingController(text: syncPreference.email);
    final passwordController = TextEditingController();
    String server = "";
    String email = "";
    String password = "";
    String errorMessage = "";
    bool isLoading = false;
    bool obscureText = true;
    final l10n = l10nLocalizations(context)!;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              l10n.login_into("SyncServer"),
              style: const TextStyle(fontSize: 30),
            ),
            content: SizedBox(
              height: 400,
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextFormField(
                      controller: serverController,
                      autofocus: true,
                      onChanged: (value) => setState(() {
                        server = value;
                      }),
                      decoration: InputDecoration(
                        hintText: l10n.sync_server,
                        filled: false,
                        contentPadding: const EdgeInsets.all(12),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(width: 0.4),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextFormField(
                      controller: emailController,
                      autofocus: true,
                      onChanged: (value) => setState(() {
                        email = value;
                      }),
                      decoration: InputDecoration(
                        hintText: l10n.email_adress,
                        filled: false,
                        contentPadding: const EdgeInsets.all(12),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(width: 0.4),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: obscureText,
                      onChanged: (value) => setState(() {
                        password = value;
                      }),
                      decoration: InputDecoration(
                        hintText: l10n.sync_password,
                        suffixIcon: IconButton(
                          onPressed: () => setState(() {
                            obscureText = !obscureText;
                          }),
                          icon: Icon(
                            obscureText
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        filled: false,
                        contentPadding: const EdgeInsets.all(12),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(width: 0.4),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(errorMessage, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      width: context.width(1),
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                setState(() {
                                  isLoading = true;
                                });
                                final res = await ref
                                    .read(
                                      syncCoordinatorProvider(
                                        syncId: 1,
                                      ).notifier,
                                    )
                                    .authenticate(
                                      l10n,
                                      server,
                                      email,
                                      password,
                                    );
                                if (!res.$1) {
                                  setState(() {
                                    isLoading = false;
                                    errorMessage = res.$2;
                                  });
                                } else {
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                }
                              },
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : Text(l10n.login),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDialogWebDav(
    BuildContext context,
    WidgetRef ref,
    SyncPreference syncPreference,
  ) {
    final urlController = TextEditingController(text: syncPreference.webDavUrl);
    final usernameController = TextEditingController(
      text: syncPreference.webDavUsername,
    );
    final passwordController = TextEditingController();
    final folderController = TextEditingController(
      text: syncPreference.webDavFolder,
    );
    String url = syncPreference.webDavUrl ?? '';
    String username = syncPreference.webDavUsername ?? '';
    String password = '';
    String folder = syncPreference.webDavFolder;
    String errorMessage = '';
    bool isLoading = false;
    bool obscureText = true;
    final bool isConfigured = isSyncConfigured(syncPreference);
    final l10n = l10nLocalizations(context)!;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              l10n.login_into(l10n.sync_service_webdav),
              style: const TextStyle(fontSize: 30),
            ),
            content: SizedBox(
              height: 480,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      l10n.webdav_url_summary,
                      style: TextStyle(
                        fontSize: 11,
                        color: context.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextFormField(
                        controller: urlController,
                        autofocus: true,
                        onChanged: (value) => setState(() {
                          url = value;
                        }),
                        decoration: InputDecoration(
                          labelText: l10n.webdav_url,
                          hintText: 'https://',
                          filled: false,
                          contentPadding: const EdgeInsets.all(12),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(width: 0.4),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextFormField(
                        controller: usernameController,
                        onChanged: (value) => setState(() {
                          username = value;
                        }),
                        decoration: InputDecoration(
                          labelText: l10n.webdav_username,
                          filled: false,
                          contentPadding: const EdgeInsets.all(12),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(width: 0.4),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: obscureText,
                        onChanged: (value) => setState(() {
                          password = value;
                        }),
                        decoration: InputDecoration(
                          labelText: l10n.webdav_password,
                          helperText: isConfigured ? l10n.webdav_password_keep_hint : null,
                          suffixIcon: IconButton(
                            onPressed: () => setState(() {
                              obscureText = !obscureText;
                            }),
                            icon: Icon(
                              obscureText
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                          filled: false,
                          contentPadding: const EdgeInsets.all(12),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(width: 0.4),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: TextFormField(
                        controller: folderController,
                        onChanged: (value) => setState(() {
                          folder = value;
                        }),
                        decoration: InputDecoration(
                          labelText: l10n.webdav_folder,
                          filled: false,
                          contentPadding: const EdgeInsets.all(12),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(width: 0.4),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: const BorderSide(),
                          ),
                        ),
                      ),
                    ),
                    Text(errorMessage, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: context.width(1),
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                setState(() {
                                  isLoading = true;
                                });
                                final effectivePassword = password.isNotEmpty
                                    ? password
                                    : (syncPreference.webDavPassword ?? '');
                                final res = await ref
                                    .read(
                                      syncCoordinatorProvider(
                                        syncId: 1,
                                      ).notifier,
                                    )
                                    .authenticate(
                                      l10n,
                                      url,
                                      username,
                                      effectivePassword,
                                      folder: folder,
                                    );
                                if (!res.$1) {
                                  setState(() {
                                    isLoading = false;
                                    errorMessage = res.$2;
                                  });
                                } else if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                        child: isLoading
                            ? const CircularProgressIndicator()
                            : Text(l10n.login),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
