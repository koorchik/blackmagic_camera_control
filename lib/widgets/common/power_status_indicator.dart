import 'package:flutter/material.dart';
import '../../models/power_state.dart';

/// Displays power/battery status indicator.
/// Shows battery percentage when on battery, or AC/power icon when on mains.
class PowerStatusIndicator extends StatelessWidget {
  const PowerStatusIndicator({
    super.key,
    required this.powerState,
  });

  final PowerState powerState;

  @override
  Widget build(BuildContext context) {
    // Don't show indicator if we have no power info
    if (powerState.source == PowerSource.unknown &&
        powerState.batteries.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    // Show AC/power icon for non-battery sources
    if (!powerState.isOnBattery) {
      return Tooltip(
        message: 'Power: ${powerState.source.label}',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.power,
            size: 20,
            color: colorScheme.primary,
          ),
        ),
      );
    }

    // Show battery with percentage
    final percent = powerState.primaryBatteryPercent;
    final isCharging = powerState.charging;

    return Tooltip(
      message: isCharging ? 'Charging: $percent%' : 'Battery: $percent%',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getBatteryIcon(percent, isCharging),
              size: 20,
              color: _getBatteryColor(percent, colorScheme),
            ),
            const SizedBox(width: 4),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 12,
                color: _getBatteryColor(percent, colorScheme),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getBatteryIcon(int percent, bool isCharging) {
    if (isCharging) {
      return Icons.battery_charging_full;
    }
    if (percent >= 90) return Icons.battery_full;
    if (percent >= 70) return Icons.battery_6_bar;
    if (percent >= 50) return Icons.battery_4_bar;
    if (percent >= 30) return Icons.battery_3_bar;
    if (percent >= 15) return Icons.battery_2_bar;
    if (percent >= 5) return Icons.battery_1_bar;
    return Icons.battery_alert;
  }

  Color _getBatteryColor(int percent, ColorScheme colorScheme) {
    if (percent <= 10) return Colors.red;
    if (percent <= 20) return Colors.orange;
    return colorScheme.onSurface.withAlpha(179);
  }
}
