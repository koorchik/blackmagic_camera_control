import 'package:flutter/foundation.dart';

import 'lens_state.dart';
import 'video_state.dart';
import 'transport_state.dart';

export 'lens_state.dart';
export 'video_state.dart';
export 'transport_state.dart';

@immutable
class CameraState {
  const CameraState({
    this.lens = const LensState(),
    this.video = const VideoState(),
    this.transport = const TransportState(),
  });

  final LensState lens;
  final VideoState video;
  final TransportState transport;

  CameraState copyWith({
    LensState? lens,
    VideoState? video,
    TransportState? transport,
  }) {
    return CameraState(
      lens: lens ?? this.lens,
      video: video ?? this.video,
      transport: transport ?? this.transport,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CameraState &&
        other.lens == lens &&
        other.video == video &&
        other.transport == transport;
  }

  @override
  int get hashCode => Object.hash(lens, video, transport);

  @override
  String toString() => 'CameraState(lens: $lens, video: $video, transport: $transport)';
}
