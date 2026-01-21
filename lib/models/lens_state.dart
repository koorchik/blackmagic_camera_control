import 'package:flutter/foundation.dart';

@immutable
class LensState {
  const LensState({
    this.focus = 0.5,
    this.iris = 0.0,
    this.zoom = 0.0,
    this.focusSupported = true,
    this.irisSupported = true,
    this.zoomSupported = true,
  });

  /// Focus position (0.0 = near, 1.0 = far)
  final double focus;

  /// Iris/aperture value as normalized (0.0-1.0)
  final double iris;

  /// Zoom position (0.0-1.0)
  final double zoom;

  /// Whether focus control is supported by the current lens
  final bool focusSupported;

  /// Whether iris control is supported by the current lens
  final bool irisSupported;

  /// Whether zoom control is supported by the current lens
  final bool zoomSupported;

  LensState copyWith({
    double? focus,
    double? iris,
    double? zoom,
    bool? focusSupported,
    bool? irisSupported,
    bool? zoomSupported,
  }) {
    return LensState(
      focus: focus ?? this.focus,
      iris: iris ?? this.iris,
      zoom: zoom ?? this.zoom,
      focusSupported: focusSupported ?? this.focusSupported,
      irisSupported: irisSupported ?? this.irisSupported,
      zoomSupported: zoomSupported ?? this.zoomSupported,
    );
  }

  factory LensState.fromJson(Map<String, dynamic> json) {
    return LensState(
      focus: (json['focus'] as num?)?.toDouble() ?? 0.5,
      iris: (json['iris'] as num?)?.toDouble() ?? 0.0,
      zoom: (json['zoom'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LensState &&
        other.focus == focus &&
        other.iris == iris &&
        other.zoom == zoom &&
        other.focusSupported == focusSupported &&
        other.irisSupported == irisSupported &&
        other.zoomSupported == zoomSupported;
  }

  @override
  int get hashCode => Object.hash(
        focus,
        iris,
        zoom,
        focusSupported,
        irisSupported,
        zoomSupported,
      );

  @override
  String toString() =>
      'LensState(focus: $focus, iris: $iris, zoom: $zoom)';
}
