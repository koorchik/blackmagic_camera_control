import '../models/camera_state.dart';
import '../models/camera_capabilities.dart';
import 'base_controller.dart';

/// Controller for monitoring-related operations.
class MonitoringController extends BaseController {
  MonitoringController(super.context);

  /// Helper to update a boolean property on the current display with optimistic update.
  void _updateCurrentDisplayBool({
    required DisplayState Function(DisplayState, bool) copyWithValue,
    required Future<void> Function(String displayName) apiCall,
    required String errorMessage,
    required bool value,
  }) {
    final state = getState();
    final displayName = state.monitoring.selectedDisplay;
    if (displayName == null) return;

    final currentDisplay = state.monitoring.displays[displayName];
    if (currentDisplay == null) return;

    final updatedDisplay = copyWithValue(currentDisplay, value);
    updateState(state.copyWith(
      monitoring: state.monitoring.updateDisplay(displayName, updatedDisplay),
    ));

    apiCall(displayName).catchError((e) {
      setError(errorMessage);
    });
  }

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
    _updateCurrentDisplayBool(
      copyWithValue: (d, v) => d.copyWith(zebraEnabled: v),
      apiCall: (name) => getService()!.setZebraEnabled(name, enabled),
      errorMessage: 'Failed to set zebra',
      value: enabled,
    );
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
    _updateCurrentDisplayBool(
      copyWithValue: (d, v) => d.copyWith(cleanFeedEnabled: v),
      apiCall: (name) => getService()!.setCleanFeedEnabled(name, enabled),
      errorMessage: 'Failed to set clean feed',
      value: enabled,
    );
  }

  /// Set display LUT enabled for current display
  void setDisplayLutEnabled(bool enabled) {
    _updateCurrentDisplayBool(
      copyWithValue: (d, v) => d.copyWith(displayLutEnabled: v),
      apiCall: (name) => getService()!.setDisplayLutEnabled(name, enabled),
      errorMessage: 'Failed to set display LUT',
      value: enabled,
    );
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

  /// Set color bars test pattern enabled (camera-wide)
  void setColorBarsEnabled(bool enabled) {
    final state = getState();
    updateState(state.copyWith(
      monitoring: state.monitoring.copyWith(colorBarsEnabled: enabled),
    ));

    getService()?.setColorBarsEnabled(enabled).catchError((e) {
      setError('Failed to set color bars: $e');
    });
  }

  /// Set false color enabled for current display
  void setFalseColorEnabled(bool enabled) {
    _updateCurrentDisplayBool(
      copyWithValue: (d, v) => d.copyWith(falseColorEnabled: v),
      apiCall: (name) => getService()!.setFalseColorEnabled(name, enabled),
      errorMessage: 'Failed to set false color',
      value: enabled,
    );
  }

  /// Set safe area enabled for current display
  void setSafeAreaEnabled(bool enabled) {
    _updateCurrentDisplayBool(
      copyWithValue: (d, v) => d.copyWith(safeAreaEnabled: v),
      apiCall: (name) => getService()!.setSafeAreaEnabled(name, enabled),
      errorMessage: 'Failed to set safe area',
      value: enabled,
    );
  }

  /// Set safe area percentage (camera-wide)
  void setSafeAreaPercent(int percent) {
    final state = getState();
    updateState(state.copyWith(
      monitoring: state.monitoring.copyWith(safeAreaPercent: percent),
    ));

    getService()?.setSafeAreaPercent(percent).catchError((e) {
      setError('Failed to set safe area percent: $e');
    });
  }

  /// Set frame grids enabled for current display
  void setFrameGridsEnabled(bool enabled) {
    _updateCurrentDisplayBool(
      copyWithValue: (d, v) => d.copyWith(frameGridsEnabled: v),
      apiCall: (name) => getService()!.setFrameGridsEnabled(name, enabled),
      errorMessage: 'Failed to set frame grids',
      value: enabled,
    );
  }

  /// Set active frame grids (camera-wide)
  void setActiveFrameGrids(List<FrameGridType> grids) {
    final state = getState();
    updateState(state.copyWith(
      monitoring: state.monitoring.copyWith(activeFrameGrids: grids),
    ));

    final gridStrings = grids.map((g) => g.code).toList();
    getService()?.setGlobalFrameGrids(gridStrings).catchError((e) {
      setError('Failed to set frame grids: $e');
    });
  }
}
