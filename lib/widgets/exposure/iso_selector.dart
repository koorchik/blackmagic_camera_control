import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';

class IsoSelector extends StatelessWidget {
  const IsoSelector({super.key});

  // Get sparse labels - show roughly 5-6 values spread across the range
  List<int> _getSparseLabels(List<int> values) {
    if (values.length <= 6) return values;

    final result = <int>[values.first];
    final step = (values.length - 1) / 4; // 5 labels total
    for (var i = 1; i < 4; i++) {
      result.add(values[(step * i).round()]);
    }
    result.add(values.last);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final currentIso = cameraState.video.iso;
    final supportedISOs = cameraState.capabilities.supportedISOs;

    if (supportedISOs.isEmpty) {
      return const SizedBox.shrink();
    }

    // Find current index, or closest match if exact value not in list
    var currentIndex = supportedISOs.indexOf(currentIso);
    if (currentIndex < 0) {
      // Find closest matching index
      currentIndex = 0;
      var minDiff = (supportedISOs[0] - currentIso).abs();
      for (var i = 1; i < supportedISOs.length; i++) {
        final diff = (supportedISOs[i] - currentIso).abs();
        if (diff < minDiff) {
          minDiff = diff;
          currentIndex = i;
        }
      }
    }

    final sparseLabels = _getSparseLabels(supportedISOs);

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
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                showValueIndicator: ShowValueIndicator.onlyForDiscrete,
              ),
              child: Slider(
                value: currentIndex.toDouble(),
                min: 0,
                max: (supportedISOs.length - 1).toDouble(),
                divisions: supportedISOs.length - 1,
                label: '$currentIso',
                onChanged: (value) {
                  final newIndex = value.round();
                  cameraState.setIso(supportedISOs[newIndex]);
                },
              ),
            ),
            // Sparse labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: sparseLabels.map((iso) {
                  return Text(
                    '$iso',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
