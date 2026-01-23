import 'package:flutter/material.dart';
import 'control_card.dart';

/// A reusable discrete slider control with sparse labels.
/// Used for ISO, Shutter, and similar controls with a fixed set of values.
///
/// Uses local widget state during drag to avoid provider rebuilds (critical for web performance).
/// - `onChanged` is called during drag for optional debounced API calls
/// - `onChangeEnd` is called at drag end for provider state updates
class DiscreteSliderControl<T> extends StatefulWidget {
  const DiscreteSliderControl({
    super.key,
    required this.title,
    required this.currentValue,
    required this.values,
    this.onChanged,
    required this.onChangeEnd,
    required this.formatValue,
    required this.formatLabel,
    this.enabled = true,
    this.trailing,
  });

  /// The title shown in the header (e.g., "ISO", "SHUTTER")
  final String title;

  /// The current value
  final T currentValue;

  /// All possible values for the slider
  final List<T> values;

  /// Optional callback during drag (for debounced API calls only)
  final ValueChanged<T>? onChanged;

  /// Required callback at drag end (for provider state update + API call)
  final ValueChanged<T> onChangeEnd;

  /// Formats the value for display in the header (e.g., "800" for ISO, "1/50" for shutter)
  final String Function(T value) formatValue;

  /// Formats the value for sparse labels below the slider
  final String Function(T value) formatLabel;

  /// Whether the slider is enabled
  final bool enabled;

  /// Optional trailing widget (e.g., AUTO chip for shutter)
  final Widget? trailing;

  @override
  State<DiscreteSliderControl<T>> createState() => _DiscreteSliderControlState<T>();
}

class _DiscreteSliderControlState<T> extends State<DiscreteSliderControl<T>> {
  int? _draggingIndex;

  /// Get sparse labels - show roughly 5-6 values spread across the range
  List<T> _getSparseLabels() {
    if (widget.values.length <= 6) return widget.values;

    final result = <T>[widget.values.first];
    final step = (widget.values.length - 1) / 4; // 5 labels total
    for (var i = 1; i < 4; i++) {
      result.add(widget.values[(step * i).round()]);
    }
    result.add(widget.values.last);
    return result;
  }

  int get _displayIndex {
    if (_draggingIndex != null) return _draggingIndex!;
    var idx = widget.values.indexOf(widget.currentValue);
    return idx < 0 ? 0 : idx;
  }

  T get _displayValue => widget.values[_displayIndex];

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty) {
      return const SizedBox.shrink();
    }

    final sparseLabels = _getSparseLabels();

    return ControlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Row(
                children: [
                  Text(
                    widget.formatValue(_displayValue),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: widget.enabled
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  if (widget.trailing != null) ...[
                    const SizedBox(width: 12),
                    widget.trailing!,
                  ],
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
              value: _displayIndex.toDouble(),
              min: 0,
              max: (widget.values.length - 1).toDouble(),
              divisions: widget.values.length - 1,
              label: widget.formatValue(_displayValue),
              onChanged: widget.enabled
                  ? (value) {
                      final newIndex = value.round();
                      setState(() => _draggingIndex = newIndex);
                      widget.onChanged?.call(widget.values[newIndex]);
                    }
                  : null,
              onChangeEnd: widget.enabled
                  ? (value) {
                      final newIndex = value.round();
                      setState(() => _draggingIndex = null);
                      widget.onChangeEnd(widget.values[newIndex]);
                    }
                  : null,
            ),
          ),
          // Sparse labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: sparseLabels.map((val) {
                return Text(
                  widget.formatLabel(val),
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
    );
  }
}
