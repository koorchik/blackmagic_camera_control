import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../../models/camera_state.dart';

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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with enable toggle
            Row(
              children: [
                const Icon(Icons.center_focus_strong),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Focus Assist',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Switch(
                  value: focusAssistEnabled,
                  onChanged: (enabled) {
                    cameraState.setFocusAssistEnabled(enabled);
                  },
                ),
              ],
            ),
            if (focusAssistEnabled) ...[
              const Divider(),
              // Mode selector
              Text(
                'Mode',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
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
              const SizedBox(height: 16),
              // Color selector
              Text(
                'Color',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: FocusAssistColor.values.map((color) {
                  final isSelected = globalSettings.color == color;
                  return ChoiceChip(
                    label: Text(color.label),
                    selected: isSelected,
                    showCheckmark: false,
                    onSelected: (selected) {
                      if (selected) {
                        cameraState.setFocusAssistSettings(
                          globalSettings.copyWith(color: color),
                        );
                      }
                    },
                    avatar: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getColor(color),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white54),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
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
          ],
        ),
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
