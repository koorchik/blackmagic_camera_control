import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';

class ZebraControl extends StatelessWidget {
  const ZebraControl({super.key});

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
            const Icon(Icons.texture),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Zebra',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Highlight overexposed areas',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Switch(
              value: currentDisplay.zebraEnabled,
              onChanged: (enabled) {
                cameraState.setZebraEnabled(enabled);
              },
            ),
          ],
        ),
      ),
    );
  }
}
