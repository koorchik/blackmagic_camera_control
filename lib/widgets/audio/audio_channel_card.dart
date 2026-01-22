import 'package:flutter/material.dart';
import '../../models/audio_state.dart';
import 'gain_bar.dart';

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
              Icon(Icons.mic_off, color: Colors.grey.shade600),
              const SizedBox(width: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with channel name and level indicator
          _buildHeader(context),
          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input Gain Bar (combined VU meter + slider)
                if (widget.onGainChanged != null) ...[
                  _buildGainSection(context, displayGain),
                  const SizedBox(height: 20),
                ],

                // Input Type Selector
                _buildInputTypeSection(context),
                const SizedBox(height: 16),

                // Audio Options (Phantom Power, Low Cut, Padding)
                _buildOptionsSection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.mic,
            color: colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Channel ${channel.index + 1}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          Text(
            channel.inputType.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildGainSection(BuildContext context, double displayGain) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Input Gain',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 8),
        GainBar(
          value: displayGain,
          minDb: channel.minGain,
          maxDb: channel.maxGain,
          height: 36,
          onChanged: (value) {
            setState(() => _localGain = value);
            widget.onGainChanged?.call(value);
          },
          onChangeEnd: (value) {
            setState(() => _localGain = null);
            widget.onGainChangeEnd?.call(value);
          },
        ),
      ],
    );
  }

  Widget _buildInputTypeSection(BuildContext context) {
    // Use supportedInputs if available, otherwise only show the current input
    // (we don't want to show options that might not be supported)
    final availableInputs = channel.supportedInputs.isNotEmpty
        ? channel.supportedInputs
        : [channel.inputType];

    // If only one input is available, just show it as text
    if (availableInputs.length <= 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Input Source',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.primaryContainer,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            child: Text(
              channel.inputType.label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Input Source',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableInputs.map((type) {
            final isSelected = channel.inputType == type;
            return _buildInputButton(context, type, isSelected);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInputButton(BuildContext context, AudioInputType type, bool isSelected) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: isSelected ? colorScheme.primaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => widget.onInputTypeChanged(type),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outline,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Text(
            type.label,
            style: TextStyle(
              color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsSection(BuildContext context) {
    // Phantom power is available for mic and XLR inputs
    final phantomAvailable = switch (channel.inputType) {
      AudioInputType.mic ||
      AudioInputType.micLeft ||
      AudioInputType.micRight ||
      AudioInputType.micMono ||
      AudioInputType.xlr ||
      AudioInputType.xlrLeft ||
      AudioInputType.xlrRight ||
      AudioInputType.xlrMono =>
        true,
      _ => false,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Options',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),

          // Phantom Power
          _buildOptionRow(
            context,
            icon: Icons.power,
            label: 'Phantom Power (48V)',
            value: channel.phantomPower,
            enabled: phantomAvailable,
            onChanged: widget.onPhantomPowerChanged,
            tooltip: phantomAvailable
                ? null
                : 'Only available for Mic/XLR input',
          ),

          // Low Cut Filter
          if (widget.onLowCutFilterChanged != null) ...[
            const SizedBox(height: 4),
            _buildOptionRow(
              context,
              icon: Icons.graphic_eq,
              label: 'Low Cut Filter',
              value: channel.lowCutFilter,
              enabled: true,
              onChanged: widget.onLowCutFilterChanged!,
              tooltip: 'Reduces low frequency rumble and wind noise',
            ),
          ],

          // Padding
          if (widget.onPaddingChanged != null) ...[
            const SizedBox(height: 4),
            _buildOptionRow(
              context,
              icon: Icons.volume_down,
              label: 'Pad (-20dB)',
              value: channel.padding,
              enabled: true,
              onChanged: widget.onPaddingChanged!,
              tooltip: 'Attenuates loud input signals',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
    String? tooltip,
  }) {
    final content = Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: value && enabled
              ? Theme.of(context).colorScheme.primary
              : Colors.grey,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: enabled ? null : Colors.grey,
                ),
          ),
        ),
        Switch(
          value: value,
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );

    if (tooltip != null && !enabled) {
      return Tooltip(
        message: tooltip,
        child: content,
      );
    }

    return content;
  }
}
