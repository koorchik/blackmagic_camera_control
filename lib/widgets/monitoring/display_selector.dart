import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';

class DisplaySelector extends StatelessWidget {
  const DisplaySelector({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final monitoring = cameraState.monitoring;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.monitor),
            const SizedBox(width: 12),
            Text(
              'Display',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: monitoring.selectedDisplay,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: monitoring.availableDisplays.map((display) {
                  return DropdownMenuItem(
                    value: display,
                    child: Text(_formatDisplayName(display)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    cameraState.selectDisplay(value);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDisplayName(String name) {
    // Convert camelCase or snake_case to readable format
    return name
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (m) => '${m.group(1)} ${m.group(2)}',
        )
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word)
        .join(' ');
  }
}
