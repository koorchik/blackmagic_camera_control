import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';

class FocusSlider extends StatefulWidget {
  const FocusSlider({super.key});

  @override
  State<FocusSlider> createState() => _FocusSliderState();
}

class _FocusSliderState extends State<FocusSlider> {
  double? _draggingValue;

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final providerFocus = cameraState.lens.focus;

    // Use local value while dragging, provider value otherwise
    final displayValue = _draggingValue ?? providerFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'FOCUS',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '${(displayValue * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Near'),
            Expanded(
              child: Slider(
                value: displayValue,
                onChanged: (value) {
                  setState(() => _draggingValue = value);
                  // Send debounced API call
                  cameraState.setFocusDebounced(value);
                },
                onChangeEnd: (value) {
                  setState(() => _draggingValue = null);
                  // Send final value immediately
                  cameraState.setFocusFinal(value);
                },
              ),
            ),
            const Text('Far'),
          ],
        ),
      ],
    );
  }
}
