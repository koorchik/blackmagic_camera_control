import 'package:flutter/foundation.dart';

/// Shutter measurement mode
enum ShutterMeasurement {
  shutterSpeed('ShutterSpeed', 'Speed'),
  shutterAngle('ShutterAngle', 'Angle');

  const ShutterMeasurement(this.code, this.label);
  final String code;
  final String label;

  static ShutterMeasurement fromString(String? value) {
    return ShutterMeasurement.values.firstWhere(
      (m) => m.code == value,
      orElse: () => ShutterMeasurement.shutterSpeed,
    );
  }
}

/// ND Filter display mode
enum NDFilterDisplayMode {
  stop('Stop', 'Stops'),
  number('Number', 'ND Number'),
  fraction('Fraction', 'Fraction');

  const NDFilterDisplayMode(this.code, this.label);
  final String code;
  final String label;

  static NDFilterDisplayMode fromString(String? value) {
    return NDFilterDisplayMode.values.firstWhere(
      (m) => m.code == value,
      orElse: () => NDFilterDisplayMode.stop,
    );
  }
}

@immutable
class VideoState {
  const VideoState({
    this.iso = 800,
    this.shutterSpeed = 50,
    this.shutterAngle = 180.0,
    this.shutterAuto = false,
    this.shutterMeasurement = ShutterMeasurement.shutterSpeed,
    this.whiteBalance = 5600,
    this.whiteBalanceTint = 0,
    this.gain = 0,
    this.ndFilterStop = 0.0,
    this.ndFilterDisplayMode = NDFilterDisplayMode.stop,
    this.ndFilterSupported = false,
    this.detailSharpeningEnabled = false,
    this.detailSharpeningLevel = 'Medium',
  });

  /// ISO value (100, 200, 400, 800, etc.)
  final int iso;

  /// Shutter speed denominator (e.g., 50 for 1/50)
  final int shutterSpeed;

  /// Shutter angle in degrees (e.g., 180.0)
  final double shutterAngle;

  /// Whether shutter is in auto exposure mode
  final bool shutterAuto;

  /// Shutter measurement mode (speed or angle)
  final ShutterMeasurement shutterMeasurement;

  /// White balance in Kelvin (2500-10000)
  final int whiteBalance;

  /// White balance tint (-50 to +50)
  final int whiteBalanceTint;

  /// Gain in dB
  final int gain;

  /// ND filter stop value (0.0 = clear, 2.0 = 2 stops, etc.)
  final double ndFilterStop;

  /// ND filter display mode
  final NDFilterDisplayMode ndFilterDisplayMode;

  /// Whether ND filter control is supported
  final bool ndFilterSupported;

  /// Whether detail sharpening is enabled
  final bool detailSharpeningEnabled;

  /// Detail sharpening level ('Low', 'Medium', 'High')
  final String detailSharpeningLevel;

  VideoState copyWith({
    int? iso,
    int? shutterSpeed,
    double? shutterAngle,
    bool? shutterAuto,
    ShutterMeasurement? shutterMeasurement,
    int? whiteBalance,
    int? whiteBalanceTint,
    int? gain,
    double? ndFilterStop,
    NDFilterDisplayMode? ndFilterDisplayMode,
    bool? ndFilterSupported,
    bool? detailSharpeningEnabled,
    String? detailSharpeningLevel,
  }) {
    return VideoState(
      iso: iso ?? this.iso,
      shutterSpeed: shutterSpeed ?? this.shutterSpeed,
      shutterAngle: shutterAngle ?? this.shutterAngle,
      shutterAuto: shutterAuto ?? this.shutterAuto,
      shutterMeasurement: shutterMeasurement ?? this.shutterMeasurement,
      whiteBalance: whiteBalance ?? this.whiteBalance,
      whiteBalanceTint: whiteBalanceTint ?? this.whiteBalanceTint,
      gain: gain ?? this.gain,
      ndFilterStop: ndFilterStop ?? this.ndFilterStop,
      ndFilterDisplayMode: ndFilterDisplayMode ?? this.ndFilterDisplayMode,
      ndFilterSupported: ndFilterSupported ?? this.ndFilterSupported,
      detailSharpeningEnabled: detailSharpeningEnabled ?? this.detailSharpeningEnabled,
      detailSharpeningLevel: detailSharpeningLevel ?? this.detailSharpeningLevel,
    );
  }

  factory VideoState.fromJson(Map<String, dynamic> json) {
    return VideoState(
      iso: json['iso'] as int? ?? 800,
      shutterSpeed: json['shutterSpeed'] as int? ?? 50,
      shutterAngle: (json['shutterAngle'] as num?)?.toDouble() ?? 180.0,
      shutterAuto: json['continuousShutterAutoExposure'] as bool? ?? false,
      shutterMeasurement: ShutterMeasurement.fromString(json['shutterMeasurement'] as String?),
      whiteBalance: json['whiteBalance'] as int? ?? 5600,
      whiteBalanceTint: json['whiteBalanceTint'] as int? ?? 0,
      gain: json['gain'] as int? ?? 0,
      ndFilterStop: (json['ndFilterStop'] as num?)?.toDouble() ?? 0.0,
      ndFilterDisplayMode: NDFilterDisplayMode.fromString(json['ndFilterDisplayMode'] as String?),
      ndFilterSupported: json['ndFilterSupported'] as bool? ?? false,
      detailSharpeningEnabled: json['detailSharpeningEnabled'] as bool? ?? false,
      detailSharpeningLevel: json['detailSharpeningLevel'] as String? ?? 'Medium',
    );
  }

  /// Common ISO values supported by Blackmagic cameras
  static const List<int> commonIsoValues = [
    100,
    200,
    400,
    800,
    1600,
    3200,
    6400,
    12800,
    25600,
  ];

  /// Common white balance presets in Kelvin
  static const Map<String, int> whiteBalancePresets = {
    'Tungsten': 3200,
    'Fluorescent': 4000,
    'Daylight': 5600,
    'Cloudy': 6500,
    'Shade': 7500,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideoState &&
        other.iso == iso &&
        other.shutterSpeed == shutterSpeed &&
        other.shutterAngle == shutterAngle &&
        other.shutterAuto == shutterAuto &&
        other.shutterMeasurement == shutterMeasurement &&
        other.whiteBalance == whiteBalance &&
        other.whiteBalanceTint == whiteBalanceTint &&
        other.gain == gain &&
        other.ndFilterStop == ndFilterStop &&
        other.ndFilterDisplayMode == ndFilterDisplayMode &&
        other.ndFilterSupported == ndFilterSupported &&
        other.detailSharpeningEnabled == detailSharpeningEnabled &&
        other.detailSharpeningLevel == detailSharpeningLevel;
  }

  @override
  int get hashCode => Object.hash(
        iso,
        shutterSpeed,
        shutterAngle,
        shutterAuto,
        shutterMeasurement,
        whiteBalance,
        whiteBalanceTint,
        gain,
        ndFilterStop,
        ndFilterDisplayMode,
        ndFilterSupported,
        detailSharpeningEnabled,
        detailSharpeningLevel,
      );

  @override
  String toString() =>
      'VideoState(iso: $iso, shutter: 1/$shutterSpeed, wb: ${whiteBalance}K)';
}
