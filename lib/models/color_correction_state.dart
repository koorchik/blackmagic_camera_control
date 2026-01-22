import 'package:flutter/foundation.dart';

@immutable
class ColorWheelValues {
  const ColorWheelValues({
    this.red = 0.0,
    this.green = 0.0,
    this.blue = 0.0,
    this.luma = 0.0,
  });

  /// Red adjustment (-1.0 to 1.0 for lift/gamma, 0.0 to 2.0 for gain)
  final double red;

  /// Green adjustment (-1.0 to 1.0 for lift/gamma, 0.0 to 2.0 for gain)
  final double green;

  /// Blue adjustment (-1.0 to 1.0 for lift/gamma, 0.0 to 2.0 for gain)
  final double blue;

  /// Luma/master adjustment (-1.0 to 1.0 for lift/gamma, 0.0 to 2.0 for gain)
  final double luma;

  /// Default values for Lift and Gamma (additive, 0.0 = no change)
  static const ColorWheelValues liftGammaDefault = ColorWheelValues();

  /// Default values for Gain (multiplicative, 1.0 = no change)
  static const ColorWheelValues gainDefault = ColorWheelValues(
    red: 1.0,
    green: 1.0,
    blue: 1.0,
    luma: 1.0,
  );

  /// Check if all values are at zero (default for lift/gamma)
  bool get isDefault => red == 0.0 && green == 0.0 && blue == 0.0 && luma == 0.0;

  /// Check if all values are at one (default for gain)
  bool get isGainDefault => red == 1.0 && green == 1.0 && blue == 1.0 && luma == 1.0;

  ColorWheelValues copyWith({
    double? red,
    double? green,
    double? blue,
    double? luma,
  }) {
    return ColorWheelValues(
      red: red ?? this.red,
      green: green ?? this.green,
      blue: blue ?? this.blue,
      luma: luma ?? this.luma,
    );
  }

  factory ColorWheelValues.fromJson(Map<String, dynamic> json) {
    return ColorWheelValues(
      red: (json['red'] as num?)?.toDouble() ?? 0.0,
      green: (json['green'] as num?)?.toDouble() ?? 0.0,
      blue: (json['blue'] as num?)?.toDouble() ?? 0.0,
      luma: (json['luma'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'red': red,
      'green': green,
      'blue': blue,
      'luma': luma,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ColorWheelValues &&
        other.red == red &&
        other.green == green &&
        other.blue == blue &&
        other.luma == luma;
  }

  @override
  int get hashCode => Object.hash(red, green, blue, luma);

  @override
  String toString() =>
      'ColorWheelValues(R: ${red.toStringAsFixed(2)}, G: ${green.toStringAsFixed(2)}, B: ${blue.toStringAsFixed(2)}, L: ${luma.toStringAsFixed(2)})';
}

@immutable
class ColorCorrectionState {
  const ColorCorrectionState({
    this.lift = ColorWheelValues.liftGammaDefault,
    this.gamma = ColorWheelValues.liftGammaDefault,
    this.gain = ColorWheelValues.gainDefault,
    this.offset = ColorWheelValues.liftGammaDefault,
    this.saturation = 1.0,
    this.hue = 0.0,
    this.contrast = 1.0,
    this.contrastPivot = 0.5,
    this.lumaContribution = 1.0,
  });

  /// Lift (shadows) color correction - default 0.0 (additive)
  final ColorWheelValues lift;

  /// Gamma (midtones) color correction - default 0.0 (additive)
  final ColorWheelValues gamma;

  /// Gain (highlights) color correction - default 1.0 (multiplicative)
  final ColorWheelValues gain;

  /// Offset (blacks) color correction - default 0.0 (additive)
  final ColorWheelValues offset;

  /// Saturation adjustment (0.0 to 2.0, 1.0 = normal)
  final double saturation;

  /// Hue shift (-1.0 to 1.0, 0.0 = no shift)
  final double hue;

  /// Contrast adjustment (0.0 to 2.0, 1.0 = normal)
  final double contrast;

  /// Contrast pivot point (0.0 to 1.0, 0.5 = middle gray)
  final double contrastPivot;

  /// Luma contribution (0.0 to 1.0, 1.0 = full color correction)
  final double lumaContribution;

  /// Check if all color correction values are at default
  bool get isDefault =>
      lift.isDefault &&
      gamma.isDefault &&
      gain.isGainDefault &&
      offset.isDefault &&
      saturation == 1.0 &&
      hue == 0.0 &&
      contrast == 1.0 &&
      contrastPivot == 0.5 &&
      lumaContribution == 1.0;

  ColorCorrectionState copyWith({
    ColorWheelValues? lift,
    ColorWheelValues? gamma,
    ColorWheelValues? gain,
    ColorWheelValues? offset,
    double? saturation,
    double? hue,
    double? contrast,
    double? contrastPivot,
    double? lumaContribution,
  }) {
    return ColorCorrectionState(
      lift: lift ?? this.lift,
      gamma: gamma ?? this.gamma,
      gain: gain ?? this.gain,
      offset: offset ?? this.offset,
      saturation: saturation ?? this.saturation,
      hue: hue ?? this.hue,
      contrast: contrast ?? this.contrast,
      contrastPivot: contrastPivot ?? this.contrastPivot,
      lumaContribution: lumaContribution ?? this.lumaContribution,
    );
  }

  /// Reset all values to default
  ColorCorrectionState reset() {
    return const ColorCorrectionState();
  }

  factory ColorCorrectionState.fromJson(Map<String, dynamic> json) {
    return ColorCorrectionState(
      lift: json['lift'] != null
          ? ColorWheelValues.fromJson(json['lift'] as Map<String, dynamic>)
          : ColorWheelValues.liftGammaDefault,
      gamma: json['gamma'] != null
          ? ColorWheelValues.fromJson(json['gamma'] as Map<String, dynamic>)
          : ColorWheelValues.liftGammaDefault,
      gain: json['gain'] != null
          ? ColorWheelValues.fromJson(json['gain'] as Map<String, dynamic>)
          : ColorWheelValues.gainDefault,
      offset: json['offset'] != null
          ? ColorWheelValues.fromJson(json['offset'] as Map<String, dynamic>)
          : ColorWheelValues.liftGammaDefault,
      saturation: (json['saturation'] as num?)?.toDouble() ?? 1.0,
      hue: (json['hue'] as num?)?.toDouble() ?? 0.0,
      contrast: (json['contrast'] as num?)?.toDouble() ?? 1.0,
      contrastPivot: (json['contrastPivot'] as num?)?.toDouble() ?? 0.5,
      lumaContribution: (json['lumaContribution'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lift': lift.toJson(),
      'gamma': gamma.toJson(),
      'gain': gain.toJson(),
      'offset': offset.toJson(),
      'saturation': saturation,
      'hue': hue,
      'contrast': contrast,
      'contrastPivot': contrastPivot,
      'lumaContribution': lumaContribution,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ColorCorrectionState &&
        other.lift == lift &&
        other.gamma == gamma &&
        other.gain == gain &&
        other.offset == offset &&
        other.saturation == saturation &&
        other.hue == hue &&
        other.contrast == contrast &&
        other.contrastPivot == contrastPivot &&
        other.lumaContribution == lumaContribution;
  }

  @override
  int get hashCode => Object.hash(
        lift,
        gamma,
        gain,
        offset,
        saturation,
        hue,
        contrast,
        contrastPivot,
        lumaContribution,
      );

  @override
  String toString() =>
      'ColorCorrectionState(lift: $lift, gamma: $gamma, gain: $gain, offset: $offset)';
}
