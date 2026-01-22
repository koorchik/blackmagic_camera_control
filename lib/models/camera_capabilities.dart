import 'package:flutter/foundation.dart';

/// Represents a supported video format (resolution + frame rate combination)
@immutable
class VideoFormat {
  const VideoFormat({
    required this.name,
    required this.frameRate,
    this.width,
    this.height,
    this.interlaced = false,
  });

  final String name;
  final String frameRate;
  final int? width;
  final int? height;
  final bool interlaced;

  factory VideoFormat.fromJson(Map<String, dynamic> json) {
    return VideoFormat(
      name: json['name'] as String? ?? '',
      frameRate: json['frameRate'] as String? ?? '',
      width: json['width'] as int?,
      height: json['height'] as int?,
      interlaced: json['interlaced'] as bool? ?? false,
    );
  }

  /// Display string for UI (e.g., "4K DCI 23.98p")
  String get displayString => '$name $frameRate';

  @override
  String toString() => '$name @ $frameRate';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideoFormat &&
        other.name == name &&
        other.frameRate == frameRate;
  }

  @override
  int get hashCode => Object.hash(name, frameRate);
}

/// Represents a supported codec format
@immutable
class CodecFormat {
  const CodecFormat({
    required this.codec,
    required this.container,
    this.variant,
  });

  final String codec;
  final String container;
  final String? variant;

  factory CodecFormat.fromJson(Map<String, dynamic> json) {
    return CodecFormat(
      codec: json['codec'] as String? ?? '',
      container: json['container'] as String? ?? '',
      variant: json['variant'] as String?,
    );
  }

  String get displayName {
    if (variant != null && variant!.isNotEmpty) {
      return '$codec ($variant)';
    }
    // Format codec string for better readability
    // e.g., "BRaw:8_1" -> "BRaw 8:1", "BRaw:Q0" -> "BRaw Q0", "ProRes:HQ" -> "ProRes HQ"
    if (codec.contains(':')) {
      final parts = codec.split(':');
      if (parts.length == 2) {
        final codecType = parts[0];
        var codecVariant = parts[1];
        // Convert underscore ratio notation to colon (8_1 -> 8:1)
        if (codecVariant.contains('_')) {
          codecVariant = codecVariant.replaceAll('_', ':');
        }
        return '$codecType $codecVariant';
      }
    }
    return codec;
  }

  @override
  String toString() => displayName;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CodecFormat &&
        other.codec == codec &&
        other.container == container &&
        other.variant == variant;
  }

  @override
  int get hashCode => Object.hash(codec, container, variant);
}

/// Camera capabilities discovered from the API
@immutable
class CameraCapabilities {
  const CameraCapabilities({
    this.supportedISOs = const [],
    this.supportedShutterSpeeds = const [],
    this.supportedNDFilters = const [],
    this.supportedVideoFormats = const [],
    this.supportedCodecFormats = const [],
    this.isLoaded = false,
  });

  /// List of supported ISO values
  final List<int> supportedISOs;

  /// List of supported shutter speeds (denominator values, e.g., 50 for 1/50)
  final List<int> supportedShutterSpeeds;

  /// List of supported ND filter stops (e.g., [0.0, 2.0, 4.0, 6.0])
  final List<double> supportedNDFilters;

  /// List of supported video formats (resolution + frame rate)
  final List<VideoFormat> supportedVideoFormats;

  /// List of supported codec formats
  final List<CodecFormat> supportedCodecFormats;

  /// Whether capabilities have been loaded from the camera
  final bool isLoaded;

  /// Default fallback values when camera doesn't support discovery
  static const CameraCapabilities defaults = CameraCapabilities(
    supportedISOs: [100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600],
    supportedShutterSpeeds: [24, 25, 30, 48, 50, 60, 96, 100, 120, 180, 250, 500, 1000, 2000],
    supportedNDFilters: [0.0, 2.0, 4.0, 6.0],
    supportedVideoFormats: [],
    supportedCodecFormats: [],
    isLoaded: true,
  );

  CameraCapabilities copyWith({
    List<int>? supportedISOs,
    List<int>? supportedShutterSpeeds,
    List<double>? supportedNDFilters,
    List<VideoFormat>? supportedVideoFormats,
    List<CodecFormat>? supportedCodecFormats,
    bool? isLoaded,
  }) {
    return CameraCapabilities(
      supportedISOs: supportedISOs ?? this.supportedISOs,
      supportedShutterSpeeds: supportedShutterSpeeds ?? this.supportedShutterSpeeds,
      supportedNDFilters: supportedNDFilters ?? this.supportedNDFilters,
      supportedVideoFormats: supportedVideoFormats ?? this.supportedVideoFormats,
      supportedCodecFormats: supportedCodecFormats ?? this.supportedCodecFormats,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CameraCapabilities &&
        listEquals(other.supportedISOs, supportedISOs) &&
        listEquals(other.supportedShutterSpeeds, supportedShutterSpeeds) &&
        listEquals(other.supportedNDFilters, supportedNDFilters) &&
        listEquals(other.supportedVideoFormats, supportedVideoFormats) &&
        listEquals(other.supportedCodecFormats, supportedCodecFormats) &&
        other.isLoaded == isLoaded;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(supportedISOs),
        Object.hashAll(supportedShutterSpeeds),
        Object.hashAll(supportedNDFilters),
        Object.hashAll(supportedVideoFormats),
        Object.hashAll(supportedCodecFormats),
        isLoaded,
      );

  @override
  String toString() =>
      'CameraCapabilities(ISOs: ${supportedISOs.length}, shutters: ${supportedShutterSpeeds.length}, NDs: ${supportedNDFilters.length}, formats: ${supportedVideoFormats.length}, codecs: ${supportedCodecFormats.length})';
}
