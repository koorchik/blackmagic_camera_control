import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../../utils/constants.dart';
import '../common/collapsible_control_card.dart';
import '../common/debounced_slider.dart';

/// Safe area control using DebouncedSlider for smooth web performance.
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
          DebouncedSlider(
            value: safeAreaPercent.toDouble(),
            min: 50,
            max: 100,
            divisions: 10,
            formatLabel: (v) => '${v.round()}%',
            onChanged: (value) => cameraState.setSafeAreaPercentDebounced(value.round()),
            onChangeEnd: (value) => cameraState.setSafeAreaPercentFinal(value.round()),
          ),
        ],
      ),
    );
  }
}
