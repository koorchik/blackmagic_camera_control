import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import 'display_toggle_control.dart';

class FalseColorControl extends StatelessWidget {
  const FalseColorControl({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();

    return DisplayToggleControl(
      icon: Icons.palette,
      title: 'False Color',
      description: 'Color-coded exposure overlay',
      getValue: (display) => display.falseColorEnabled,
      onChanged: cameraState.setFalseColorEnabled,
    );
  }
}
