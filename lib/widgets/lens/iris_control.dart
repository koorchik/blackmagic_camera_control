import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';

class IrisControl extends StatefulWidget {
  const IrisControl({super.key});

  @override
  State<IrisControl> createState() => _IrisControlState();
}

class _IrisControlState extends State<IrisControl> {
  double? _draggingValue;

  String _getApertureDisplay(double normalized) {
    const fStops = [1.4, 2.0, 2.8, 4.0, 5.6, 8.0, 11, 16, 22];
    final index = (normalized * (fStops.length - 1)).round().clamp(0, fStops.length - 1);
    return 'f/${fStops[index]}';
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final providerIris = cameraState.lens.iris;
    final displayValue = _draggingValue ?? providerIris;

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
                  'IRIS',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  _getApertureDisplay(displayValue),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.camera, size: 16),
                const SizedBox(width: 4),
                const Text('Open'),
                Expanded(
                  child: Slider(
                    value: displayValue,
                    onChanged: (value) {
                      setState(() => _draggingValue = value);
                      cameraState.setIrisDebounced(value);
                    },
                    onChangeEnd: (value) {
                      setState(() => _draggingValue = null);
                      cameraState.setIrisFinal(value);
                    },
                  ),
                ),
                const Text('Close'),
                const SizedBox(width: 4),
                const Icon(Icons.camera, size: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
