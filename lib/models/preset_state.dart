import 'package:flutter/foundation.dart';

/// State for camera presets
@immutable
class PresetState {
  const PresetState({
    this.availablePresets = const [],
    this.activePreset,
    this.isLoading = false,
  });

  /// List of available preset names
  final List<String> availablePresets;

  /// Currently active preset name (null if no preset is active)
  final String? activePreset;

  /// Whether a preset operation is in progress
  final bool isLoading;

  PresetState copyWith({
    List<String>? availablePresets,
    String? activePreset,
    bool clearActivePreset = false,
    bool? isLoading,
  }) {
    return PresetState(
      availablePresets: availablePresets ?? this.availablePresets,
      activePreset: clearActivePreset ? null : (activePreset ?? this.activePreset),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  factory PresetState.fromJson(Map<String, dynamic> json) {
    final presetsList = json['presets'] as List<dynamic>? ?? [];
    return PresetState(
      availablePresets: presetsList.cast<String>(),
      activePreset: json['activePreset'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PresetState &&
        listEquals(other.availablePresets, availablePresets) &&
        other.activePreset == activePreset &&
        other.isLoading == isLoading;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(availablePresets),
        activePreset,
        isLoading,
      );

  @override
  String toString() =>
      'PresetState(presets: ${availablePresets.length}, active: $activePreset)';
}
