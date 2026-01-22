import 'package:flutter/material.dart';
import '../../models/camera_state.dart';
import 'color_wheel.dart';

/// Type of color wheel determining value ranges
enum ColorWheelType {
  lift,   // -2.0 to 2.0, default 0.0
  gamma,  // -4.0 to 4.0, default 0.0
  gain,   // 0.0 to 16.0, default 1.0
  offset, // -2.0 to 2.0, default 0.0
}

class ColorWheelCard extends StatefulWidget {
  const ColorWheelCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.values,
    required this.onChanged,
    required this.onChangeEnd,
    this.isGain = false,
    this.wheelType,
  });

  final String title;
  final String subtitle;
  final ColorWheelValues values;
  final void Function(ColorWheelValues) onChanged;
  final void Function(ColorWheelValues) onChangeEnd;
  final bool isGain;
  /// Optional wheel type for correct value ranges. If not provided, uses isGain flag.
  final ColorWheelType? wheelType;

  @override
  State<ColorWheelCard> createState() => _ColorWheelCardState();
}

class _ColorWheelCardState extends State<ColorWheelCard> {
  // Track local dragging values for each slider
  ColorWheelValues? _draggingValues;

  /// Get the effective wheel type
  ColorWheelType get _effectiveWheelType {
    if (widget.wheelType != null) return widget.wheelType!;
    return widget.isGain ? ColorWheelType.gain : ColorWheelType.lift;
  }

  /// Get min/max/center values based on wheel type
  (double min, double max, double center) get _valueRange {
    switch (_effectiveWheelType) {
      case ColorWheelType.lift:
        return (-2.0, 2.0, 0.0);
      case ColorWheelType.gamma:
        return (-4.0, 4.0, 0.0);
      case ColorWheelType.gain:
        // 0-2 range puts default 1.0 at center (50%)
        return (0.0, 2.0, 1.0);
      case ColorWheelType.offset:
        // API spec: -8.0 to 8.0
        return (-8.0, 8.0, 0.0);
    }
  }

  ColorWheelValues get _defaultValues {
    switch (_effectiveWheelType) {
      case ColorWheelType.gain:
        return ColorWheelValues.gainDefault;
      case ColorWheelType.lift:
      case ColorWheelType.gamma:
      case ColorWheelType.offset:
        return ColorWheelValues.liftGammaDefault;
    }
  }

  bool get _isAtDefault {
    switch (_effectiveWheelType) {
      case ColorWheelType.gain:
        return widget.values.isGainDefault;
      case ColorWheelType.lift:
      case ColorWheelType.gamma:
      case ColorWheelType.offset:
        return widget.values.isDefault;
    }
  }

  // Use local dragging values if actively dragging, otherwise use widget values
  ColorWheelValues get _displayValues => _draggingValues ?? widget.values;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              widget.subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            // Color wheel
            Center(
              child: ColorWheel(
                red: _displayValues.red,
                green: _displayValues.green,
                blue: _displayValues.blue,
                size: 180,
                isGain: widget.isGain,
                minValue: _valueRange.$1,
                maxValue: _valueRange.$2,
                centerValue: _valueRange.$3,
                onChanged: (r, g, b) {
                  final newValues = _displayValues.copyWith(red: r, green: g, blue: b);
                  setState(() => _draggingValues = newValues);
                  widget.onChanged(newValues);
                },
                onChangeEnd: (r, g, b) {
                  final newValues = _displayValues.copyWith(red: r, green: g, blue: b);
                  setState(() => _draggingValues = null);
                  widget.onChangeEnd(newValues);
                },
              ),
            ),
            const SizedBox(height: 16),
            // Luma slider
            _buildSlider(
              context,
              'Luma',
              _displayValues.luma,
              (value) {
                final newValues = _displayValues.copyWith(luma: value);
                setState(() => _draggingValues = newValues);
                widget.onChanged(newValues);
              },
              (value) {
                final newValues = _displayValues.copyWith(luma: value);
                setState(() => _draggingValues = null);
                widget.onChangeEnd(newValues);
              },
            ),
            const Divider(),
            // RGB sliders
            _buildSlider(
              context,
              'Red',
              _displayValues.red,
              (value) {
                final newValues = _displayValues.copyWith(red: value);
                setState(() => _draggingValues = newValues);
                widget.onChanged(newValues);
              },
              (value) {
                final newValues = _displayValues.copyWith(red: value);
                setState(() => _draggingValues = null);
                widget.onChangeEnd(newValues);
              },
              activeColor: Colors.red,
            ),
            _buildSlider(
              context,
              'Green',
              _displayValues.green,
              (value) {
                final newValues = _displayValues.copyWith(green: value);
                setState(() => _draggingValues = newValues);
                widget.onChanged(newValues);
              },
              (value) {
                final newValues = _displayValues.copyWith(green: value);
                setState(() => _draggingValues = null);
                widget.onChangeEnd(newValues);
              },
              activeColor: Colors.green,
            ),
            _buildSlider(
              context,
              'Blue',
              _displayValues.blue,
              (value) {
                final newValues = _displayValues.copyWith(blue: value);
                setState(() => _draggingValues = newValues);
                widget.onChanged(newValues);
              },
              (value) {
                final newValues = _displayValues.copyWith(blue: value);
                setState(() => _draggingValues = null);
                widget.onChangeEnd(newValues);
              },
              activeColor: Colors.blue,
            ),
            // Reset button
            const SizedBox(height: 8),
            TextButton(
              onPressed: _isAtDefault
                  ? null
                  : () => widget.onChangeEnd(_defaultValues),
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
    final (minVal, maxVal, _) = _valueRange;

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
