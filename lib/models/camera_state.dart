import 'package:flutter/foundation.dart';

import 'lens_state.dart';
import 'video_state.dart';
import 'transport_state.dart';
import 'slate_state.dart';
import 'audio_state.dart';
import 'media_state.dart';
import 'monitoring_state.dart';
import 'color_correction_state.dart';
import 'power_state.dart';
import 'preset_state.dart';

export 'lens_state.dart';
export 'video_state.dart';
export 'transport_state.dart';
export 'slate_state.dart';
export 'audio_state.dart';
export 'media_state.dart';
export 'monitoring_state.dart';
export 'color_correction_state.dart';
export 'power_state.dart';
export 'preset_state.dart';

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
    this.power = const PowerState(),
    this.tallyStatus = TallyStatus.none,
    this.preset = const PresetState(),
  });

  final LensState lens;
  final VideoState video;
  final TransportState transport;
  final SlateState slate;
  final AudioState audio;
  final MediaState media;
  final MonitoringState monitoring;
  final ColorCorrectionState colorCorrection;
  final PowerState power;
  final TallyStatus tallyStatus;
  final PresetState preset;

  CameraState copyWith({
    LensState? lens,
    VideoState? video,
    TransportState? transport,
    SlateState? slate,
    AudioState? audio,
    MediaState? media,
    MonitoringState? monitoring,
    ColorCorrectionState? colorCorrection,
    PowerState? power,
    TallyStatus? tallyStatus,
    PresetState? preset,
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
      power: power ?? this.power,
      tallyStatus: tallyStatus ?? this.tallyStatus,
      preset: preset ?? this.preset,
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
        other.colorCorrection == colorCorrection &&
        other.power == power &&
        other.tallyStatus == tallyStatus &&
        other.preset == preset;
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
        power,
        tallyStatus,
        preset,
      );

  @override
  String toString() =>
      'CameraState(lens: $lens, video: $video, transport: $transport)';
}
