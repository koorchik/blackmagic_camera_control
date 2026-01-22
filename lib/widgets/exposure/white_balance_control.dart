import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/video_state.dart';
import '../../providers/camera_state_provider.dart';
import '../../utils/constants.dart';
import '../common/control_card.dart';
import '../common/chip_selection_group.dart';

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
          Row(
            children: [
              Text(
                'WHITE BALANCE',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              FilledButton.tonal(
                onPressed: () {
                  cameraState.triggerAutoWhiteBalance();
                },
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
          ),
          Spacing.verticalMd,
          Slider(
            value: whiteBalance.toDouble(),
            min: 2500,
            max: 10000,
            divisions: 30,
            label: '${whiteBalance}K',
            onChanged: (value) {
              cameraState.setWhiteBalance(value.round());
            },
          ),
          Spacing.verticalSm,
          ChipSelectionGroup<String>(
            values: presetEntries.map((e) => e.key).toList(),
            selectedValue: selectedPreset,
            onSelected: (presetName) {
              final value = VideoState.whiteBalancePresets[presetName];
              if (value != null) {
                cameraState.setWhiteBalance(value);
              }
            },
            labelBuilder: (presetName) => presetName,
          ),
        ],
      ),
    );
  }
}
