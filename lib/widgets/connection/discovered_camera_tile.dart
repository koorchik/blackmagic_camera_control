import 'package:flutter/material.dart';
import '../../models/discovered_camera.dart';

/// A list tile widget for displaying a discovered camera
class DiscoveredCameraTile extends StatelessWidget {
  const DiscoveredCameraTile({
    super.key,
    required this.camera,
    required this.onTap,
    this.isConnecting = false,
  });

  final DiscoveredCamera camera;
  final VoidCallback onTap;
  final bool isConnecting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: isConnecting ? null : onTap,
        leading: Icon(
          Icons.videocam,
          color: theme.colorScheme.primary,
        ),
        title: Text(
          camera.displayName,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              camera.productName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              camera.ipAddress ?? camera.host,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: isConnecting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
      ),
    );
  }
}
