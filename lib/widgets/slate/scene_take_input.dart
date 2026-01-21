import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/camera_state_provider.dart';
import '../../models/camera_state.dart';

/// Widget for scene and take input fields with auto-submit on blur.
class SceneTakeInput extends StatefulWidget {
  const SceneTakeInput({
    super.key,
    required this.onSaving,
  });

  final VoidCallback onSaving;

  @override
  SceneTakeInputState createState() => SceneTakeInputState();
}

class SceneTakeInputState extends State<SceneTakeInput> {
  late TextEditingController _sceneController;
  late TextEditingController _takeController;
  late FocusNode _sceneFocusNode;
  late FocusNode _takeFocusNode;

  String? _lastSyncedScene;
  int? _lastSyncedTake;

  @override
  void initState() {
    super.initState();
    _sceneController = TextEditingController();
    _takeController = TextEditingController();
    _sceneFocusNode = FocusNode();
    _takeFocusNode = FocusNode();

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
      widget.onSaving();
      cameraState.setSlateScene(newValue);
      _lastSyncedScene = newValue;
    }
  }

  void _submitTake() {
    final cameraState = context.read<CameraStateProvider>();
    final take = int.tryParse(_takeController.text);
    if (take != null && take > 0 && take != cameraState.slate.take) {
      widget.onSaving();
      cameraState.setSlateTake(take);
      _lastSyncedTake = take;
    } else {
      _takeController.text = cameraState.slate.take.toString();
    }
  }

  void resetToDefaults() {
    _sceneController.text = '';
    _takeController.text = '1';
    _lastSyncedScene = '';
    _lastSyncedTake = 1;
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncControllersWithProvider();
    });

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
          child: _buildTakeSelector(cameraState, slate),
        ),
      ],
    );
  }

  Widget _buildTakeSelector(CameraStateProvider cameraState, SlateState slate) {
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
            widget.onSaving();
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
}
