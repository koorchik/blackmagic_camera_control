import 'base_controller.dart';

/// Controller for lens-related operations (focus, iris, zoom, autofocus).
class LensController extends BaseController {
  LensController(super.context);

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

  /// Trigger autofocus at a specific position in frame
  /// [x] and [y] are normalized coordinates (0.0-1.0), defaulting to center
  Future<void> triggerAutofocus({double x = 0.5, double y = 0.5}) async {
    try {
      await getService()?.triggerAutofocus(x: x, y: y);
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
