import 'package:flutter/material.dart';
import 'control_card.dart';

/// A reusable discrete slider control with sparse labels.
/// Used for ISO, Shutter, and similar controls with a fixed set of values.
class DiscreteSliderControl<T> extends StatelessWidget {
  const DiscreteSliderControl({
    super.key,
    required this.title,
    required this.currentValue,
    required this.values,
    required this.onChanged,
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

  /// Callback when value changes
  final ValueChanged<T> onChanged;

  /// Formats the value for display in the header (e.g., "800" for ISO, "1/50" for shutter)
  final String Function(T value) formatValue;

  /// Formats the value for sparse labels below the slider
  final String Function(T value) formatLabel;

  /// Whether the slider is enabled
  final bool enabled;

  /// Optional trailing widget (e.g., AUTO chip for shutter)
  final Widget? trailing;

  /// Get sparse labels - show roughly 5-6 values spread across the range
  List<T> _getSparseLabels() {
    if (values.length <= 6) return values;

    final result = <T>[values.first];
    final step = (values.length - 1) / 4; // 5 labels total
    for (var i = 1; i < 4; i++) {
      result.add(values[(step * i).round()]);
    }
    result.add(values.last);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const SizedBox.shrink();
    }

    // Find current index, or closest match if exact value not in list
    var currentIndex = values.indexOf(currentValue);
    if (currentIndex < 0) {
      currentIndex = 0;
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
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Row(
                children: [
                  Text(
                    formatValue(currentValue),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: enabled
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 12),
                    trailing!,
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
              value: currentIndex.toDouble(),
              min: 0,
              max: (values.length - 1).toDouble(),
              divisions: values.length - 1,
              label: formatValue(currentValue),
              onChanged: enabled
                  ? (value) {
                      final newIndex = value.round();
                      onChanged(values[newIndex]);
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
                  formatLabel(val),
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
