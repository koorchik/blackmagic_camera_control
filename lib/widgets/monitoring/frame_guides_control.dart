import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../../models/camera_state.dart';

class FrameGuidesControl extends StatelessWidget {
  const FrameGuidesControl({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final currentDisplay = cameraState.monitoring.currentDisplay;

    if (currentDisplay == null) {
      return const SizedBox.shrink();
    }

    final frameGuidesEnabled = currentDisplay.frameGuides.enabled;
    // Frame guide ratio is a camera-wide setting (not per-display)
    final currentRatio = cameraState.monitoring.currentFrameGuideRatio;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with enable toggle
            Row(
              children: [
                const Icon(Icons.crop_free),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Frame Guides',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Switch(
                  value: frameGuidesEnabled,
                  onChanged: (enabled) {
                    cameraState.setFrameGuidesEnabled(enabled);
                  },
                ),
              ],
            ),
            if (frameGuidesEnabled) ...[
              const Divider(),
              // Ratio selector
              Text(
                'Aspect Ratio',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: FrameGuideRatio.values.map((ratio) {
                  final isSelected = currentRatio == ratio;
                  return ChoiceChip(
                    label: Text(ratio.label),
                    selected: isSelected,
                    showCheckmark: false,
                    onSelected: (selected) {
                      if (selected) {
                        cameraState.setFrameGuideRatio(ratio);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
