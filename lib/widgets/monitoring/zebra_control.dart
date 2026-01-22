import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import 'display_toggle_control.dart';

class ZebraControl extends StatelessWidget {
  const ZebraControl({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();

    return DisplayToggleControl(
      icon: Icons.texture,
      title: 'Zebra',
      description: 'Highlight overexposed areas',
      getValue: (display) => display.zebraEnabled,
      onChanged: cameraState.setZebraEnabled,
    );
  }
}
