import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/video_state.dart';
import '../../providers/camera_state_provider.dart';

class IsoSelector extends StatelessWidget {
  const IsoSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final currentIso = cameraState.video.iso;

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
                  'ISO',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '$currentIso',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: VideoState.commonIsoValues.map((iso) {
                final isSelected = iso == currentIso;
                return ChoiceChip(
                  label: Text('$iso'),
                  selected: isSelected,
                  onSelected: (_) {
                    cameraState.setIso(iso);
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
