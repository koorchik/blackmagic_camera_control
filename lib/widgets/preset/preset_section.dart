import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../../utils/constants.dart';
import '../common/control_card.dart';
import 'save_preset_dialog.dart';

/// Card showing preset list with load/save/delete actions
class PresetSection extends StatefulWidget {
  const PresetSection({super.key});

  @override
  State<PresetSection> createState() => _PresetSectionState();
}

class _PresetSectionState extends State<PresetSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CameraStateProvider>().refreshPresets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final presetState = cameraState.preset;

    return ControlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.save_outlined),
              Spacing.horizontalMd,
              Text(
                'Presets',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              if (presetState.isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => cameraState.refreshPresets(),
                  tooltip: 'Refresh presets',
                  iconSize: 20,
                ),
            ],
          ),
          Spacing.verticalMd,
          if (presetState.availablePresets.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'No presets available',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                      ),
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: presetState.availablePresets.map((name) {
                final isActive = presetState.activePreset == name;
                return _PresetChip(
                  name: name,
                  isActive: isActive,
                  isLoading: presetState.isLoading,
                  onLoad: () => _loadPreset(name),
                  onDelete: () => _confirmDelete(name),
                );
              }).toList(),
            ),
          Spacing.verticalLg,
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: presetState.isLoading ? null : _showSaveDialog,
              icon: const Icon(Icons.add),
              label: const Text('Save Current Settings'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadPreset(String name) async {
    await context.read<CameraStateProvider>().loadPreset(name);
    // After loading a preset, refresh main camera state
    if (mounted) {
      await context.read<CameraStateProvider>().refresh();
    }
  }

  Future<void> _showSaveDialog() async {
    final cameraState = context.read<CameraStateProvider>();
    final existingPresets = cameraState.preset.availablePresets;

    final name = await showDialog<String>(
      context: context,
      builder: (context) => SavePresetDialog(
        existingPresets: existingPresets,
      ),
    );

    if (name != null && mounted) {
      await context.read<CameraStateProvider>().saveAsPreset(name);
    }
  }

  Future<void> _confirmDelete(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Preset'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<CameraStateProvider>().deletePreset(name);
    }
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.name,
    required this.isActive,
    required this.isLoading,
    required this.onLoad,
    required this.onDelete,
  });

  final String name;
  final bool isActive;
  final bool isLoading;
  final VoidCallback onLoad;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(name),
      selected: isActive,
      showCheckmark: false,
      onPressed: isLoading ? null : onLoad,
      onDeleted: isLoading ? null : onDelete,
      deleteIcon: const Icon(Icons.close, size: 18),
    );
  }
}
