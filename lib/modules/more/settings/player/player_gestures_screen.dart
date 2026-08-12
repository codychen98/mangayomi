import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mangayomi/modules/more/settings/player/providers/player_state_provider.dart';
import 'package:mangayomi/utils/extensions/build_context_extensions.dart';

class PlayerGesturesScreen extends ConsumerWidget {
  const PlayerGesturesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableBrightness = ref.watch(enablePlayerBrightnessGestureStateProvider);
    final enableVolume = ref.watch(enablePlayerVolumeGestureStateProvider);
    final enableSeekLeft = ref.watch(enablePlayerDoubleTapSeekLeftStateProvider);
    final enableSeekRight =
        ref.watch(enablePlayerDoubleTapSeekRightStateProvider);
    final enablePlayPause =
        ref.watch(enablePlayerDoubleTapPlayPauseStateProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.player_gestures)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                context.l10n.player_gestures_info,
                style: TextStyle(fontSize: 13, color: context.secondaryColor),
              ),
            ),
            SwitchListTile(
              value: enableBrightness,
              title: Text(context.l10n.player_gesture_brightness),
              subtitle: Text(
                context.l10n.player_gesture_brightness_info,
                style: TextStyle(fontSize: 11, color: context.secondaryColor),
              ),
              onChanged: (value) => ref
                  .read(enablePlayerBrightnessGestureStateProvider.notifier)
                  .set(value),
            ),
            SwitchListTile(
              value: enableVolume,
              title: Text(context.l10n.player_gesture_volume),
              subtitle: Text(
                context.l10n.player_gesture_volume_info,
                style: TextStyle(fontSize: 11, color: context.secondaryColor),
              ),
              onChanged: (value) => ref
                  .read(enablePlayerVolumeGestureStateProvider.notifier)
                  .set(value),
            ),
            SwitchListTile(
              value: enableSeekLeft,
              title: Text(context.l10n.player_gesture_double_tap_seek_left),
              subtitle: Text(
                context.l10n.player_gesture_double_tap_seek_left_info,
                style: TextStyle(fontSize: 11, color: context.secondaryColor),
              ),
              onChanged: (value) => ref
                  .read(enablePlayerDoubleTapSeekLeftStateProvider.notifier)
                  .set(value),
            ),
            SwitchListTile(
              value: enablePlayPause,
              title: Text(context.l10n.player_gesture_double_tap_play_pause),
              subtitle: Text(
                context.l10n.player_gesture_double_tap_play_pause_info,
                style: TextStyle(fontSize: 11, color: context.secondaryColor),
              ),
              onChanged: (value) => ref
                  .read(enablePlayerDoubleTapPlayPauseStateProvider.notifier)
                  .set(value),
            ),
            SwitchListTile(
              value: enableSeekRight,
              title: Text(context.l10n.player_gesture_double_tap_seek_right),
              subtitle: Text(
                context.l10n.player_gesture_double_tap_seek_right_info,
                style: TextStyle(fontSize: 11, color: context.secondaryColor),
              ),
              onChanged: (value) => ref
                  .read(enablePlayerDoubleTapSeekRightStateProvider.notifier)
                  .set(value),
            ),
          ],
        ),
      ),
    );
  }
}
