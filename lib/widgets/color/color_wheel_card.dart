import 'package:flutter/material.dart';
import '../../models/camera_state.dart';
import 'color_wheel.dart';

class ColorWheelCard extends StatelessWidget {
  const ColorWheelCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.values,
    required this.onChanged,
    required this.onChangeEnd,
    this.isGain = false,
  });

  final String title;
  final String subtitle;
  final ColorWheelValues values;
  final void Function(ColorWheelValues) onChanged;
  final void Function(ColorWheelValues) onChangeEnd;
  final bool isGain;

  ColorWheelValues get _defaultValues =>
      isGain ? ColorWheelValues.gainDefault : ColorWheelValues.liftGammaDefault;

  bool get _isAtDefault =>
      isGain ? values.isGainDefault : values.isDefault;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            // Color wheel
            Center(
              child: ColorWheel(
                red: values.red,
                green: values.green,
                blue: values.blue,
                size: 180,
                isGain: isGain,
                onChanged: (r, g, b) {
                  onChanged(values.copyWith(red: r, green: g, blue: b));
                },
                onChangeEnd: (r, g, b) {
                  onChangeEnd(values.copyWith(red: r, green: g, blue: b));
                },
              ),
            ),
            const SizedBox(height: 16),
            // Luma slider
            _buildSlider(
              context,
              'Luma',
              values.luma,
              (value) => onChanged(values.copyWith(luma: value)),
              (value) => onChangeEnd(values.copyWith(luma: value)),
            ),
            const Divider(),
            // RGB sliders
            _buildSlider(
              context,
              'Red',
              values.red,
              (value) => onChanged(values.copyWith(red: value)),
              (value) => onChangeEnd(values.copyWith(red: value)),
              activeColor: Colors.red,
            ),
            _buildSlider(
              context,
              'Green',
              values.green,
              (value) => onChanged(values.copyWith(green: value)),
              (value) => onChangeEnd(values.copyWith(green: value)),
              activeColor: Colors.green,
            ),
            _buildSlider(
              context,
              'Blue',
              values.blue,
              (value) => onChanged(values.copyWith(blue: value)),
              (value) => onChangeEnd(values.copyWith(blue: value)),
              activeColor: Colors.blue,
            ),
            // Reset button
            const SizedBox(height: 8),
            TextButton(
              onPressed: _isAtDefault
                  ? null
                  : () => onChangeEnd(_defaultValues),
              child: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    BuildContext context,
    String label,
    double value,
    ValueChanged<double> onChanged,
    ValueChanged<double> onChangeEnd, {
    Color? activeColor,
  }) {
    // Gain uses 0.0-2.0 range (multiplicative), Lift/Gamma use -1.0 to 1.0 (additive)
    final minVal = isGain ? 0.0 : -1.0;
    final maxVal = isGain ? 2.0 : 1.0;

    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value.clamp(minVal, maxVal),
              min: minVal,
              max: maxVal,
              activeColor: activeColor,
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
            ),
          ),
        ),
        SizedBox(
          width: 48,
          child: Text(
            value.toStringAsFixed(2),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
