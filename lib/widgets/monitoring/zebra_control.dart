import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../common/toggle_control_row.dart';

class ZebraControl extends StatelessWidget {
  const ZebraControl({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final currentDisplay = cameraState.monitoring.currentDisplay;

    if (currentDisplay == null) {
      return const SizedBox.shrink();
    }

    return ToggleControlRow(
      icon: Icons.texture,
      title: 'Zebra',
      description: 'Highlight overexposed areas',
      value: currentDisplay.zebraEnabled,
      onChanged: (enabled) {
        cameraState.setZebraEnabled(enabled);
      },
    );
  }
}
