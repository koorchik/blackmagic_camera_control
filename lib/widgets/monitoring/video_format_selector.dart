import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../../models/camera_capabilities.dart';

class VideoFormatSelector extends StatelessWidget {
  const VideoFormatSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final monitoring = cameraState.monitoring;
    final capabilities = cameraState.capabilities;
    final supportedFormats = capabilities.supportedVideoFormats;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.movie_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Video Format',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Resolution and frame rate',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (supportedFormats.isEmpty)
              Text(
                monitoring.currentVideoFormat ?? 'Unknown',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              DropdownButton<String>(
                value: _findMatchingFormat(monitoring.currentVideoFormat, supportedFormats),
                underline: const SizedBox.shrink(),
                onChanged: (value) {
                  if (value != null) {
                    final format = supportedFormats.firstWhere(
                      (f) => f.displayString == value,
                    );
                    cameraState.setVideoFormat(format.name, format.frameRate);
                  }
                },
                items: supportedFormats.map((format) {
                  return DropdownMenuItem<String>(
                    value: format.displayString,
                    child: Text(format.displayString),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  String? _findMatchingFormat(String? current, List<VideoFormat> formats) {
    if (current == null || formats.isEmpty) return null;

    // Try to find exact match
    for (final format in formats) {
      if (format.displayString == current) {
        return format.displayString;
      }
    }

    // If no match found, return the first format as default
    return formats.first.displayString;
  }
}
