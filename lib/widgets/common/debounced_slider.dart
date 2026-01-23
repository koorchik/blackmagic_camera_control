import 'package:flutter/material.dart';

/// A Slider wrapper that manages local dragging state to prevent UI lag.
///
/// This is the core building block for all slider controls. It handles:
/// - Local `_draggingValue` state during drag (no provider rebuilds)
/// - `onChanged` callback for debounced API calls during drag
/// - `onChangeEnd` callback for final state update + API call
///
/// Use this instead of raw Slider widgets to ensure smooth web performance.
///
/// Example:
/// ```dart
/// DebouncedSlider(
///   value: someProviderValue,
///   min: 0,
///   max: 100,
///   onChanged: (v) => provider.setValueDebounced(v),  // API only
///   onChangeEnd: (v) => provider.setValueFinal(v),     // State + API
/// )
/// ```
class DebouncedSlider extends StatefulWidget {
  const DebouncedSlider({
    super.key,
    required this.value,
    required this.onChangeEnd,
    this.onChanged,
    this.onChangeStart,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.enabled = true,
    this.formatLabel,
  });

  /// The current value from provider/state
  final double value;

  /// Called during drag (for debounced API calls only - should NOT update provider state)
  final ValueChanged<double>? onChanged;

  /// Called at drag start
  final ValueChanged<double>? onChangeStart;

  /// Called at drag end (for provider state update + final API call)
  final ValueChanged<double> onChangeEnd;

  /// Minimum value
  final double min;

  /// Maximum value
  final double max;

  /// Number of discrete divisions (null for continuous)
  final int? divisions;

  /// Static label for the slider tooltip
  final String? label;

  /// Optional function to format the label based on current value
  final String Function(double)? formatLabel;

  /// Active track color
  final Color? activeColor;

  /// Inactive track color
  final Color? inactiveColor;

  /// Thumb color
  final Color? thumbColor;

  /// Whether the slider is enabled
  final bool enabled;

  @override
  State<DebouncedSlider> createState() => _DebouncedSliderState();
}

class _DebouncedSliderState extends State<DebouncedSlider> {
  double? _draggingValue;
  bool _isDragging = false;

  double get _displayValue => _draggingValue ?? widget.value;

  @override
  void didUpdateWidget(DebouncedSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only sync external value when not dragging
    if (!_isDragging && oldWidget.value != widget.value) {
      _draggingValue = null;
    }
  }

  void _handleChangeStart(double value) {
    setState(() {
      _isDragging = true;
      _draggingValue = value;
    });
    widget.onChangeStart?.call(value);
  }

  void _handleChange(double value) {
    setState(() {
      _draggingValue = value;
    });
    widget.onChanged?.call(value);
  }

  void _handleChangeEnd(double value) {
    widget.onChangeEnd(value);
    setState(() {
      _isDragging = false;
      _draggingValue = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final clampedValue = _displayValue.clamp(widget.min, widget.max);
    final label = widget.formatLabel?.call(clampedValue) ?? widget.label;

    return Slider(
      value: clampedValue,
      min: widget.min,
      max: widget.max,
      divisions: widget.divisions,
      label: label,
      activeColor: widget.activeColor,
      inactiveColor: widget.inactiveColor,
      thumbColor: widget.thumbColor,
      onChangeStart: widget.enabled ? _handleChangeStart : null,
      onChanged: widget.enabled ? _handleChange : null,
      onChangeEnd: widget.enabled ? _handleChangeEnd : null,
    );
  }
}
