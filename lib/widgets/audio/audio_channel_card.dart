import 'package:flutter/material.dart';
import '../../models/camera_state.dart';
import 'vu_meter.dart';

class AudioChannelCard extends StatelessWidget {
  const AudioChannelCard({
    super.key,
    required this.channel,
    required this.onInputTypeChanged,
    required this.onPhantomPowerChanged,
  });

  final AudioChannelState channel;
  final ValueChanged<AudioInputType> onInputTypeChanged;
  final ValueChanged<bool> onPhantomPowerChanged;

  @override
  Widget build(BuildContext context) {
    if (!channel.available) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Channel ${channel.index + 1}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 16),
              const Text(
                'Not available',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Channel ${channel.index + 1}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                _buildLevelText(context),
              ],
            ),
            const SizedBox(height: 16),
            // VU Meter
            Center(
              child: VuMeterWithLabels(
                level: channel.levelNormalized,
                height: 150,
                horizontal: true,
              ),
            ),
            const SizedBox(height: 16),
            // Input Type
            Row(
              children: [
                Text(
                  'Input',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                SegmentedButton<AudioInputType>(
                  segments: AudioInputType.values.map((type) {
                    return ButtonSegment<AudioInputType>(
                      value: type,
                      label: Text(type.label),
                    );
                  }).toList(),
                  selected: {channel.inputType},
                  onSelectionChanged: (selected) {
                    onInputTypeChanged(selected.first);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Phantom Power
            Row(
              children: [
                Text(
                  'Phantom Power (48V)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                Switch(
                  value: channel.phantomPower,
                  onChanged: channel.inputType == AudioInputType.mic
                      ? onPhantomPowerChanged
                      : null,
                ),
              ],
            ),
            if (channel.inputType != AudioInputType.mic)
              Text(
                'Phantom power only available for Mic input',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelText(BuildContext context) {
    // Convert normalized to approximate dB
    final db = channel.levelNormalized > 0
        ? (channel.levelNormalized * 48 - 48).toStringAsFixed(1)
        : '-inf';

    return Text(
      '$db dB',
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontFamily: 'monospace',
            color: channel.levelNormalized > 0.9
                ? Colors.red
                : channel.levelNormalized > 0.75
                    ? Colors.orange
                    : null,
          ),
    );
  }
}
