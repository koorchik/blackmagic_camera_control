import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../common/control_card.dart';
import 'scene_take_input.dart';
import 'shot_type_selector.dart';
import 'good_take_button.dart';
import 'scene_metadata_selector.dart';

class SlateCard extends StatefulWidget {
  const SlateCard({super.key});

  @override
  State<SlateCard> createState() => _SlateCardState();
}

class _SlateCardState extends State<SlateCard> {
  final GlobalKey<SceneTakeInputState> _sceneTakeKey = GlobalKey();
  bool _isSaving = false;

  void _showSavingIndicator() {
    setState(() => _isSaving = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    });
  }

  Future<void> _showResetDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Slate'),
        content: const Text(
          'This will clear all slate metadata including scene, take number, '
          'shot type, location, time, and good take marker.\n\n'
          'Are you sure you want to reset?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _showSavingIndicator();
      context.read<CameraStateProvider>().resetSlate();
      _sceneTakeKey.currentState?.resetToDefaults();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ControlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          SceneTakeInput(
            key: _sceneTakeKey,
            onSaving: _showSavingIndicator,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ShotTypeSelector(onSaving: _showSavingIndicator),
              ),
              GoodTakeButton(onSaving: _showSavingIndicator),
            ],
          ),
          const SizedBox(height: 16),
          SceneLocationSelector(onSaving: _showSavingIndicator),
          const SizedBox(height: 12),
          SceneTimeSelector(onSaving: _showSavingIndicator),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          'Slate',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(width: 8),
        if (_isSaving)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Saving...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
        const Spacer(),
        TextButton.icon(
          onPressed: _showResetDialog,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Reset'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ],
    );
  }
}
