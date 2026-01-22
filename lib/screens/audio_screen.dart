import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/audio_state.dart';
import '../providers/camera_state_provider.dart';
import '../utils/constants.dart';
import '../widgets/audio/audio_channel_card.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CameraStateProvider>().refreshAudio();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final audio = cameraState.audio;

    if (audio.channels.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No audio channels available',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > Breakpoints.medium;

        if (isWide) {
          // Wide layout: 2 channels side by side
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildWideLayout(cameraState, audio.channels),
          );
        } else {
          // Narrow layout: vertical stack
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: audio.channels.length,
            itemBuilder: (context, index) {
              return _buildChannelCard(cameraState, audio.channels[index]);
            },
          );
        }
      },
    );
  }

  Widget _buildWideLayout(CameraStateProvider cameraState, List<AudioChannelState> channels) {
    final List<Widget> rows = [];

    // Group channels in pairs for side-by-side display
    for (var i = 0; i < channels.length; i += 2) {
      final firstChannel = channels[i];
      final secondChannel = i + 1 < channels.length ? channels[i + 1] : null;

      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildChannelCard(cameraState, firstChannel),
              ),
              if (secondChannel != null) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _buildChannelCard(cameraState, secondChannel),
                ),
              ] else
                const Spacer(),
            ],
          ),
        ),
      );
      if (i + 2 < channels.length) {
        rows.add(const SizedBox(height: 8));
      }
    }

    return Column(children: rows);
  }

  Widget _buildChannelCard(CameraStateProvider cameraState, AudioChannelState channel) {
    return AudioChannelCard(
      channel: channel,
      onInputTypeChanged: (type) {
        cameraState.setAudioInput(channel.index, type);
      },
      onPhantomPowerChanged: (enabled) {
        cameraState.setPhantomPower(channel.index, enabled);
      },
      onGainChanged: (value) {
        cameraState.setAudioGainDebounced(channel.index, value);
      },
      onGainChangeEnd: (value) {
        cameraState.setAudioGainFinal(channel.index, value);
      },
      onLowCutFilterChanged: (enabled) {
        cameraState.setLowCutFilter(channel.index, enabled);
      },
      onPaddingChanged: (enabled) {
        cameraState.setAudioPadding(channel.index, enabled);
      },
    );
  }
}
