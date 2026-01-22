import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../../utils/constants.dart';
import '../common/collapsible_control_card.dart';

class SafeAreaControl extends StatelessWidget {
  const SafeAreaControl({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final currentDisplay = cameraState.monitoring.currentDisplay;

    if (currentDisplay == null) {
      return const SizedBox.shrink();
    }

    final safeAreaEnabled = currentDisplay.safeAreaEnabled;
    final safeAreaPercent = cameraState.monitoring.safeAreaPercent;

    return CollapsibleControlCard(
      icon: Icons.crop_din,
      title: 'Safe Area',
      enabled: safeAreaEnabled,
      onEnabledChanged: cameraState.setSafeAreaEnabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Area Percentage',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '$safeAreaPercent%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          Spacing.verticalSm,
          Slider(
            value: safeAreaPercent.toDouble(),
            min: 50,
            max: 100,
            divisions: 10,
            label: '$safeAreaPercent%',
            onChanged: (value) {
              cameraState.setSafeAreaPercent(value.round());
            },
          ),
        ],
      ),
    );
  }
}
