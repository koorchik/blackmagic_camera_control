import 'package:flutter/foundation.dart';

/// Audio input type
enum AudioInputType {
  mic('Mic', 'Microphone'),
  line('Line', 'Line Level');

  const AudioInputType(this.code, this.label);
  final String code;
  final String label;
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
  });

  /// Channel index (0-based)
  final int index;

  /// Audio level in dB (typically -60 to 0)
  final double levelDb;

  /// Audio level normalized (0.0 to 1.0)
  final double levelNormalized;

  /// Input type (Mic/Line)
  final AudioInputType inputType;

  /// Whether phantom power (48V) is enabled
  final bool phantomPower;

  /// Whether this channel is available on the camera
  final bool available;

  AudioChannelState copyWith({
    int? index,
    double? levelDb,
    double? levelNormalized,
    AudioInputType? inputType,
    bool? phantomPower,
    bool? available,
  }) {
    return AudioChannelState(
      index: index ?? this.index,
      levelDb: levelDb ?? this.levelDb,
      levelNormalized: levelNormalized ?? this.levelNormalized,
      inputType: inputType ?? this.inputType,
      phantomPower: phantomPower ?? this.phantomPower,
      available: available ?? this.available,
    );
  }

  factory AudioChannelState.fromJson(Map<String, dynamic> json, int index) {
    final inputStr = json['input'] as String?;
    return AudioChannelState(
      index: index,
      levelDb: (json['level'] as num?)?.toDouble() ?? -60.0,
      levelNormalized: (json['normalised'] as num?)?.toDouble() ?? 0.0,
      inputType: inputStr == 'Line' ? AudioInputType.line : AudioInputType.mic,
      phantomPower: json['phantomPower'] as bool? ?? false,
      available: json['available'] as bool? ?? true,
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
        other.available == available;
  }

  @override
  int get hashCode => Object.hash(
        index,
        levelDb,
        levelNormalized,
        inputType,
        phantomPower,
        available,
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
