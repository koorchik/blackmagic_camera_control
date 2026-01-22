import 'package:flutter/foundation.dart';
import 'camera_capabilities.dart';

/// Focus assist mode
enum FocusAssistMode {
  peak('Peak', 'Peaking'),
  coloredLines('ColoredLines', 'Colored Lines');

  const FocusAssistMode(this.code, this.label);
  final String code;
  final String label;
}

/// Focus assist color
enum FocusAssistColor {
  red('Red', 'Red'),
  green('Green', 'Green'),
  blue('Blue', 'Blue'),
  white('White', 'White'),
  black('Black', 'Black');

  const FocusAssistColor(this.code, this.label);
  final String code;
  final String label;
}

/// Frame guide ratio presets
enum FrameGuideRatio {
  ratio16x9('16:9', 16 / 9),
  ratio239x1('2.39:1', 2.39),
  ratio185x1('1.85:1', 1.85),
  ratio4x3('4:3', 4 / 3),
  ratio1x1('1:1', 1.0),
  ratio9x16('9:16', 9 / 16);

  const FrameGuideRatio(this.label, this.value);
  final String label;
  final double value;
}

/// Frame grid types
enum FrameGridType {
  thirds('Thirds', 'Rule of Thirds'),
  crosshair('Crosshair', 'Center Crosshair'),
  centerDot('CenterDot', 'Center Dot');

  const FrameGridType(this.code, this.label);
  final String code;
  final String label;

  static FrameGridType fromString(String? value) {
    return FrameGridType.values.firstWhere(
      (g) => g.code == value,
      orElse: () => FrameGridType.thirds,
    );
  }
}

@immutable
class FocusAssistState {
  const FocusAssistState({
    this.enabled = false,
    this.mode = FocusAssistMode.peak,
    this.color = FocusAssistColor.red,
    this.intensity = 0.5,
  });

  /// Whether focus assist is enabled
  final bool enabled;

  /// Focus assist mode
  final FocusAssistMode mode;

  /// Focus assist color
  final FocusAssistColor color;

  /// Focus assist intensity (0.0 to 1.0)
  final double intensity;

  FocusAssistState copyWith({
    bool? enabled,
    FocusAssistMode? mode,
    FocusAssistColor? color,
    double? intensity,
  }) {
    return FocusAssistState(
      enabled: enabled ?? this.enabled,
      mode: mode ?? this.mode,
      color: color ?? this.color,
      intensity: intensity ?? this.intensity,
    );
  }

  factory FocusAssistState.fromJson(Map<String, dynamic> json) {
    final modeStr = json['mode'] as String?;
    final colorStr = json['color'] as String? ?? json['colour'] as String?;
    // API returns intensity as 0-100 integer, convert to 0.0-1.0
    final rawIntensity = json['intensity'] as num?;
    final intensity = rawIntensity != null ? rawIntensity.toDouble() / 100.0 : 0.5;

    return FocusAssistState(
      enabled: json['enabled'] as bool? ?? false,
      mode: FocusAssistMode.values.cast<FocusAssistMode?>().firstWhere(
        (m) => m?.code == modeStr,
        orElse: () => FocusAssistMode.peak,
      )!,
      color: FocusAssistColor.values.cast<FocusAssistColor?>().firstWhere(
        (c) => c?.code == colorStr,
        orElse: () => FocusAssistColor.red,
      )!,
      intensity: intensity.clamp(0.0, 1.0),
    );
  }

