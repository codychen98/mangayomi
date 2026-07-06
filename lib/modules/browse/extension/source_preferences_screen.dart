import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:mangayomi/eval/model/source_preference.dart';
import 'package:mangayomi/main.dart';
import 'package:mangayomi/models/source.dart';
import 'package:mangayomi/modules/browse/extension/providers/extension_preferences_providers.dart';
import 'package:mangayomi/modules/browse/extension/widgets/source_preference_widget.dart';

class SourcePreferencesScreen extends ConsumerStatefulWidget {
  final Source source;

  const SourcePreferencesScreen({super.key, required this.source});

  @override
  ConsumerState<SourcePreferencesScreen> createState() =>
      _SourcePreferencesScreenState();
}

class _SourcePreferencesScreenState
    extends ConsumerState<SourcePreferencesScreen> {
  late Source source = isar.sources.getSync(widget.source.id!)!;
  late final List<SourcePreference>? preferences =
      loadSourcePreferencesForSource(source);

  @override
  Widget build(BuildContext context) {
    final prefs = preferences;
    return Scaffold(
      appBar: AppBar(
        title: Text(source.name ?? ''),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: prefs == null
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              child: SourcePreferenceWidget(
                sourcePreference: prefs,
                source: source,
              ),
            ),
    );
  }
}
