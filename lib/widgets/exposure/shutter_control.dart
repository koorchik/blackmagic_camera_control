import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';

class ShutterControl extends StatelessWidget {
  const ShutterControl({super.key});

  static const List<int> _commonShutterSpeeds = [
    24, 25, 30, 48, 50, 60, 96, 100, 120, 180, 250, 500, 1000, 2000,
  ];

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final video = cameraState.video;
    final isAuto = video.shutterAuto;

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
              children: _commonShutterSpeeds.map((speed) {
                final isSelected = speed == video.shutterSpeed;
                return ChoiceChip(
                  label: Text('1/$speed'),
                  selected: isSelected,
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
