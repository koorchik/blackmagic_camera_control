import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/video_state.dart';
import '../../providers/camera_state_provider.dart';

class WhiteBalanceControl extends StatelessWidget {
  const WhiteBalanceControl({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final whiteBalance = cameraState.video.whiteBalance;

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
                  'WHITE BALANCE',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${whiteBalance}K',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              value: whiteBalance.toDouble(),
              min: 2500,
              max: 10000,
              divisions: 30,
              label: '${whiteBalance}K',
              onChanged: (value) {
                cameraState.setWhiteBalance(value.round());
              },
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: VideoState.whiteBalancePresets.entries.map((entry) {
                final isSelected = (entry.value - whiteBalance).abs() < 100;
                return ChoiceChip(
                  label: Text(entry.key),
                  selected: isSelected,
                  onSelected: (_) {
                    cameraState.setWhiteBalance(entry.value);
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
