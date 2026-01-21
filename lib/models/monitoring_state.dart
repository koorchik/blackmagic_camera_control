import 'package:flutter/foundation.dart';

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
    final colorStr = json['colour'] as String? ?? json['color'] as String?;

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
      intensity: (json['intensity'] as num?)?.toDouble() ?? 0.5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'mode': mode.code,
      'colour': color.code,
      'intensity': intensity,
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

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'ratio': ratio.label,
      'opacity': opacity,
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

  DisplayState copyWith({
    String? name,
    FocusAssistState? focusAssist,
    bool? zebraEnabled,
    double? zebraLevel,
    FrameGuidesState? frameGuides,
  }) {
    return DisplayState(
      name: name ?? this.name,
      focusAssist: focusAssist ?? this.focusAssist,
      zebraEnabled: zebraEnabled ?? this.zebraEnabled,
      zebraLevel: zebraLevel ?? this.zebraLevel,
      frameGuides: frameGuides ?? this.frameGuides,
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
        other.frameGuides == frameGuides;
  }

  @override
  int get hashCode => Object.hash(
        name,
        focusAssist,
        zebraEnabled,
        zebraLevel,
        frameGuides,
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
  });

  /// List of available display names
  final List<String> availableDisplays;

  /// Currently selected display name
  final String? selectedDisplay;

  /// Display states by name
  final Map<String, DisplayState> displays;

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
  }) {
    return MonitoringState(
      availableDisplays: availableDisplays ?? this.availableDisplays,
      selectedDisplay: clearSelectedDisplay
          ? null
          : (selectedDisplay ?? this.selectedDisplay),
      displays: displays ?? this.displays,
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

    return MonitoringState(
      availableDisplays: availableDisplays,
      selectedDisplay: json['selectedDisplay'] as String?,
      displays: displays,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MonitoringState &&
        listEquals(other.availableDisplays, availableDisplays) &&
        other.selectedDisplay == selectedDisplay &&
        mapEquals(other.displays, displays);
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(availableDisplays),
        selectedDisplay,
        Object.hashAll(displays.entries),
      );

  @override
  String toString() =>
      'MonitoringState(displays: ${availableDisplays.length}, selected: $selectedDisplay)';
}
