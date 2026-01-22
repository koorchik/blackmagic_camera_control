import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/camera_state.dart';
import '../../providers/camera_state_provider.dart';
import '../common/toggle_control_row.dart';

/// A reusable toggle control for per-display monitoring settings.
///
/// Handles the common pattern of:
/// 1. Checking if a display is selected
/// 2. Getting the value from the display state
/// 3. Rendering a ToggleControlRow
class DisplayToggleControl extends StatelessWidget {
  const DisplayToggleControl({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.getValue,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool Function(DisplayState) getValue;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final currentDisplay = cameraState.monitoring.currentDisplay;

    if (currentDisplay == null) {
      return const SizedBox.shrink();
    }

    return ToggleControlRow(
      icon: icon,
      title: title,
      description: description,
      value: getValue(currentDisplay),
      onChanged: onChanged,
    );
  }
}
