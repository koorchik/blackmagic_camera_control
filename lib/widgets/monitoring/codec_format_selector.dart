import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../../models/camera_capabilities.dart';

class CodecFormatSelector extends StatelessWidget {
  const CodecFormatSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final monitoring = cameraState.monitoring;
    final capabilities = cameraState.capabilities;
    final supportedCodecs = capabilities.supportedCodecFormats;
    final currentCodec = monitoring.currentCodecFormat;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.video_settings_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Codec',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Recording format',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (supportedCodecs.isEmpty)
              Text(
                currentCodec?.displayName ?? 'Unknown',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              DropdownButton<String>(
                value: _findMatchingCodec(currentCodec, supportedCodecs),
                underline: const SizedBox.shrink(),
                onChanged: (value) {
                  if (value != null) {
                    final format = supportedCodecs.firstWhere(
                      (f) => _codecKey(f) == value,
                    );
                    cameraState.setCodecFormat(format.codec, format.container);
                  }
                },
                items: supportedCodecs.map((format) {
                  return DropdownMenuItem<String>(
                    value: _codecKey(format),
                    child: Text(format.displayName),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  /// Unique key for dropdown value (codec already contains variant, e.g., "ProRes:HQ")
  String _codecKey(CodecFormat format) => '${format.codec}|${format.container}';

  String? _findMatchingCodec(CodecFormat? current, List<CodecFormat> formats) {
    if (current == null || formats.isEmpty) return null;

    // Find exact match on codec + container
    for (final format in formats) {
      if (format.codec == current.codec && format.container == current.container) {
        return _codecKey(format);
      }
    }

    // Fallback to first format
    return formats.isNotEmpty ? _codecKey(formats.first) : null;
  }
}