  /// Convert to JSON for the per-display focusAssist endpoint.
  /// Note: Per-display endpoint only accepts {"enabled": true/false}.
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
    };
  }

  /// Convert to JSON for the global focusAssist settings endpoint.
  /// Intensity is sent as 0-100 integer (converted from internal 0.0-1.0).
  Map<String, dynamic> toSettingsJson() {
    return {
      'mode': mode.code,
      'color': color.code,
      'intensity': (intensity * 100).round(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FocusAssistState &&
        other.enabled == enabled &&
        other.mode == mode &&
        other.color == color &&
        other.intensity == intensity;
  }

  @override
  int get hashCode => Object.hash(enabled, mode, color, intensity);

  @override
  String toString() =>
      'FocusAssistState(enabled: $enabled, mode: ${mode.label})';
}

@immutable
class FrameGuidesState {
  const FrameGuidesState({
    this.enabled = false,
    this.ratio = FrameGuideRatio.ratio16x9,
    this.opacity = 0.5,
  });

  /// Whether frame guides are enabled
  final bool enabled;

  /// Frame guide ratio
  final FrameGuideRatio ratio;

  /// Frame guide opacity (0.0 to 1.0)
  final double opacity;

  FrameGuidesState copyWith({
    bool? enabled,
    FrameGuideRatio? ratio,
    double? opacity,
  }) {
    return FrameGuidesState(
      enabled: enabled ?? this.enabled,
      ratio: ratio ?? this.ratio,
      opacity: opacity ?? this.opacity,
    );
  }

  factory FrameGuidesState.fromJson(Map<String, dynamic> json) {
    final ratioStr = json['ratio'] as String?;

    return FrameGuidesState(
      enabled: json['enabled'] as bool? ?? false,
      ratio: FrameGuideRatio.values.cast<FrameGuideRatio?>().firstWhere(
        (r) => r?.label == ratioStr,
        orElse: () => FrameGuideRatio.ratio16x9,
      )!,
      opacity: (json['opacity'] as num?)?.toDouble() ?? 0.5,
    );
  }

  /// Convert to JSON for the frameGuide endpoint (per-display).
  /// Note: API only accepts {"enabled": true/false} for this endpoint.
  /// Ratio is set via a separate /monitoring/frameGuideRatio endpoint.
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FrameGuidesState &&
        other.enabled == enabled &&
        other.ratio == ratio &&
        other.opacity == opacity;
  }

  @override
  int get hashCode => Object.hash(enabled, ratio, opacity);

  @override
  String toString() =>
      'FrameGuidesState(enabled: $enabled, ratio: ${ratio.label})';
}

@immutable
class DisplayState {
  const DisplayState({
    required this.name,
    this.focusAssist = const FocusAssistState(),
    this.zebraEnabled = false,
    this.zebraLevel = 100.0,
    this.frameGuides = const FrameGuidesState(),
    this.cleanFeedEnabled = false,
    this.displayLutEnabled = false,
    this.falseColorEnabled = false,
    this.safeAreaEnabled = false,
    this.frameGridsEnabled = false,
  });

  /// Display name/identifier
  final String name;

  /// Focus assist state for this display
  final FocusAssistState focusAssist;

  /// Whether zebra overlay is enabled
  final bool zebraEnabled;

  /// Zebra level (typically 75-105 IRE)
  final double zebraLevel;

  /// Frame guides state for this display
  final FrameGuidesState frameGuides;

  /// Whether clean feed is enabled (hides overlays)
  final bool cleanFeedEnabled;

  /// Whether display LUT is enabled
  final bool displayLutEnabled;

  /// Whether false color is enabled
  final bool falseColorEnabled;

  /// Whether safe area is enabled
  final bool safeAreaEnabled;

  /// Whether frame grids are enabled
  final bool frameGridsEnabled;

