import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../common/toggle_control_row.dart';

class CleanFeedControl extends StatelessWidget {
  const CleanFeedControl({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final currentDisplay = cameraState.monitoring.currentDisplay;

    if (currentDisplay == null) {
      return const SizedBox.shrink();
    }

    return ToggleControlRow(
      icon: Icons.visibility_off_outlined,
      title: 'Clean Feed',
      description: 'Hide all overlays on output',
      value: currentDisplay.cleanFeedEnabled,
      onChanged: (enabled) {
        cameraState.setCleanFeedEnabled(enabled);
      },
    );
  }
}
