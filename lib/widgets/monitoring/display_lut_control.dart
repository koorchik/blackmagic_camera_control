import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import 'display_toggle_control.dart';

class DisplayLutControl extends StatelessWidget {
  const DisplayLutControl({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();

    return DisplayToggleControl(
      icon: Icons.palette_outlined,
      title: 'Display 3D LUT',
      description: 'Apply LUT to display output',
      getValue: (display) => display.displayLutEnabled,
      onChanged: cameraState.setDisplayLutEnabled,
    );
  }
}
