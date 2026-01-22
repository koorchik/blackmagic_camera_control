import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/camera_state_provider.dart';
import '../widgets/media/media_device_card.dart';
import '../widgets/transport/record_button.dart';
import '../widgets/transport/timecode_display.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CameraStateProvider>().refreshMedia();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final media = cameraState.media;

    return Column(
      children: [
        // Recording controls at the top
        const Padding(
          padding: EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  TimecodeDisplay(),
                  SizedBox(height: 16),
                  RecordButton(),
                ],
              ),
            ),
          ),
        ),
        // Media devices list
        Expanded(
          child: media.devices.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sd_card_alert, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No media devices found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: media.devices.length,
                  itemBuilder: (context, index) {
                    final device = media.devices[index];
                    return MediaDeviceCard(
                      device: device,
                      isFormatting: media.formatInProgress &&
                          media.formatDeviceName == device.deviceName,
                    );
                  },
                ),
        ),
      ],
    );
  }
}
