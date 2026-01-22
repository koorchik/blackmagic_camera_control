import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/camera_state.dart';
import '../../providers/camera_state_provider.dart';
import '../../utils/constants.dart';
import '../common/collapsible_control_card.dart';

/// Frame grids control with API limitations:
/// - Maximum 2 grids can be selected
/// - If 2 grids are selected, one must be "Thirds"
class FrameGridsControl extends StatelessWidget {
  const FrameGridsControl({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final currentDisplay = cameraState.monitoring.currentDisplay;

    if (currentDisplay == null) {
      return const SizedBox.shrink();
    }

    final frameGridsEnabled = currentDisplay.frameGridsEnabled;
    final activeGrids = cameraState.monitoring.activeFrameGrids;

    return CollapsibleControlCard(
      icon: Icons.grid_on,
      title: 'Frame Grids',
      enabled: frameGridsEnabled,
      onEnabledChanged: cameraState.setFrameGridsEnabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Grids',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            'Max 2 grids; if 2 selected, one must be Thirds',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                ),
          ),
          Spacing.verticalSm,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: FrameGridType.values.map((gridType) {
              final isSelected = activeGrids.contains(gridType);
              final canSelect = _canSelectGrid(gridType, activeGrids, isSelected);

              return FilterChip(
                label: Text(gridType.label),
                selected: isSelected,
                onSelected: canSelect
                    ? (selected) {
                        final newGrids = List<FrameGridType>.from(activeGrids);
                        if (selected) {
                          newGrids.add(gridType);
                        } else {
                          newGrids.remove(gridType);
                        }
                        cameraState.setActiveFrameGrids(newGrids);
                      }
                    : null,
                showCheckmark: false,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Check if a grid type can be selected based on API limitations:
  /// - Max 2 grids
  /// - If 2 grids, one must be Thirds
  bool _canSelectGrid(
    FrameGridType gridType,
    List<FrameGridType> activeGrids,
    bool isCurrentlySelected,
  ) {
    // Can always deselect
    if (isCurrentlySelected) return true;

    // Can always select if less than 2 are active
    if (activeGrids.length < 2) {
      // But if 1 is already selected and it's not Thirds,
      // we can only add Thirds
      if (activeGrids.length == 1 &&
          !activeGrids.contains(FrameGridType.thirds) &&
          gridType != FrameGridType.thirds) {
        return false;
      }
      return true;
    }

    // Already have 2 selected, can't add more
    return false;
  }
}
