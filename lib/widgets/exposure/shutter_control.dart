import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';

class ShutterControl extends StatelessWidget {
  const ShutterControl({super.key});

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
    final video = cameraState.video;
    final isAuto = video.shutterAuto;
    final supportedShutterSpeeds = cameraState.capabilities.supportedShutterSpeeds;

    if (supportedShutterSpeeds.isEmpty) {
      return const SizedBox.shrink();
    }

    // Find current index, or closest match if exact value not in list
    var currentIndex = supportedShutterSpeeds.indexOf(video.shutterSpeed);
    if (currentIndex < 0) {
      // Find closest matching index
      currentIndex = 0;
      var minDiff = (supportedShutterSpeeds[0] - video.shutterSpeed).abs();
      for (var i = 1; i < supportedShutterSpeeds.length; i++) {
        final diff = (supportedShutterSpeeds[i] - video.shutterSpeed).abs();
        if (diff < minDiff) {
          minDiff = diff;
          currentIndex = i;
        }
      }
    }

    final sparseLabels = _getSparseLabels(supportedShutterSpeeds);

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
                            color: isAuto
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : Theme.of(context).colorScheme.primary,
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
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                showValueIndicator: ShowValueIndicator.onlyForDiscrete,
              ),
              child: Slider(
                value: currentIndex.toDouble(),
                min: 0,
                max: (supportedShutterSpeeds.length - 1).toDouble(),
                divisions: supportedShutterSpeeds.length - 1,
                label: '1/${video.shutterSpeed}',
                onChanged: isAuto
                    ? null
                    : (value) {
                        final newIndex = value.round();
                        cameraState.setShutterSpeed(supportedShutterSpeeds[newIndex]);
                      },
              ),
            ),
            // Sparse labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: sparseLabels.map((speed) {
                  return Text(
                    '1/$speed',
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
