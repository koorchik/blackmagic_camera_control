import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../../models/camera_state.dart';
import '../common/collapsible_control_card.dart';
import '../common/chip_selection_group.dart';

class FrameGuidesControl extends StatelessWidget {
  const FrameGuidesControl({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final currentDisplay = cameraState.monitoring.currentDisplay;

    if (currentDisplay == null) {
      return const SizedBox.shrink();
    }

    final frameGuidesEnabled = currentDisplay.frameGuides.enabled;
    // Frame guide ratio is a camera-wide setting (not per-display)
    final currentRatio = cameraState.monitoring.currentFrameGuideRatio;

    return CollapsibleControlCard(
      icon: Icons.crop_free,
      title: 'Frame Guides',
      enabled: frameGuidesEnabled,
      onEnabledChanged: cameraState.setFrameGuidesEnabled,
      child: ChipSelectionGroup<FrameGuideRatio>(
        label: 'Aspect Ratio',
        values: FrameGuideRatio.values,
        selectedValue: currentRatio,
        onSelected: cameraState.setFrameGuideRatio,
        labelBuilder: (ratio) => ratio.label,
      ),
    );
  }
}
