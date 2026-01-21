import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';

class ProgramFeedControl extends StatelessWidget {
  const ProgramFeedControl({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final monitoring = cameraState.monitoring;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.cast_connected),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Program Return Feed',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Display ATEM switcher program output',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Switch(
              value: monitoring.programFeedEnabled,
              onChanged: (enabled) {
                cameraState.setProgramFeedEnabled(enabled);
              },
            ),
          ],
        ),
      ),
    );
  }
}
