import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';

class ZoomControl extends StatefulWidget {
  const ZoomControl({super.key});

  @override
  State<ZoomControl> createState() => _ZoomControlState();
}

class _ZoomControlState extends State<ZoomControl> {
  double? _draggingValue;

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final providerZoom = cameraState.lens.zoom;
    final displayValue = _draggingValue ?? providerZoom;

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
                  'ZOOM',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${(displayValue * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.zoom_out, size: 20),
                Expanded(
                  child: Slider(
                    value: displayValue,
                    onChanged: (value) {
                      setState(() => _draggingValue = value);
                      cameraState.setZoomDebounced(value);
                    },
                    onChangeEnd: (value) {
                      setState(() => _draggingValue = null);
                      cameraState.setZoomFinal(value);
                    },
                  ),
                ),
                const Icon(Icons.zoom_in, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
