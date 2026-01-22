import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../common/toggle_control_row.dart';

class FalseColorControl extends StatelessWidget {
  const FalseColorControl({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final currentDisplay = cameraState.monitoring.currentDisplay;

    if (currentDisplay == null) {
      return const SizedBox.shrink();
    }

    return ToggleControlRow(
      icon: Icons.palette,
      title: 'False Color',
      description: 'Color-coded exposure overlay',
      value: currentDisplay.falseColorEnabled,
      onChanged: (enabled) {
        cameraState.setFalseColorEnabled(enabled);
      },
    );
  }
}
