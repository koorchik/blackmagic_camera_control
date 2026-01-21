import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../../models/camera_state.dart';
import 'format_confirmation_dialog.dart';

class MediaDeviceCard extends StatelessWidget {
  const MediaDeviceCard({
    super.key,
    required this.device,
    this.isFormatting = false,
  });

  final MediaDevice device;
  final bool isFormatting;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  _getDeviceIcon(),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.deviceName.toUpperCase(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (device.isActive)
                        Text(
                          'Active',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.green),
                        ),
                    ],
                  ),
                ),
                if (isFormatting)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Storage progress
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${device.usedSpaceFormatted} used',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${device.remainingSpaceFormatted} free',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: device.usedPercentage,
                  backgroundColor: Colors.grey.shade700,
                  valueColor: AlwaysStoppedAnimation(
                    device.usedPercentage > 0.9
                        ? Colors.red
                        : device.usedPercentage > 0.75
                            ? Colors.orange
                            : Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: ${device.totalSpaceFormatted}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Remaining time
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Remaining: ${device.remainingTimeFormatted}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: 'monospace',
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Format buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: isFormatting
                      ? null
                      : () => _showFormatDialog(context, FilesystemType.hfsPlus),
                  icon: const Icon(Icons.format_paint),
                  label: const Text('HFS+'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: isFormatting
                      ? null
                      : () => _showFormatDialog(context, FilesystemType.exFat),
                  icon: const Icon(Icons.format_paint),
                  label: const Text('ExFAT'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDeviceIcon() {
    final name = device.deviceName.toLowerCase();
    if (name.contains('sd')) {
      return Icons.sd_card;
    } else if (name.contains('cfast')) {
      return Icons.memory;
    } else if (name.contains('usb')) {
      return Icons.usb;
    } else if (name.contains('ssd')) {
      return Icons.storage;
    }
    return Icons.sd_storage;
  }

  Future<void> _showFormatDialog(
    BuildContext context,
    FilesystemType filesystem,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => FormatConfirmationDialog(
        deviceName: device.deviceName,
        filesystem: filesystem,
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<CameraStateProvider>().formatDevice(
            device.deviceName,
            filesystem,
          );
    }
  }
}
