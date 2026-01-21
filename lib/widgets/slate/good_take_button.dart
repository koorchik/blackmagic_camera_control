import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';

/// Toggle button for marking a take as good.
class GoodTakeButton extends StatelessWidget {
  const GoodTakeButton({
    super.key,
    required this.onSaving,
  });

  final VoidCallback onSaving;

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final isGoodTake = cameraState.slate.goodTake;

    if (isGoodTake) {
      return FilledButton.tonalIcon(
        onPressed: () {
          onSaving();
          cameraState.setSlateGoodTake(false);
        },
        icon: const Icon(Icons.star, size: 18),
        label: const Text('Good Take'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: () {
        onSaving();
        cameraState.setSlateGoodTake(true);
      },
      icon: const Icon(Icons.star_border, size: 18),
      label: const Text('Good Take'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
