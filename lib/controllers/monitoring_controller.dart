import '../models/camera_state.dart';
import '../models/camera_capabilities.dart';
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

  /// Set focus assist enabled for current display (per-display toggle)
  void setFocusAssistEnabled(bool enabled) {
    final state = getState();
    final displayName = state.monitoring.selectedDisplay;
    if (displayName == null) return;

    final currentDisplay = state.monitoring.displays[displayName];
    if (currentDisplay == null) return;

    final updatedFocusAssist = currentDisplay.focusAssist.copyWith(enabled: enabled);
    final updatedDisplay = currentDisplay.copyWith(focusAssist: updatedFocusAssist);
    updateState(state.copyWith(
      monitoring: state.monitoring.updateDisplay(displayName, updatedDisplay),
    ));

    getService()?.setFocusAssistEnabled(displayName, enabled).catchError((e) {
      setError('Failed to set focus assist enabled: $e');
    });
  }

  /// Set focus assist settings (camera-wide: mode, color, intensity)
  /// Note: Some cameras don't support changing these via API.
  void setFocusAssistSettings(FocusAssistState settings) {
    final state = getState();
    final previousSettings = state.monitoring.globalFocusAssistSettings;

    // Update global settings in state optimistically
    updateState(state.copyWith(
      monitoring: state.monitoring.copyWith(globalFocusAssistSettings: settings),
    ));

    // Send settings to global endpoint
    getService()?.setGlobalFocusAssist(settings).catchError((e) {
      // Revert to previous settings on error
      final currentState = getState();
      updateState(currentState.copyWith(
        monitoring: currentState.monitoring.copyWith(globalFocusAssistSettings: previousSettings),
      ));

      if (e.toString().contains('cannot be changed via API')) {
        setError('Focus assist settings can only be changed on camera');
      } else {
        setError('Failed to set focus assist settings: $e');
      }
    });
  }

  /// Legacy method for backward compatibility
  @Deprecated('Use setFocusAssistEnabled and setFocusAssistSettings instead')
  void setFocusAssist(FocusAssistState focusAssist) {
    setFocusAssistEnabled(focusAssist.enabled);
    setFocusAssistSettings(focusAssist);
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

  /// Set frame guides enabled for current display
  void setFrameGuidesEnabled(bool enabled) {
    final state = getState();
    final displayName = state.monitoring.selectedDisplay;
    if (displayName == null) return;

    final currentDisplay = state.monitoring.displays[displayName];
    if (currentDisplay == null) return;

    final updatedFrameGuides = currentDisplay.frameGuides.copyWith(enabled: enabled);
    final updatedDisplay = currentDisplay.copyWith(frameGuides: updatedFrameGuides);
    updateState(state.copyWith(
      monitoring: state.monitoring.updateDisplay(displayName, updatedDisplay),
    ));

    getService()?.setFrameGuides(displayName, updatedFrameGuides).catchError((e) {
      setError('Failed to set frame guides: $e');
    });
  }

  /// Set frame guide ratio (camera-wide setting)
  void setFrameGuideRatio(FrameGuideRatio ratio) {
    final state = getState();

    // Update local state
    updateState(state.copyWith(
      monitoring: state.monitoring.copyWith(currentFrameGuideRatio: ratio),
    ));

    // Send to API
    getService()?.setFrameGuideRatio(ratio.label).catchError((e) {
      setError('Failed to set frame guide ratio: $e');
    });
  }

  /// Legacy method for backward compatibility - sets both enabled and ratio
  @Deprecated('Use setFrameGuidesEnabled and setFrameGuideRatio instead')
  void setFrameGuides(FrameGuidesState frameGuides) {
    setFrameGuidesEnabled(frameGuides.enabled);
    setFrameGuideRatio(frameGuides.ratio);
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

  /// Set codec format (camera-wide)
  void setCodecFormat(String codec, String container) {
    final state = getState();
    final previousCodec = state.monitoring.currentCodecFormat;

    // Optimistic update
    updateState(state.copyWith(
      monitoring: state.monitoring.copyWith(
        currentCodecFormat: CodecFormat(codec: codec, container: container),
      ),
    ));

    getService()?.setCodecFormat(codec, container).catchError((e) {
      // Revert on failure
      final currentState = getState();
      updateState(currentState.copyWith(
        monitoring: currentState.monitoring.copyWith(
          currentCodecFormat: previousCodec,
          clearCodecFormat: previousCodec == null,
        ),
      ));
      setError('Failed to set codec format: $e');
    });
  }
}
