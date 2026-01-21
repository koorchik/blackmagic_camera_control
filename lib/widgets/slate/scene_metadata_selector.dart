import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../../models/camera_state.dart';

/// Widget for scene location selection.
class SceneLocationSelector extends StatelessWidget {
  const SceneLocationSelector({
    super.key,
    required this.onSaving,
  });

  final VoidCallback onSaving;

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final slate = cameraState.slate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        SegmentedButton<SceneLocation?>(
          segments: [
            const ButtonSegment<SceneLocation?>(
              value: null,
              label: Text('None'),
            ),
            ...SceneLocation.values.map((location) => ButtonSegment<SceneLocation?>(
                  value: location,
                  label: Text(location.label),
                )),
          ],
          selected: {slate.sceneLocation},
          onSelectionChanged: (selection) {
            onSaving();
            cameraState.setSlateLocation(selection.first);
          },
          showSelectedIcon: false,
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}

/// Widget for scene time selection.
class SceneTimeSelector extends StatelessWidget {
  const SceneTimeSelector({
    super.key,
    required this.onSaving,
  });

  final VoidCallback onSaving;

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final slate = cameraState.slate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        SegmentedButton<SceneTime?>(
          segments: [
            const ButtonSegment<SceneTime?>(
              value: null,
              label: Text('None'),
            ),
            ...SceneTime.values.map((time) => ButtonSegment<SceneTime?>(
                  value: time,
                  label: Text(time.label),
                )),
          ],
          selected: {slate.sceneTime},
          onSelectionChanged: (selection) {
            onSaving();
            cameraState.setSlateTime(selection.first);
          },
          showSelectedIcon: false,
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}
