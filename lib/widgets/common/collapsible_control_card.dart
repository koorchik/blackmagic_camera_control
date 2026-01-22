import 'package:flutter/material.dart';
import '../../utils/constants.dart';

/// A card with an icon, title, and toggle switch that shows/hides content when enabled.
///
/// Used for controls like Focus Assist and Frame Guides where the feature can be
/// toggled on/off, and additional settings are shown only when enabled.
class CollapsibleControlCard extends StatelessWidget {
  const CollapsibleControlCard({
    super.key,
    required this.icon,
    required this.title,
    required this.enabled,
    required this.onEnabledChanged,
    required this.child,
  });

  /// Icon shown in the header
  final IconData icon;

  /// Title text
  final String title;

  /// Whether the feature is enabled
  final bool enabled;

  /// Callback when the toggle changes
  final ValueChanged<bool> onEnabledChanged;

  /// Content shown when enabled
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: Spacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with enable toggle
            Row(
              children: [
                Icon(icon),
                Spacing.horizontalMd,
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: onEnabledChanged,
                ),
              ],
            ),
            if (enabled) ...[
              const Divider(),
              child,
            ],
          ],
        ),
      ),
    );
  }
}