  DisplayState copyWith({
    String? name,
    FocusAssistState? focusAssist,
    bool? zebraEnabled,
    double? zebraLevel,
    FrameGuidesState? frameGuides,
    bool? cleanFeedEnabled,
    bool? displayLutEnabled,
    bool? falseColorEnabled,
    bool? safeAreaEnabled,
    bool? frameGridsEnabled,
  }) {
    return DisplayState(
      name: name ?? this.name,
      focusAssist: focusAssist ?? this.focusAssist,
      zebraEnabled: zebraEnabled ?? this.zebraEnabled,
      zebraLevel: zebraLevel ?? this.zebraLevel,
      frameGuides: frameGuides ?? this.frameGuides,
      cleanFeedEnabled: cleanFeedEnabled ?? this.cleanFeedEnabled,
      displayLutEnabled: displayLutEnabled ?? this.displayLutEnabled,
      falseColorEnabled: falseColorEnabled ?? this.falseColorEnabled,
      safeAreaEnabled: safeAreaEnabled ?? this.safeAreaEnabled,
      frameGridsEnabled: frameGridsEnabled ?? this.frameGridsEnabled,
    );
  }

  factory DisplayState.fromJson(Map<String, dynamic> json, String name) {
    return DisplayState(
      name: name,
      focusAssist: json['focusAssist'] != null
          ? FocusAssistState.fromJson(json['focusAssist'] as Map<String, dynamic>)
          : const FocusAssistState(),
      zebraEnabled: json['zebraEnabled'] as bool? ?? false,
      zebraLevel: (json['zebraLevel'] as num?)?.toDouble() ?? 100.0,
      frameGuides: json['frameGuides'] != null
          ? FrameGuidesState.fromJson(json['frameGuides'] as Map<String, dynamic>)
          : const FrameGuidesState(),
      cleanFeedEnabled: json['cleanFeedEnabled'] as bool? ?? false,
      displayLutEnabled: json['displayLutEnabled'] as bool? ?? false,
      falseColorEnabled: json['falseColorEnabled'] as bool? ?? false,
      safeAreaEnabled: json['safeAreaEnabled'] as bool? ?? false,
      frameGridsEnabled: json['frameGridsEnabled'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DisplayState &&
        other.name == name &&
        other.focusAssist == focusAssist &&
        other.zebraEnabled == zebraEnabled &&
        other.zebraLevel == zebraLevel &&
        other.frameGuides == frameGuides &&
        other.cleanFeedEnabled == cleanFeedEnabled &&
        other.displayLutEnabled == displayLutEnabled &&
        other.falseColorEnabled == falseColorEnabled &&
        other.safeAreaEnabled == safeAreaEnabled &&
        other.frameGridsEnabled == frameGridsEnabled;
  }

  @override
  int get hashCode => Object.hash(
        name,
        focusAssist,
        zebraEnabled,
        zebraLevel,
        frameGuides,
        cleanFeedEnabled,
        displayLutEnabled,
        falseColorEnabled,
        safeAreaEnabled,
        frameGridsEnabled,
      );

  @override
  String toString() => 'DisplayState(name: $name)';
}

@immutable
class MonitoringState {
  const MonitoringState({
    this.availableDisplays = const [],
    this.selectedDisplay,
    this.displays = const {},
    this.programFeedEnabled = false,
    this.currentVideoFormat,
    this.currentCodecFormat,
    this.currentFrameGuideRatio = FrameGuideRatio.ratio16x9,
    this.globalFocusAssistSettings = const FocusAssistState(),
  });

  /// List of available display names
  final List<String> availableDisplays;

  /// Currently selected display name
  final String? selectedDisplay;

  /// Display states by name
  final Map<String, DisplayState> displays;

  /// Whether program return feed is enabled (for ATEM switcher setups)
  final bool programFeedEnabled;

  /// Current video format (e.g., "4K DCI 23.98p")
  final String? currentVideoFormat;

  /// Current codec format (e.g., ProRes 422 HQ)
  final CodecFormat? currentCodecFormat;

  /// Current frame guide ratio (camera-wide setting)
  final FrameGuideRatio currentFrameGuideRatio;

  /// Global focus assist settings (mode, color, intensity - camera-wide)
  final FocusAssistState globalFocusAssistSettings;

  /// Get current display state
  DisplayState? get currentDisplay {
    if (selectedDisplay == null) return null;
    return displays[selectedDisplay];
  }

  MonitoringState copyWith({
    List<String>? availableDisplays,
    String? selectedDisplay,
    bool clearSelectedDisplay = false,
    Map<String, DisplayState>? displays,
    bool? programFeedEnabled,
    String? currentVideoFormat,
    bool clearVideoFormat = false,
    CodecFormat? currentCodecFormat,
    bool clearCodecFormat = false,
    FrameGuideRatio? currentFrameGuideRatio,
    FocusAssistState? globalFocusAssistSettings,
  }) {
    return MonitoringState(
      availableDisplays: availableDisplays ?? this.availableDisplays,
      selectedDisplay: clearSelectedDisplay
          ? null
          : (selectedDisplay ?? this.selectedDisplay),
      displays: displays ?? this.displays,
      programFeedEnabled: programFeedEnabled ?? this.programFeedEnabled,
      currentVideoFormat: clearVideoFormat
          ? null
          : (currentVideoFormat ?? this.currentVideoFormat),
      currentCodecFormat: clearCodecFormat
          ? null
          : (currentCodecFormat ?? this.currentCodecFormat),
      currentFrameGuideRatio: currentFrameGuideRatio ?? this.currentFrameGuideRatio,
      globalFocusAssistSettings: globalFocusAssistSettings ?? this.globalFocusAssistSettings,
    );
  }

  /// Update a specific display's state
  MonitoringState updateDisplay(String name, DisplayState state) {
    final newDisplays = Map<String, DisplayState>.from(displays);
    newDisplays[name] = state;
    return copyWith(displays: newDisplays);
  }

  factory MonitoringState.fromJson(Map<String, dynamic> json) {
    final availableDisplays =
        (json['availableDisplays'] as List<dynamic>?)?.cast<String>() ?? [];
    final displaysJson = json['displays'] as Map<String, dynamic>? ?? {};
    final displays = <String, DisplayState>{};

    for (final entry in displaysJson.entries) {
      displays[entry.key] = DisplayState.fromJson(
        entry.value as Map<String, dynamic>,
        entry.key,
      );
    }

    // Parse frame guide ratio from string
    final ratioStr = json['currentFrameGuideRatio'] as String?;
    final frameGuideRatio = FrameGuideRatio.values.cast<FrameGuideRatio?>().firstWhere(
      (r) => r?.label == ratioStr,
      orElse: () => FrameGuideRatio.ratio16x9,
    )!;

    // Parse global focus assist settings
    final focusAssistJson = json['globalFocusAssistSettings'] as Map<String, dynamic>?;
    final globalFocusAssist = focusAssistJson != null
        ? FocusAssistState.fromJson(focusAssistJson)
        : const FocusAssistState();

    return MonitoringState(
      availableDisplays: availableDisplays,
      selectedDisplay: json['selectedDisplay'] as String?,
      displays: displays,
      programFeedEnabled: json['programFeedEnabled'] as bool? ?? false,
      currentVideoFormat: json['currentVideoFormat'] as String?,
      currentFrameGuideRatio: frameGuideRatio,
      globalFocusAssistSettings: globalFocusAssist,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MonitoringState &&
        listEquals(other.availableDisplays, availableDisplays) &&
        other.selectedDisplay == selectedDisplay &&
        mapEquals(other.displays, displays) &&
        other.programFeedEnabled == programFeedEnabled &&
        other.currentVideoFormat == currentVideoFormat &&
        other.currentCodecFormat == currentCodecFormat &&
        other.currentFrameGuideRatio == currentFrameGuideRatio &&
        other.globalFocusAssistSettings == globalFocusAssistSettings;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(availableDisplays),
        selectedDisplay,
        Object.hashAll(displays.entries),
        programFeedEnabled,
        currentVideoFormat,
        currentCodecFormat,
        currentFrameGuideRatio,
        globalFocusAssistSettings,
      );

  @override
  String toString() =>
      'MonitoringState(displays: ${availableDisplays.length}, selected: $selectedDisplay)';
}
