import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../../models/camera_state.dart';

class SlateCard extends StatelessWidget {
  const SlateCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final slate = cameraState.slate;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Slate',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            // Scene and Take row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Scene',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    controller: TextEditingController(text: slate.scene),
                    onSubmitted: (value) {
                      cameraState.setSlateScene(value);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTakeSelector(context, cameraState, slate),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Shot Type
            Text(
              'Shot Type',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ShotType.values.map((type) {
                final isSelected = slate.shotType == type;
                return ChoiceChip(
                  label: Text(type.code),
                  selected: isSelected,
                  showCheckmark: false,
                  onSelected: (selected) {
                    cameraState.setSlateShotType(selected ? type : null);
                  },
                  tooltip: type.label,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Location and Time row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: SceneLocation.values.map((location) {
                          final isSelected = slate.sceneLocation == location;
                          return ChoiceChip(
                            label: Text(location.code),
                            selected: isSelected,
                            showCheckmark: false,
                            onSelected: (selected) {
                              cameraState.setSlateLocation(
                                selected ? location : null,
                              );
                            },
                            tooltip: location.label,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: SceneTime.values.map((time) {
                          final isSelected = slate.sceneTime == time;
                          return ChoiceChip(
                            label: Text(time.code),
                            selected: isSelected,
                            showCheckmark: false,
                            onSelected: (selected) {
                              cameraState.setSlateTime(selected ? time : null);
                            },
                            tooltip: time.label,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Good Take
            Row(
              children: [
                FilterChip(
                  label: const Text('Good Take'),
                  selected: slate.goodTake,
                  showCheckmark: false,
                  onSelected: (selected) {
                    cameraState.setSlateGoodTake(selected);
                  },
                  avatar: Icon(
                    slate.goodTake ? Icons.star : Icons.star_border,
                    size: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTakeSelector(
    BuildContext context,
    CameraStateProvider cameraState,
    SlateState slate,
  ) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Take',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            controller: TextEditingController(text: slate.take.toString()),
            keyboardType: TextInputType.number,
            onSubmitted: (value) {
              final take = int.tryParse(value);
              if (take != null && take > 0) {
                cameraState.setSlateTake(take);
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: cameraState.incrementSlateTake,
          icon: const Icon(Icons.add),
          tooltip: 'Next Take',
        ),
      ],
    );
  }
}
