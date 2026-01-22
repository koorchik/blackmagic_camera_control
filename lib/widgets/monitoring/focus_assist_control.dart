import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../../models/camera_state.dart';
import '../../utils/constants.dart';
import '../common/collapsible_control_card.dart';
import '../common/chip_selection_group.dart';

class FocusAssistControl extends StatelessWidget {
  const FocusAssistControl({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final currentDisplay = cameraState.monitoring.currentDisplay;

    if (currentDisplay == null) {
      return const SizedBox.shrink();
    }

    // Enabled state is per-display
    final focusAssistEnabled = currentDisplay.focusAssist.enabled;
    // Settings (mode, color, intensity) are camera-wide
    final globalSettings = cameraState.monitoring.globalFocusAssistSettings;

    return CollapsibleControlCard(
      icon: Icons.center_focus_strong,
      title: 'Focus Assist',
      enabled: focusAssistEnabled,
      onEnabledChanged: cameraState.setFocusAssistEnabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mode selector
          Text(
            'Mode',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Spacing.verticalSm,
          SegmentedButton<FocusAssistMode>(
            segments: FocusAssistMode.values.map((mode) {
              return ButtonSegment<FocusAssistMode>(
                value: mode,
                label: Text(mode.label),
              );
            }).toList(),
            selected: {globalSettings.mode},
            onSelectionChanged: (selected) {
              cameraState.setFocusAssistSettings(
                globalSettings.copyWith(mode: selected.first),
              );
            },
          ),
          Spacing.verticalLg,
          // Color selector
          ChipSelectionGroup<FocusAssistColor>(
            label: 'Color',
            values: FocusAssistColor.values,
            selectedValue: globalSettings.color,
            onSelected: (color) {
              cameraState.setFocusAssistSettings(
                globalSettings.copyWith(color: color),
              );
            },
            labelBuilder: (color) => color.label,
            avatarBuilder: (color) => Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getColor(color),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white54),
              ),
            ),
          ),
          Spacing.verticalLg,
          // Intensity slider
          Text(
            'Intensity',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Slider(
            value: globalSettings.intensity,
            min: 0.0,
            max: 1.0,
            divisions: 10,
            label: '${(globalSettings.intensity * 100).round()}%',
            onChanged: (value) {
              cameraState.setFocusAssistSettings(
                globalSettings.copyWith(intensity: value),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _getColor(FocusAssistColor color) {
    switch (color) {
      case FocusAssistColor.red:
        return Colors.red;
      case FocusAssistColor.green:
        return Colors.green;
      case FocusAssistColor.blue:
        return Colors.blue;
      case FocusAssistColor.white:
        return Colors.white;
      case FocusAssistColor.black:
        return Colors.black;
    }
  }
}
