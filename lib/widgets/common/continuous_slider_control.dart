import 'package:flutter/material.dart';
import 'control_card.dart';
import 'debounced_slider.dart';
import '../../utils/constants.dart';

/// A reusable continuous slider control with built-in dragging state management.
/// Uses DebouncedSlider internally for smooth UI during drag operations.
///
/// Used for Focus, Iris, Zoom, and similar continuous value controls where
/// debounced updates are sent during drag and a final value on drag end.
class ContinuousSliderControl extends StatelessWidget {
  const ContinuousSliderControl({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.onChangeEnd,
    required this.formatValue,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.enabled = true,
    this.labels,
    this.showCard = true,
    this.leadingIcon,
    this.trailingIcon,
    this.leadingLabel,
    this.trailingLabel,
  });

  /// The title shown in the header (e.g., "IRIS", "ZOOM")
  final String title;

  /// The current value from the provider
  final double value;

  /// Callback for debounced updates during drag
  final ValueChanged<double> onChanged;

  /// Callback for final value when drag ends
  final ValueChanged<double> onChangeEnd;

  /// Formats the value for display in the header (e.g., "f/2.8", "50%")
  final String Function(double) formatValue;

  /// Minimum slider value
  final double min;

  /// Maximum slider value
  final double max;

  /// Number of discrete divisions (null for continuous)
  final int? divisions;

  /// Whether the slider is enabled
  final bool enabled;

  /// Optional sparse labels to show below the slider
  final List<String>? labels;

  /// Whether to wrap in a card (default: true)
  final bool showCard;

  /// Optional leading icon for the slider row
  final IconData? leadingIcon;

  /// Optional trailing icon for the slider row
  final IconData? trailingIcon;

  /// Optional leading label for the slider row (e.g., "Near")
  final String? leadingLabel;

  /// Optional trailing label for the slider row (e.g., "Far")
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        Spacing.verticalSm,
        _buildSliderRow(context),
        if (labels != null && labels!.isNotEmpty) _buildLabels(context),
      ],
    );

    if (showCard) {
      return ControlCard(child: content);
    }

    return content;
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          formatValue(value),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: enabled
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildSliderRow(BuildContext context) {
    final slider = SliderTheme(
      data: SliderTheme.of(context).copyWith(
        showValueIndicator: divisions != null
            ? ShowValueIndicator.onlyForDiscrete
            : ShowValueIndicator.onlyForContinuous,
      ),
      child: DebouncedSlider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        formatLabel: formatValue,
        enabled: enabled,
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
      ),
    );

    // Check if we have icons or labels for the row
    final hasLeading = leadingIcon != null || leadingLabel != null;
    final hasTrailing = trailingIcon != null || trailingLabel != null;

    if (!hasLeading && !hasTrailing) {
      return slider;
    }

    return Row(
      children: [
        if (leadingIcon != null)
          Icon(leadingIcon, size: 20)
        else if (leadingLabel != null)
          Text(leadingLabel!),
        Expanded(child: slider),
        if (trailingIcon != null)
          Icon(trailingIcon, size: 20)
        else if (trailingLabel != null)
          Text(trailingLabel!),
      ],
    );
  }

  Widget _buildLabels(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: labels!.map((label) {
          return Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: Styles.sliderLabelFontSize,
                ),
          );
        }).toList(),
      ),
    );
  }
}
