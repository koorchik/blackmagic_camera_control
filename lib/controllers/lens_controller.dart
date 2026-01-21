import '../models/camera_state.dart';
import '../services/camera_service.dart';

/// Controller for lens-related operations (focus, iris, zoom, autofocus).
class LensController {
  LensController({
    required this.getState,
    required this.updateState,
    required this.setError,
    required this.getService,
  });

  final CameraState Function() getState;
  final void Function(CameraState state) updateState;
  final void Function(String error) setError;
  final CameraService? Function() getService;

  /// Set focus - debounced API call only (no state update, for smooth dragging)
  void setFocusDebounced(double value) {
    getService()?.setFocusDebounced(value);
  }

  /// Set focus position immediately (for drag end)
  void setFocusFinal(double value) {
    final state = getState();
    updateState(state.copyWith(lens: state.lens.copyWith(focus: value)));
    getService()?.setFocus(value);
  }

  /// Trigger autofocus
  Future<void> triggerAutofocus() async {
    try {
      await getService()?.triggerAutofocus();
      // Wait a bit for AF to complete, then fetch new focus position
      await Future.delayed(const Duration(milliseconds: 500));
      final newFocus = await getService()?.getFocus();
      if (newFocus != null) {
        final state = getState();
        updateState(state.copyWith(lens: state.lens.copyWith(focus: newFocus)));
      }
    } catch (e) {
      setError('Autofocus failed: $e');
    }
  }

  /// Set iris - debounced API call only (no state update, for smooth dragging)
  void setIrisDebounced(double value) {
    getService()?.setIrisDebounced(value);
  }

  /// Set iris position immediately (for drag end)
  void setIrisFinal(double value, {Future<void> Function()? onComplete}) {
    final state = getState();
    updateState(state.copyWith(lens: state.lens.copyWith(iris: value)));
    getService()?.setIris(value).then((_) {
      onComplete?.call();
    });
  }

  /// Set zoom - debounced API call only (no state update, for smooth dragging)
  void setZoomDebounced(double value) {
    getService()?.setZoomDebounced(value);
  }

  /// Set zoom position immediately (for drag end)
  void setZoomFinal(double value) {
    final state = getState();
    updateState(state.copyWith(lens: state.lens.copyWith(zoom: value)));
    getService()?.setZoom(value);
  }
}
