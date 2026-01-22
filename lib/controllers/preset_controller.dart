import '../models/camera_state.dart';
import '../services/camera_service.dart';

/// Controller for preset-related operations.
class PresetController {
  PresetController({
    required this.getState,
    required this.updateState,
    required this.setError,
    required this.getService,
  });

  final CameraState Function() getState;
  final void Function(CameraState state) updateState;
  final void Function(String error) setError;
  final CameraService? Function() getService;

  /// Fetch preset list and active preset from camera
  Future<void> refresh() async {
    final state = getState();
    updateState(state.copyWith(
      preset: state.preset.copyWith(isLoading: true),
    ));

    try {
      final presetState = await getService()?.fetchPresetState();
      if (presetState != null) {
        final currentState = getState();
        updateState(currentState.copyWith(preset: presetState));
      }
    } catch (e) {
      setError('Failed to fetch presets: $e');
    } finally {
      final currentState = getState();
      updateState(currentState.copyWith(
        preset: currentState.preset.copyWith(isLoading: false),
      ));
    }
  }

  /// Load/apply a preset
  Future<void> loadPreset(String name) async {
    final state = getState();
    updateState(state.copyWith(
      preset: state.preset.copyWith(isLoading: true),
    ));

    try {
      await getService()?.loadPreset(name);
      // After loading, the preset becomes active
      final currentState = getState();
      updateState(currentState.copyWith(
        preset: currentState.preset.copyWith(
          activePreset: name,
          isLoading: false,
        ),
      ));
    } catch (e) {
      setError('Failed to load preset: $e');
      final currentState = getState();
      updateState(currentState.copyWith(
        preset: currentState.preset.copyWith(isLoading: false),
      ));
    }
  }

  /// Save current settings as a new preset
  Future<void> saveAsPreset(String name) async {
    final state = getState();
    updateState(state.copyWith(
      preset: state.preset.copyWith(isLoading: true),
    ));

    try {
      await getService()?.savePreset(name);
      // After saving, refresh the preset list
      await refresh();
    } catch (e) {
      setError('Failed to save preset: $e');
      final currentState = getState();
      updateState(currentState.copyWith(
        preset: currentState.preset.copyWith(isLoading: false),
      ));
    }
  }

  /// Delete a preset
  Future<void> deletePreset(String name) async {
    final state = getState();
    updateState(state.copyWith(
      preset: state.preset.copyWith(isLoading: true),
    ));

    try {
      await getService()?.deletePreset(name);
      // After deleting, refresh the preset list
      await refresh();
    } catch (e) {
      setError('Failed to delete preset: $e');
      final currentState = getState();
      updateState(currentState.copyWith(
        preset: currentState.preset.copyWith(isLoading: false),
      ));
    }
  }
}
