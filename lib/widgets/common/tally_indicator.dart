import 'package:flutter/material.dart';
import '../../models/power_state.dart';

/// Displays a colored tally light indicator.
/// - Red: Program (on-air)
/// - Green: Preview
/// - Grey: None/Off
class TallyIndicator extends StatelessWidget {
  const TallyIndicator({
    super.key,
    required this.status,
    this.size = 12.0,
  });

  final TallyStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    // Don't show indicator when tally is off
    if (status == TallyStatus.none) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: 'Tally: ${status.label}',
      child: Container(
        width: size,
        height: size,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getColor(),
          boxShadow: [
            BoxShadow(
              color: _getColor().withAlpha(127),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case TallyStatus.program:
        return Colors.red;
      case TallyStatus.preview:
        return Colors.green;
      case TallyStatus.none:
        return Colors.grey;
    }
  }
}
