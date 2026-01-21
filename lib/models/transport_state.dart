import 'package:flutter/foundation.dart';

@immutable
class TransportState {
  const TransportState({
    this.isRecording = false,
    this.isPlaying = false,
    this.timecode = '00:00:00:00',
    this.clipName = '',
  });

  /// Whether the camera is currently recording
  final bool isRecording;

  /// Whether the camera is playing back
  final bool isPlaying;

  /// Current timecode in format HH:MM:SS:FF
  final String timecode;

  /// Current clip name
  final String clipName;

  TransportState copyWith({
    bool? isRecording,
    bool? isPlaying,
    String? timecode,
    String? clipName,
  }) {
    return TransportState(
      isRecording: isRecording ?? this.isRecording,
      isPlaying: isPlaying ?? this.isPlaying,
      timecode: timecode ?? this.timecode,
      clipName: clipName ?? this.clipName,
    );
  }

  factory TransportState.fromJson(Map<String, dynamic> json) {
    return TransportState(
      isRecording: json['recording'] as bool? ?? false,
      timecode: json['timecode'] as String? ?? '00:00:00:00',
      clipName: json['clipName'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransportState &&
        other.isRecording == isRecording &&
        other.isPlaying == isPlaying &&
        other.timecode == timecode &&
        other.clipName == clipName;
  }

  @override
  int get hashCode => Object.hash(
        isRecording,
        isPlaying,
        timecode,
        clipName,
      );

  @override
  String toString() =>
      'TransportState(recording: $isRecording, timecode: $timecode)';
}
