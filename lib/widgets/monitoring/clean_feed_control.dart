import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import 'display_toggle_control.dart';

class CleanFeedControl extends StatelessWidget {
  const CleanFeedControl({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();

    return DisplayToggleControl(
      icon: Icons.visibility_off_outlined,
      title: 'Clean Feed',
      description: 'Hide all overlays on output',
      getValue: (display) => display.cleanFeedEnabled,
      onChanged: cameraState.setCleanFeedEnabled,
    );
  }
}
