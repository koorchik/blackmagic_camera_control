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

    final frameGuides = currentDisplay.frameGuides;

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
                  value: frameGuides.enabled,
                  onChanged: (enabled) {
                    cameraState.setFrameGuides(
                      frameGuides.copyWith(enabled: enabled),
                    );
                  },
                ),
              ],
            ),
            if (frameGuides.enabled) ...[
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
                  final isSelected = frameGuides.ratio == ratio;
                  return ChoiceChip(
                    label: Text(ratio.label),
                    selected: isSelected,
                    showCheckmark: false,
                    onSelected: (selected) {
                      if (selected) {
                        cameraState.setFrameGuides(
                          frameGuides.copyWith(ratio: ratio),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              // Opacity slider
              Text(
                'Opacity',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Slider(
                value: frameGuides.opacity,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: '${(frameGuides.opacity * 100).round()}%',
                onChanged: (value) {
                  cameraState.setFrameGuides(
                    frameGuides.copyWith(opacity: value),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
