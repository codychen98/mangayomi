import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangayomi/modules/more/settings/sync/providers/sync_providers.dart';
import 'package:mangayomi/providers/l10n_providers.dart';
import 'package:mangayomi/utils/extensions/build_context_extensions.dart';

class SyncTriggersScreen extends ConsumerStatefulWidget {
  const SyncTriggersScreen({super.key});

  @override
  ConsumerState<SyncTriggersScreen> createState() => _SyncTriggersScreenState();
}

class _SyncTriggersScreenState extends ConsumerState<SyncTriggersScreen> {
  late bool _syncOnChapterSeen;
  late bool _syncOnChapterOpen;
  late bool _syncOnAppStart;
  late bool _syncOnAppResume;
  bool _initialized = false;

  void _loadDraft() {
    final prefs = ref.read(synchingProvider(syncId: 1));
    _syncOnChapterSeen = prefs.syncOnChapterSeen;
    _syncOnChapterOpen = prefs.syncOnChapterOpen;
    _syncOnAppStart = prefs.syncOnAppStart;
    _syncOnAppResume = prefs.syncOnAppResume;
    _initialized = true;
  }

  void _save() {
    final notifier = ref.read(synchingProvider(syncId: 1).notifier);
    notifier.setSyncOnChapterSeen(_syncOnChapterSeen);
    notifier.setSyncOnChapterOpen(_syncOnChapterOpen);
    notifier.setSyncOnAppStart(_syncOnAppStart);
    notifier.setSyncOnAppResume(_syncOnAppResume);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = l10nLocalizations(context)!;
    final syncOn = ref.watch(synchingProvider(syncId: 1)).syncOn;
    if (!_initialized) {
      _loadDraft();
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sync_triggers)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Column(
              children: [
                CheckboxListTile(
                  enabled: syncOn,
                  value: _syncOnChapterSeen,
                  title: Text(l10n.sync_on_chapter_seen),
                  onChanged: syncOn
                      ? (value) {
                          setState(() {
                            _syncOnChapterSeen = value ?? false;
                          });
                        }
                      : null,
                ),
                CheckboxListTile(
                  enabled: syncOn,
                  value: _syncOnChapterOpen,
                  title: Text(l10n.sync_on_chapter_open),
                  onChanged: syncOn
                      ? (value) {
                          setState(() {
                            _syncOnChapterOpen = value ?? false;
                          });
                        }
                      : null,
                ),
                CheckboxListTile(
                  enabled: syncOn,
                  value: _syncOnAppStart,
                  title: Text(l10n.sync_on_app_start),
                  onChanged: syncOn
                      ? (value) {
                          setState(() {
                            _syncOnAppStart = value ?? false;
                          });
                        }
                      : null,
                ),
                CheckboxListTile(
                  enabled: syncOn,
                  value: _syncOnAppResume,
                  title: Text(l10n.sync_on_app_resume),
                  onChanged: syncOn
                      ? (value) {
                          setState(() {
                            _syncOnAppResume = value ?? false;
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: syncOn ? _save : null,
            child: Text(l10n.save),
          ),
        ),
      ),
    );
  }
}
