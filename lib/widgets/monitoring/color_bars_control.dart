import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../common/toggle_control_row.dart';

class ColorBarsControl extends StatelessWidget {
  const ColorBarsControl({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final colorBarsEnabled = cameraState.monitoring.colorBarsEnabled;

    return ToggleControlRow(
      icon: Icons.gradient,
      title: 'Color Bars',
      description: 'Display test pattern for calibration',
      value: colorBarsEnabled,
      onChanged: (enabled) {
        cameraState.setColorBarsEnabled(enabled);
      },
    );
  }
}
