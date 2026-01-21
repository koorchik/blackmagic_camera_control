import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';

class DisplayLutControl extends StatelessWidget {
  const DisplayLutControl({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final currentDisplay = cameraState.monitoring.currentDisplay;

    if (currentDisplay == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.palette_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Display 3D LUT',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Apply LUT to display output',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Switch(
              value: currentDisplay.displayLutEnabled,
              onChanged: (enabled) {
                cameraState.setDisplayLutEnabled(enabled);
              },
            ),
          ],
        ),
      ),
    );
  }
}
