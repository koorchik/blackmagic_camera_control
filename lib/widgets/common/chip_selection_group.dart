import 'package:flutter/material.dart';
import '../../utils/constants.dart';

/// A reusable group of ChoiceChips with consistent styling.
/// Automatically sets showCheckmark: false for a cleaner look.
///
/// Used for selecting from a list of discrete options like
/// white balance presets, focus assist colors, frame guide ratios, etc.
class ChipSelectionGroup<T> extends StatelessWidget {
  const ChipSelectionGroup({
    super.key,
    this.label,
    required this.values,
    required this.selectedValue,
    required this.onSelected,
    required this.labelBuilder,
    this.avatarBuilder,
    this.tooltipBuilder,
    this.spacing = Spacing.sm,
    this.runSpacing = Spacing.sm,
    this.allowDeselect = false,
  });

  /// Optional label shown above the chips
  final String? label;

  /// All possible values
  final List<T> values;

  /// Currently selected value
  final T? selectedValue;

  /// Callback when a chip is selected
  final ValueChanged<T> onSelected;

  /// Builds the label text for each chip
  final String Function(T value) labelBuilder;

  /// Optional builder for chip avatars (e.g., color indicators)
  final Widget Function(T value)? avatarBuilder;

  /// Optional builder for chip tooltips
  final String Function(T value)? tooltipBuilder;

  /// Horizontal spacing between chips
  final double spacing;

  /// Vertical spacing between rows of chips
  final double runSpacing;

  /// Whether tapping a selected chip deselects it
  final bool allowDeselect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Spacing.verticalSm,
        ],
        Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: values.map((value) {
            final isSelected = selectedValue == value;
            final chip = ChoiceChip(
              label: Text(labelBuilder(value)),
              selected: isSelected,
              showCheckmark: false,
              avatar: avatarBuilder?.call(value),
              onSelected: (selected) {
                if (selected || (allowDeselect && isSelected)) {
                  onSelected(value);
                }
              },
            );

            final tooltip = tooltipBuilder?.call(value);
            if (tooltip != null && !isSelected) {
              return Tooltip(
                message: tooltip,
                child: chip,
              );
            }

            return chip;
          }).toList(),
        ),
      ],
    );
  }
}
