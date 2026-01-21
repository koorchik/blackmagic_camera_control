import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/discovered_camera.dart';
import '../../providers/camera_connection_provider.dart';
import 'discovered_camera_tile.dart';

/// Widget that encapsulates the camera discovery UI
class DiscoverySection extends StatelessWidget {
  const DiscoverySection({super.key});

  @override
  Widget build(BuildContext context) {
    final connection = context.watch<CameraConnectionProvider>();
    final isDiscovering = connection.isDiscovering;
    final isConnecting = connection.status == ConnectionStatus.connecting;
    final cameras = connection.discoveredCameras;
    final discoveryStatus = connection.discoveryStatus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Scan button
        OutlinedButton.icon(
          onPressed: isDiscovering || isConnecting
              ? null
              : () => connection.startDiscovery(),
          icon: isDiscovering
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.wifi_find),
          label: Text(isDiscovering ? 'Scanning...' : 'Scan for Cameras'),
        ),

        // Discovery results
        if (isDiscovering || cameras.isNotEmpty || discoveryStatus == DiscoveryStatus.error) ...[
          const SizedBox(height: 16),
          _buildDiscoveryResults(context, connection),
        ],

        // Discovery error
        if (discoveryStatus == DiscoveryStatus.error) ...[
          const SizedBox(height: 8),
          _buildErrorMessage(context, connection.discoveryErrorMessage),
        ],

        // Empty state after completed scan
        if (discoveryStatus == DiscoveryStatus.completed && cameras.isEmpty) ...[
          const SizedBox(height: 16),
          _buildEmptyState(context),
        ],
      ],
    );
  }

  Widget _buildDiscoveryResults(
    BuildContext context,
    CameraConnectionProvider connection,
  ) {
    final cameras = connection.discoveredCameras;
    final isConnecting = connection.status == ConnectionStatus.connecting;

    if (cameras.isEmpty && connection.isDiscovering) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Searching for cameras...'),
        ),
      );
    }

    if (cameras.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discovered Cameras:',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        ...cameras.map(
          (camera) => DiscoveredCameraTile(
            camera: camera,
            isConnecting: isConnecting,
            onTap: () => _connectToCamera(context, camera),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            Icons.videocam_off_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text(
            'No cameras found',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Make sure your camera is on the same network and has network control enabled.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _connectToCamera(BuildContext context, DiscoveredCamera camera) {
    context.read<CameraConnectionProvider>().connectToDiscoveredCamera(camera);
  }
}
