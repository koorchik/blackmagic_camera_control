import 'package:flutter/foundation.dart';

import 'lens_state.dart';
import 'video_state.dart';
import 'transport_state.dart';
import 'slate_state.dart';
import 'audio_state.dart';
import 'media_state.dart';
import 'monitoring_state.dart';
import 'color_correction_state.dart';

export 'lens_state.dart';
export 'video_state.dart';
export 'transport_state.dart';
export 'slate_state.dart';
export 'audio_state.dart';
export 'media_state.dart';
export 'monitoring_state.dart';
export 'color_correction_state.dart';

@immutable
class CameraState {
  const CameraState({
    this.lens = const LensState(),
    this.video = const VideoState(),
    this.transport = const TransportState(),
    this.slate = const SlateState(),
    this.audio = const AudioState(),
    this.media = const MediaState(),
    this.monitoring = const MonitoringState(),
    this.colorCorrection = const ColorCorrectionState(),
  });

  final LensState lens;
  final VideoState video;
  final TransportState transport;
  final SlateState slate;
  final AudioState audio;
  final MediaState media;
  final MonitoringState monitoring;
  final ColorCorrectionState colorCorrection;

  CameraState copyWith({
    LensState? lens,
    VideoState? video,
    TransportState? transport,
    SlateState? slate,
    AudioState? audio,
    MediaState? media,
    MonitoringState? monitoring,
    ColorCorrectionState? colorCorrection,
  }) {
    return CameraState(
      lens: lens ?? this.lens,
      video: video ?? this.video,
      transport: transport ?? this.transport,
      slate: slate ?? this.slate,
      audio: audio ?? this.audio,
      media: media ?? this.media,
      monitoring: monitoring ?? this.monitoring,
      colorCorrection: colorCorrection ?? this.colorCorrection,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CameraState &&
        other.lens == lens &&
        other.video == video &&
        other.transport == transport &&
        other.slate == slate &&
        other.audio == audio &&
        other.media == media &&
        other.monitoring == monitoring &&
        other.colorCorrection == colorCorrection;
  }

  @override
  int get hashCode => Object.hash(
        lens,
        video,
        transport,
        slate,
        audio,
        media,
        monitoring,
        colorCorrection,
      );

  @override
  String toString() =>
      'CameraState(lens: $lens, video: $video, transport: $transport)';
}
