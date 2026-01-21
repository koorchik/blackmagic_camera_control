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

  // Standard f-stop scale (full stops)
  static const List<double> _fStops = [1.4, 2.0, 2.8, 4.0, 5.6, 8.0, 11, 16, 22];

  String _getApertureDisplay(double normalized) {
    final index = (normalized * (_fStops.length - 1)).round().clamp(0, _fStops.length - 1);
    final fStop = _fStops[index];
    // Format nicely: show decimal only if needed
    return fStop == fStop.roundToDouble() ? 'f/${fStop.toInt()}' : 'f/$fStop';
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
            const SizedBox(height: 8),
            // Slider with discrete divisions
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                showValueIndicator: ShowValueIndicator.onlyForDiscrete,
              ),
              child: Slider(
                value: displayValue,
                divisions: _fStops.length - 1,
                label: _getApertureDisplay(displayValue),
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
            // F-stop scale labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _fStops.map((fStop) {
                  final label = fStop == fStop.roundToDouble()
                      ? '${fStop.toInt()}'
                      : '$fStop';
                  return Text(
                    label,
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
