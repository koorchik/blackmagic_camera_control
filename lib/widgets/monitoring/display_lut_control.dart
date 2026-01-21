import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../common/toggle_control_row.dart';

class DisplayLutControl extends StatelessWidget {
  const DisplayLutControl({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final currentDisplay = cameraState.monitoring.currentDisplay;

    if (currentDisplay == null) {
      return const SizedBox.shrink();
    }

    return ToggleControlRow(
      icon: Icons.palette_outlined,
      title: 'Display 3D LUT',
      description: 'Apply LUT to display output',
      value: currentDisplay.displayLutEnabled,
      onChanged: (enabled) {
        cameraState.setDisplayLutEnabled(enabled);
      },
    );
  }
}
