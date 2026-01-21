import 'package:flutter/material.dart';
import '../../models/camera_state.dart';
import 'vu_meter.dart';

class AudioChannelCard extends StatefulWidget {
  const AudioChannelCard({
    super.key,
    required this.channel,
    required this.onInputTypeChanged,
    required this.onPhantomPowerChanged,
    this.onGainChanged,
    this.onGainChangeEnd,
    this.onLowCutFilterChanged,
    this.onPaddingChanged,
  });

  final AudioChannelState channel;
  final ValueChanged<AudioInputType> onInputTypeChanged;
  final ValueChanged<bool> onPhantomPowerChanged;
  final ValueChanged<double>? onGainChanged;
  final ValueChanged<double>? onGainChangeEnd;
  final ValueChanged<bool>? onLowCutFilterChanged;
  final ValueChanged<bool>? onPaddingChanged;

  @override
  State<AudioChannelCard> createState() => _AudioChannelCardState();
}

class _AudioChannelCardState extends State<AudioChannelCard> {
  double? _localGain;

  AudioChannelState get channel => widget.channel;

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

    // Use local gain while dragging, otherwise use channel value
    final displayGain = _localGain ?? channel.gainNormalized;

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
            // Input Gain Slider
            if (widget.onGainChanged != null) ...[
              _buildGainSlider(context, displayGain),
              const SizedBox(height: 16),
            ],
            // Input Type
            _buildInputTypeSelector(context),
            const SizedBox(height: 12),
            // Phantom Power
            _buildPhantomPowerRow(context),
            const SizedBox(height: 12),
            // Low Cut Filter and Padding
            _buildAudioOptionsRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildGainSlider(BuildContext context, double displayGain) {
    // Calculate dB value for display
    final minDb = channel.minGain;
    final maxDb = channel.maxGain;
    final dbRange = maxDb - minDb;
    final currentDb = minDb + (displayGain * dbRange);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Input Gain',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            Text(
              '${currentDb.toStringAsFixed(1)} dB',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              '${minDb.toInt()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            Expanded(
              child: Slider(
                value: displayGain,
                min: 0.0,
                max: 1.0,
                onChanged: (value) {
                  setState(() => _localGain = value);
                  widget.onGainChanged?.call(value);
                },
                onChangeEnd: (value) {
                  setState(() => _localGain = null);
                  widget.onGainChangeEnd?.call(value);
                },
              ),
            ),
            Text(
              '${maxDb.toInt()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputTypeSelector(BuildContext context) {
    // Use supportedInputs if available, otherwise default to Mic/Line
    final availableInputs = channel.supportedInputs.isNotEmpty
        ? channel.supportedInputs
        : [AudioInputType.mic, AudioInputType.line];

    return Row(
      children: [
        Text(
          'Input',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<AudioInputType>(
              segments: availableInputs.map((type) {
                return ButtonSegment<AudioInputType>(
                  value: type,
                  label: Text(type.label),
                );
              }).toList(),
              selected: {channel.inputType},
              onSelectionChanged: (selected) {
                widget.onInputTypeChanged(selected.first);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhantomPowerRow(BuildContext context) {
    // Phantom power is typically only available for Mic/XLR inputs
    final phantomAvailable = channel.inputType == AudioInputType.mic ||
        channel.inputType == AudioInputType.xlr;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Phantom Power (48V)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            Switch(
              value: channel.phantomPower,
              onChanged: phantomAvailable ? widget.onPhantomPowerChanged : null,
            ),
          ],
        ),
        if (!phantomAvailable)
          Text(
            'Phantom power only available for Mic/XLR input',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
          ),
      ],
    );
  }

  Widget _buildAudioOptionsRow(BuildContext context) {
    return Row(
      children: [
        // Low Cut Filter
        if (widget.onLowCutFilterChanged != null) ...[
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.graphic_eq,
                  size: 18,
                  color: channel.lowCutFilter ? Theme.of(context).colorScheme.primary : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  'Low Cut',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Switch(
                  value: channel.lowCutFilter,
                  onChanged: widget.onLowCutFilterChanged,
                ),
              ],
            ),
          ),
        ],
        // Padding
        if (widget.onPaddingChanged != null) ...[
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.volume_down,
                  size: 18,
                  color: channel.padding ? Theme.of(context).colorScheme.primary : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  'Pad',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                Switch(
                  value: channel.padding,
                  onChanged: widget.onPaddingChanged,
                ),
              ],
            ),
          ),
        ],
      ],
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
