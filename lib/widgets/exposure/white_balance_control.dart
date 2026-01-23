import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/video_state.dart';
import '../../providers/camera_state_provider.dart';
import '../../utils/constants.dart';
import '../common/control_card.dart';
import '../common/chip_selection_group.dart';
import '../common/debounced_slider.dart';

/// White balance control using DebouncedSlider for smooth web performance.
class WhiteBalanceControl extends StatelessWidget {
  const WhiteBalanceControl({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final whiteBalance = cameraState.video.whiteBalance;

    // Find the matching preset (within 100K tolerance)
    final presetEntries = VideoState.whiteBalancePresets.entries.toList();
    final selectedPreset = presetEntries
        .where((entry) => (entry.value - whiteBalance).abs() < 100)
        .map((entry) => entry.key)
        .firstOrNull;

    return ControlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WhiteBalanceHeader(
            whiteBalance: whiteBalance,
            onAutoWhiteBalance: cameraState.triggerAutoWhiteBalance,
          ),
          Spacing.verticalMd,
          DebouncedSlider(
            value: whiteBalance.toDouble(),
            min: 2500,
            max: 10000,
            divisions: 30,
            formatLabel: (v) => '${v.round()}K',
            onChanged: (value) => cameraState.setWhiteBalanceDebounced(value.round()),
            onChangeEnd: (value) => cameraState.setWhiteBalanceFinal(value.round()),
          ),
          Spacing.verticalSm,
          ChipSelectionGroup<String>(
            values: presetEntries.map((e) => e.key).toList(),
            selectedValue: selectedPreset,
            onSelected: (presetName) {
              final value = VideoState.whiteBalancePresets[presetName];
              if (value != null) {
                cameraState.setWhiteBalanceFinal(value);
              }
            },
            labelBuilder: (presetName) => presetName,
          ),
        ],
      ),
    );
  }
}

/// Extracted header to avoid rebuilding during slider drag.
class _WhiteBalanceHeader extends StatelessWidget {
  const _WhiteBalanceHeader({
    required this.whiteBalance,
    required this.onAutoWhiteBalance,
  });

  final int whiteBalance;
  final VoidCallback onAutoWhiteBalance;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'WHITE BALANCE',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const Spacer(),
        FilledButton.tonal(
          onPressed: onAutoWhiteBalance,
          style: FilledButton.styleFrom(
            minimumSize: const Size(48, 32),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: const Text('AWB'),
        ),
        Spacing.horizontalMd,
        Text(
          '${whiteBalance}K',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ],
    );
  }
}
