import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';

class CleanFeedControl extends StatelessWidget {
  const CleanFeedControl({super.key});

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
            const Icon(Icons.visibility_off_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Clean Feed',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Hide all overlays on output',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Switch(
              value: currentDisplay.cleanFeedEnabled,
              onChanged: (enabled) {
                cameraState.setCleanFeedEnabled(enabled);
              },
            ),
          ],
        ),
      ),
    );
  }
}
