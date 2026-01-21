import 'package:flutter/foundation.dart';

@immutable
class VideoState {
  const VideoState({
    this.iso = 800,
    this.shutterSpeed = 50,
    this.shutterAuto = false,
    this.whiteBalance = 5600,
    this.whiteBalanceTint = 0,
    this.gain = 0,
  });

  /// ISO value (100, 200, 400, 800, etc.)
  final int iso;

  /// Shutter speed denominator (e.g., 50 for 1/50)
  final int shutterSpeed;

  /// Whether shutter is in auto exposure mode
  final bool shutterAuto;

  /// White balance in Kelvin (2500-10000)
  final int whiteBalance;

  /// White balance tint (-50 to +50)
  final int whiteBalanceTint;

  /// Gain in dB
  final int gain;

  VideoState copyWith({
    int? iso,
    int? shutterSpeed,
    bool? shutterAuto,
    int? whiteBalance,
    int? whiteBalanceTint,
    int? gain,
  }) {
    return VideoState(
      iso: iso ?? this.iso,
      shutterSpeed: shutterSpeed ?? this.shutterSpeed,
      shutterAuto: shutterAuto ?? this.shutterAuto,
      whiteBalance: whiteBalance ?? this.whiteBalance,
      whiteBalanceTint: whiteBalanceTint ?? this.whiteBalanceTint,
      gain: gain ?? this.gain,
    );
  }

  factory VideoState.fromJson(Map<String, dynamic> json) {
    return VideoState(
      iso: json['iso'] as int? ?? 800,
      shutterSpeed: json['shutterSpeed'] as int? ?? 50,
      shutterAuto: json['continuousShutterAutoExposure'] as bool? ?? false,
      whiteBalance: json['whiteBalance'] as int? ?? 5600,
      whiteBalanceTint: json['whiteBalanceTint'] as int? ?? 0,
      gain: json['gain'] as int? ?? 0,
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
        other.shutterAuto == shutterAuto &&
        other.whiteBalance == whiteBalance &&
        other.whiteBalanceTint == whiteBalanceTint &&
        other.gain == gain;
  }

  @override
  int get hashCode => Object.hash(
        iso,
        shutterSpeed,
        shutterAuto,
        whiteBalance,
        whiteBalanceTint,
        gain,
      );

  @override
  String toString() =>
      'VideoState(iso: $iso, shutter: 1/$shutterSpeed, wb: ${whiteBalance}K)';
}
