import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';

class ShutterControl extends StatelessWidget {
  const ShutterControl({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final video = cameraState.video;
    final isAuto = video.shutterAuto;
    final supportedShutterSpeeds = cameraState.capabilities.supportedShutterSpeeds;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SHUTTER',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Row(
                  children: [
                    Text(
                      '1/${video.shutterSpeed}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(width: 12),
                    FilterChip(
                      label: const Text('AUTO'),
                      selected: isAuto,
                      showCheckmark: false,
                      onSelected: (_) {
                        cameraState.toggleShutterAuto();
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: supportedShutterSpeeds.map((speed) {
                final isSelected = speed == video.shutterSpeed;
                return ChoiceChip(
                  label: Text('1/$speed'),
                  selected: isSelected,
                  showCheckmark: false,
                  onSelected: isAuto ? null : (_) {
                    cameraState.setShutterSpeed(speed);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
