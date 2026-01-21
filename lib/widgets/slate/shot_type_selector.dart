import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../../models/camera_state.dart';

/// Widget for shot type selection with choice chips.
class ShotTypeSelector extends StatelessWidget {
  const ShotTypeSelector({
    super.key,
    required this.onSaving,
  });

  final VoidCallback onSaving;

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final slate = cameraState.slate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shot Type',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ShotType.values.map((type) {
            final isSelected = slate.shotType == type;
            final label = isSelected ? '${type.code} - ${type.label}' : type.code;
            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (selected) {
                onSaving();
                cameraState.setSlateShotType(selected ? type : null);
              },
              tooltip: isSelected ? null : type.label,
            );
          }).toList(),
        ),
      ],
    );
  }
}
