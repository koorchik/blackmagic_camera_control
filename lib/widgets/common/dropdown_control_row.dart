import 'package:flutter/material.dart';
import '../../utils/constants.dart';

/// A card with icon, title, optional description, and a dropdown selector.
///
/// Used for controls like Video Format, Codec, Display selector where
/// a single selection is made from a dropdown list.
class DropdownControlRow<T> extends StatelessWidget {
  const DropdownControlRow({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabelBuilder,
    this.fallbackLabel,
  });

  /// Icon shown on the left
  final IconData icon;

  /// Title text
  final String title;

  /// Optional description shown below the title
  final String? description;

  /// Currently selected value (must match one of the items, or null)
  final T? value;

  /// Available items to select from
  final List<T> items;

  /// Callback when selection changes
  final ValueChanged<T?> onChanged;

  /// Builds the display label for each item (defaults to toString)
  final String Function(T item)? itemLabelBuilder;

  /// Label shown when items is empty and value is shown as text
  final String? fallbackLabel;

  String _getLabel(T item) {
    return itemLabelBuilder?.call(item) ?? item.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: Spacing.cardPadding,
        child: Row(
          children: [
            Icon(icon),
            Spacing.horizontalMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (description != null)
                    Text(
                      description!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
            if (items.isEmpty)
              Text(
                value != null ? _getLabel(value as T) : (fallbackLabel ?? 'Unknown'),
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              DropdownButton<T>(
                value: value,
                underline: const SizedBox.shrink(),
                onChanged: onChanged,
                items: items.map((item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(_getLabel(item)),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
