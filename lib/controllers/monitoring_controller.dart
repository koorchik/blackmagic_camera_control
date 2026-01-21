import '../models/camera_state.dart';
import '../services/camera_service.dart';

/// Controller for monitoring-related operations.
class MonitoringController {
  MonitoringController({
    required this.getState,
    required this.updateState,
    required this.setError,
    required this.getService,
  });

  final CameraState Function() getState;
  final void Function(CameraState state) updateState;
  final void Function(String error) setError;
  final CameraService? Function() getService;

  /// Fetch fresh monitoring state
  Future<void> refresh() async {
    try {
      final monitoring = await getService()?.fetchMonitoringState();
      if (monitoring != null) {
        final state = getState();
        updateState(state.copyWith(monitoring: monitoring));
      }
    } catch (e) {
      setError('Failed to fetch monitoring state: $e');
    }
  }

  /// Select a display for monitoring settings
  void selectDisplay(String displayName) {
    final state = getState();
    updateState(state.copyWith(
      monitoring: state.monitoring.copyWith(selectedDisplay: displayName),
    ));
  }

  /// Set focus assist for current display
  void setFocusAssist(FocusAssistState focusAssist) {
    final state = getState();
    final displayName = state.monitoring.selectedDisplay;
    if (displayName == null) return;

    final currentDisplay = state.monitoring.displays[displayName];
    if (currentDisplay == null) return;

    final updatedDisplay = currentDisplay.copyWith(focusAssist: focusAssist);
    updateState(state.copyWith(
      monitoring: state.monitoring.updateDisplay(displayName, updatedDisplay),
    ));

    getService()?.setFocusAssist(displayName, focusAssist).catchError((e) {
      setError('Failed to set focus assist: $e');
    });
  }

  /// Set zebra enabled for current display
  void setZebraEnabled(bool enabled) {
    final state = getState();
    final displayName = state.monitoring.selectedDisplay;
    if (displayName == null) return;

    final currentDisplay = state.monitoring.displays[displayName];
    if (currentDisplay == null) return;

    final updatedDisplay = currentDisplay.copyWith(zebraEnabled: enabled);
    updateState(state.copyWith(
      monitoring: state.monitoring.updateDisplay(displayName, updatedDisplay),
    ));

    getService()?.setZebraEnabled(displayName, enabled).catchError((e) {
      setError('Failed to set zebra: $e');
    });
  }

  /// Set frame guides for current display
  void setFrameGuides(FrameGuidesState frameGuides) {
    final state = getState();
    final displayName = state.monitoring.selectedDisplay;
    if (displayName == null) return;

    final currentDisplay = state.monitoring.displays[displayName];
    if (currentDisplay == null) return;

    final updatedDisplay = currentDisplay.copyWith(frameGuides: frameGuides);
    updateState(state.copyWith(
      monitoring: state.monitoring.updateDisplay(displayName, updatedDisplay),
    ));

    getService()?.setFrameGuides(displayName, frameGuides).catchError((e) {
      setError('Failed to set frame guides: $e');
    });
  }

  /// Set clean feed enabled for current display
  void setCleanFeedEnabled(bool enabled) {
    final state = getState();
    final displayName = state.monitoring.selectedDisplay;
    if (displayName == null) return;

    final currentDisplay = state.monitoring.displays[displayName];
    if (currentDisplay == null) return;

    final updatedDisplay = currentDisplay.copyWith(cleanFeedEnabled: enabled);
    updateState(state.copyWith(
      monitoring: state.monitoring.updateDisplay(displayName, updatedDisplay),
    ));

    getService()?.setCleanFeedEnabled(displayName, enabled).catchError((e) {
      setError('Failed to set clean feed: $e');
    });
  }

  /// Set display LUT enabled for current display
  void setDisplayLutEnabled(bool enabled) {
    final state = getState();
    final displayName = state.monitoring.selectedDisplay;
    if (displayName == null) return;

    final currentDisplay = state.monitoring.displays[displayName];
    if (currentDisplay == null) return;

    final updatedDisplay = currentDisplay.copyWith(displayLutEnabled: enabled);
    updateState(state.copyWith(
      monitoring: state.monitoring.updateDisplay(displayName, updatedDisplay),
    ));

    getService()?.setDisplayLutEnabled(displayName, enabled).catchError((e) {
      setError('Failed to set display LUT: $e');
    });
  }

  /// Set program feed display enabled (camera-wide)
  void setProgramFeedEnabled(bool enabled) {
    final state = getState();
    updateState(state.copyWith(
      monitoring: state.monitoring.copyWith(programFeedEnabled: enabled),
    ));

    getService()?.setProgramFeedEnabled(enabled).catchError((e) {
      setError('Failed to set program feed: $e');
    });
  }

  /// Set video format (camera-wide)
  void setVideoFormat(String name, String frameRate) {
    final displayString = '$name $frameRate';
    final state = getState();
    updateState(state.copyWith(
      monitoring: state.monitoring.copyWith(currentVideoFormat: displayString),
    ));

    getService()?.setVideoFormat(name, frameRate).catchError((e) {
      setError('Failed to set video format: $e');
    });
  }
}
