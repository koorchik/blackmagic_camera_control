import 'package:flutter/foundation.dart';

/// Audio input type
enum AudioInputType {
  mic('Mic', 'Microphone'),
  line('Line', 'Line Level'),
  camera('Camera', 'Camera Mic'),
  xlr('XLR', 'XLR Input'),
  internalMic('Internal Mic', 'Internal Microphone'),
  none('None', 'No Input');

  const AudioInputType(this.code, this.label);
  final String code;
  final String label;

  /// Parse input type from API string
  static AudioInputType fromString(String? value) {
    if (value == null) return AudioInputType.mic;
    switch (value.toLowerCase()) {
      case 'mic':
        return AudioInputType.mic;
      case 'line':
        return AudioInputType.line;
      case 'camera':
        return AudioInputType.camera;
      case 'xlr':
        return AudioInputType.xlr;
      case 'internal mic':
      case 'internal':
        return AudioInputType.internalMic;
      case 'none':
        return AudioInputType.none;
      default:
        return AudioInputType.mic;
    }
  }
}

@immutable
class AudioChannelState {
  const AudioChannelState({
    required this.index,
    this.levelDb = -60.0,
    this.levelNormalized = 0.0,
    this.inputType = AudioInputType.mic,
    this.phantomPower = false,
    this.available = true,
    this.gain = 0.0,
    this.gainNormalized = 0.5,
    this.lowCutFilter = false,
    this.padding = false,
    this.supportedInputs = const [],
    this.minGain = -60.0,
    this.maxGain = 24.0,
  });

  /// Channel index (0-based)
  final int index;

  /// Audio level in dB (typically -60 to 0) - read from meter
  final double levelDb;

  /// Audio level normalized (0.0 to 1.0) - read from meter
  final double levelNormalized;

  /// Input type (Mic/Line/etc.)
  final AudioInputType inputType;

  /// Whether phantom power (48V) is enabled
  final bool phantomPower;

  /// Whether this channel is available on the camera
  final bool available;

  /// Current gain/input level in dB
  final double gain;

  /// Gain normalized (0.0 to 1.0) for slider control
  final double gainNormalized;

  /// Whether low cut filter is enabled (reduces wind/rumble)
  final bool lowCutFilter;

  /// Whether padding is enabled (attenuates loud signals)
  final bool padding;

  /// List of supported input types for this channel
  final List<AudioInputType> supportedInputs;

  /// Minimum gain value in dB (from input description)
  final double minGain;

  /// Maximum gain value in dB (from input description)
  final double maxGain;

  AudioChannelState copyWith({
    int? index,
    double? levelDb,
    double? levelNormalized,
    AudioInputType? inputType,
    bool? phantomPower,
    bool? available,
    double? gain,
    double? gainNormalized,
    bool? lowCutFilter,
    bool? padding,
    List<AudioInputType>? supportedInputs,
    double? minGain,
    double? maxGain,
  }) {
    return AudioChannelState(
      index: index ?? this.index,
      levelDb: levelDb ?? this.levelDb,
      levelNormalized: levelNormalized ?? this.levelNormalized,
      inputType: inputType ?? this.inputType,
      phantomPower: phantomPower ?? this.phantomPower,
      available: available ?? this.available,
      gain: gain ?? this.gain,
      gainNormalized: gainNormalized ?? this.gainNormalized,
      lowCutFilter: lowCutFilter ?? this.lowCutFilter,
      padding: padding ?? this.padding,
      supportedInputs: supportedInputs ?? this.supportedInputs,
      minGain: minGain ?? this.minGain,
      maxGain: maxGain ?? this.maxGain,
    );
  }

  factory AudioChannelState.fromJson(Map<String, dynamic> json, int index) {
    final inputStr = json['input'] as String?;
    // Parse supported inputs if present
    final supportedInputsJson = json['supportedInputs'] as List<dynamic>?;
    final supportedInputs = supportedInputsJson
        ?.map((e) => AudioInputType.fromString(e as String?))
        .toList() ?? [];

    return AudioChannelState(
      index: index,
      levelDb: (json['level'] as num?)?.toDouble() ?? -60.0,
      levelNormalized: (json['normalised'] as num?)?.toDouble() ?? 0.0,
      inputType: AudioInputType.fromString(inputStr),
      phantomPower: json['phantomPower'] as bool? ?? false,
      available: json['available'] as bool? ?? true,
      gain: (json['gain'] as num?)?.toDouble() ?? 0.0,
      gainNormalized: (json['gainNormalised'] as num?)?.toDouble() ?? 0.5,
      lowCutFilter: json['lowCutFilter'] as bool? ?? false,
      padding: json['padding'] as bool? ?? false,
      supportedInputs: supportedInputs,
      minGain: (json['minGain'] as num?)?.toDouble() ?? -60.0,
      maxGain: (json['maxGain'] as num?)?.toDouble() ?? 24.0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudioChannelState &&
        other.index == index &&
        other.levelDb == levelDb &&
        other.levelNormalized == levelNormalized &&
        other.inputType == inputType &&
        other.phantomPower == phantomPower &&
        other.available == available &&
        other.gain == gain &&
        other.gainNormalized == gainNormalized &&
        other.lowCutFilter == lowCutFilter &&
        other.padding == padding &&
        listEquals(other.supportedInputs, supportedInputs) &&
        other.minGain == minGain &&
        other.maxGain == maxGain;
  }

  @override
  int get hashCode => Object.hash(
        index,
        levelDb,
        levelNormalized,
        inputType,
        phantomPower,
        available,
        gain,
        gainNormalized,
        lowCutFilter,
        padding,
        Object.hashAll(supportedInputs),
        minGain,
        maxGain,
      );

  @override
  String toString() =>
      'AudioChannelState(index: $index, level: ${levelDb.toStringAsFixed(1)}dB)';
}

@immutable
class AudioState {
  const AudioState({
    this.channels = const [],
  });

  /// List of audio channels
  final List<AudioChannelState> channels;

  /// Default channel count for most Blackmagic cameras
  static const int defaultChannelCount = 2;

  /// Get channel by index, or null if not found
  AudioChannelState? getChannel(int index) {
    if (index < 0 || index >= channels.length) return null;
    return channels[index];
  }

  AudioState copyWith({
    List<AudioChannelState>? channels,
  }) {
    return AudioState(
      channels: channels ?? this.channels,
    );
  }

  /// Update a single channel
  AudioState updateChannel(int index, AudioChannelState channel) {
    final newChannels = List<AudioChannelState>.from(channels);
    if (index < newChannels.length) {
      newChannels[index] = channel;
    }
    return copyWith(channels: newChannels);
  }

  factory AudioState.fromJson(Map<String, dynamic> json) {
    final channelsJson = json['channels'] as List<dynamic>? ?? [];
    final channels = <AudioChannelState>[];
    for (var i = 0; i < channelsJson.length; i++) {
      channels.add(AudioChannelState.fromJson(
        channelsJson[i] as Map<String, dynamic>,
        i,
      ));
    }
    return AudioState(channels: channels);
  }

  /// Create default audio state with given channel count
  factory AudioState.defaultState({int channelCount = 2}) {
    return AudioState(
      channels: List.generate(
        channelCount,
        (i) => AudioChannelState(index: i),
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudioState && listEquals(other.channels, channels);
  }

  @override
  int get hashCode => Object.hashAll(channels);

  @override
  String toString() => 'AudioState(channels: ${channels.length})';
}
