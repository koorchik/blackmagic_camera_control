import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../../models/camera_state.dart';

class SlateCard extends StatefulWidget {
  const SlateCard({super.key});

  @override
  State<SlateCard> createState() => _SlateCardState();
}

class _SlateCardState extends State<SlateCard> {
  late TextEditingController _sceneController;
  late TextEditingController _takeController;
  late FocusNode _sceneFocusNode;
  late FocusNode _takeFocusNode;

  bool _isSaving = false;
  String? _lastSyncedScene;
  int? _lastSyncedTake;

  @override
  void initState() {
    super.initState();
    _sceneController = TextEditingController();
    _takeController = TextEditingController();
    _sceneFocusNode = FocusNode();
    _takeFocusNode = FocusNode();

    // Add blur listeners for auto-submit
    _sceneFocusNode.addListener(_onSceneFocusChange);
    _takeFocusNode.addListener(_onTakeFocusChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncControllersWithProvider();
  }

  void _syncControllersWithProvider() {
    final slate = context.read<CameraStateProvider>().slate;

    // Only update if not currently editing and value changed from server
    if (!_sceneFocusNode.hasFocus && slate.scene != _lastSyncedScene) {
      _sceneController.text = slate.scene;
      _lastSyncedScene = slate.scene;
    }

    if (!_takeFocusNode.hasFocus && slate.take != _lastSyncedTake) {
      _takeController.text = slate.take.toString();
      _lastSyncedTake = slate.take;
    }
  }

  void _onSceneFocusChange() {
    if (!_sceneFocusNode.hasFocus) {
      _submitScene();
    }
  }

  void _onTakeFocusChange() {
    if (!_takeFocusNode.hasFocus) {
      _submitTake();
    }
  }

  void _submitScene() {
    final cameraState = context.read<CameraStateProvider>();
    final newValue = _sceneController.text;
    if (newValue != cameraState.slate.scene) {
      _showSavingIndicator();
      cameraState.setSlateScene(newValue);
      _lastSyncedScene = newValue;
    }
  }

  void _submitTake() {
    final cameraState = context.read<CameraStateProvider>();
    final take = int.tryParse(_takeController.text);
    if (take != null && take > 0 && take != cameraState.slate.take) {
      _showSavingIndicator();
      cameraState.setSlateTake(take);
      _lastSyncedTake = take;
    } else {
      // Revert to valid value if invalid
      _takeController.text = cameraState.slate.take.toString();
    }
  }

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
      // Update controllers with reset values
      _sceneController.text = '';
      _takeController.text = '1';
      _lastSyncedScene = '';
      _lastSyncedTake = 1;
    }
  }

  @override
  void dispose() {
    _sceneFocusNode.removeListener(_onSceneFocusChange);
    _takeFocusNode.removeListener(_onTakeFocusChange);
    _sceneController.dispose();
    _takeController.dispose();
    _sceneFocusNode.dispose();
    _takeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = context.watch<CameraStateProvider>();
    final slate = cameraState.slate;

    // Sync controllers when provider updates (e.g., from WebSocket)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncControllersWithProvider();
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with title, saving indicator, and reset button
            _buildHeader(context),
            const SizedBox(height: 16),
            // Scene and Take row
            _buildSceneTakeRow(context, cameraState, slate),
            const SizedBox(height: 16),
            // Shot Type with Good Take
            _buildShotTypeSection(context, cameraState, slate),
            const SizedBox(height: 16),
            // Location section
            _buildLocationSection(context, cameraState, slate),
            const SizedBox(height: 12),
            // Time section
            _buildTimeSection(context, cameraState, slate),
          ],
        ),
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

  Widget _buildSceneTakeRow(
    BuildContext context,
    CameraStateProvider cameraState,
    SlateState slate,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: _sceneController,
            focusNode: _sceneFocusNode,
            decoration: const InputDecoration(
              labelText: 'Scene',
              border: OutlineInputBorder(),
              isDense: true,
              hintText: 'e.g., 1A, 2B',
            ),
            onSubmitted: (_) => _submitScene(),
            textInputAction: TextInputAction.done,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTakeSelector(context, cameraState, slate),
        ),
      ],
    );
  }

  Widget _buildTakeSelector(
    BuildContext context,
    CameraStateProvider cameraState,
    SlateState slate,
  ) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _takeController,
            focusNode: _takeFocusNode,
            decoration: const InputDecoration(
              labelText: 'Take',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            keyboardType: TextInputType.number,
            onSubmitted: (_) => _submitTake(),
            textInputAction: TextInputAction.done,
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: () {
            _showSavingIndicator();
            cameraState.incrementSlateTake();
            _takeController.text = (slate.take + 1).toString();
            _lastSyncedTake = slate.take + 1;
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.all(12),
            minimumSize: Size.zero,
          ),
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  Widget _buildShotTypeSection(
    BuildContext context,
    CameraStateProvider cameraState,
    SlateState slate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Shot Type',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            // Good Take button in the same row
            _buildGoodTakeButton(context, cameraState, slate),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ShotType.values.map((type) {
            final isSelected = slate.shotType == type;
            // Show full label when selected, code only when not selected
            final label = isSelected ? '${type.code} - ${type.label}' : type.code;
            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (selected) {
                _showSavingIndicator();
                cameraState.setSlateShotType(selected ? type : null);
              },
              tooltip: isSelected ? null : type.label,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGoodTakeButton(
    BuildContext context,
    CameraStateProvider cameraState,
    SlateState slate,
  ) {
    return slate.goodTake
        ? FilledButton.tonalIcon(
            onPressed: () {
              _showSavingIndicator();
              cameraState.setSlateGoodTake(false);
            },
            icon: const Icon(Icons.star, size: 18),
            label: const Text('Good Take'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          )
        : OutlinedButton.icon(
            onPressed: () {
              _showSavingIndicator();
              cameraState.setSlateGoodTake(true);
            },
            icon: const Icon(Icons.star_border, size: 18),
            label: const Text('Good Take'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
  }

  Widget _buildLocationSection(
    BuildContext context,
    CameraStateProvider cameraState,
    SlateState slate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        SegmentedButton<SceneLocation?>(
          segments: [
            const ButtonSegment<SceneLocation?>(
              value: null,
              label: Text('None'),
            ),
            ...SceneLocation.values.map((location) => ButtonSegment<SceneLocation?>(
                  value: location,
                  label: Text(location.label),
                )),
          ],
          selected: {slate.sceneLocation},
          onSelectionChanged: (selection) {
            _showSavingIndicator();
            cameraState.setSlateLocation(selection.first);
          },
          showSelectedIcon: false,
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSection(
    BuildContext context,
    CameraStateProvider cameraState,
    SlateState slate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        SegmentedButton<SceneTime?>(
          segments: [
            const ButtonSegment<SceneTime?>(
              value: null,
              label: Text('None'),
            ),
            ...SceneTime.values.map((time) => ButtonSegment<SceneTime?>(
                  value: time,
                  label: Text(time.label),
                )),
          ],
          selected: {slate.sceneTime},
          onSelectionChanged: (selection) {
            _showSavingIndicator();
            cameraState.setSlateTime(selection.first);
          },
          showSelectedIcon: false,
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}
