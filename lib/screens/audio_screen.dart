import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/camera_state_provider.dart';
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: audio.channels.length,
      itemBuilder: (context, index) {
        final channel = audio.channels[index];
        return AudioChannelCard(
          channel: channel,
          onInputTypeChanged: (type) {
            cameraState.setAudioInput(index, type);
          },
          onPhantomPowerChanged: (enabled) {
            cameraState.setPhantomPower(index, enabled);
          },
        );
      },
    );
  }
}
