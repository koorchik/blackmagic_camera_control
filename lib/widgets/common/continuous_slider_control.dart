import 'package:flutter/material.dart';
import 'control_card.dart';
import '../../utils/constants.dart';

/// A reusable continuous slider control with built-in dragging state management.
/// Handles the _draggingValue pattern internally for smooth UI during drag operations.
///
/// Used for Focus, Iris, Zoom, and similar continuous value controls where
/// debounced updates are sent during drag and a final value on drag end.
class ContinuousSliderControl extends StatefulWidget {
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
  State<ContinuousSliderControl> createState() =>
      _ContinuousSliderControlState();
}

class _ContinuousSliderControlState extends State<ContinuousSliderControl> {
  double? _draggingValue;

  double get _displayValue => _draggingValue ?? widget.value;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        Spacing.verticalSm,
        _buildSliderRow(context),
        if (widget.labels != null && widget.labels!.isNotEmpty)
          _buildLabels(context),
      ],
    );

    if (widget.showCard) {
      return ControlCard(child: content);
    }

    return content;
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          widget.formatValue(_displayValue),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: widget.enabled
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
        showValueIndicator: widget.divisions != null
            ? ShowValueIndicator.onlyForDiscrete
            : ShowValueIndicator.onlyForContinuous,
      ),
      child: Slider(
        value: _displayValue.clamp(widget.min, widget.max),
        min: widget.min,
        max: widget.max,
        divisions: widget.divisions,
        label: widget.formatValue(_displayValue),
        onChanged: widget.enabled
            ? (value) {
                setState(() => _draggingValue = value);
                widget.onChanged(value);
              }
            : null,
        onChangeEnd: widget.enabled
            ? (value) {
                setState(() => _draggingValue = null);
                widget.onChangeEnd(value);
              }
            : null,
      ),
    );

    // Check if we have icons or labels for the row
    final hasLeading =
        widget.leadingIcon != null || widget.leadingLabel != null;
    final hasTrailing =
        widget.trailingIcon != null || widget.trailingLabel != null;

    if (!hasLeading && !hasTrailing) {
      return slider;
    }

    return Row(
      children: [
        if (widget.leadingIcon != null)
          Icon(widget.leadingIcon, size: 20)
        else if (widget.leadingLabel != null)
          Text(widget.leadingLabel!),
        Expanded(child: slider),
        if (widget.trailingIcon != null)
          Icon(widget.trailingIcon, size: 20)
        else if (widget.trailingLabel != null)
          Text(widget.trailingLabel!),
      ],
    );
  }

  Widget _buildLabels(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: widget.labels!.map((label) {
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
