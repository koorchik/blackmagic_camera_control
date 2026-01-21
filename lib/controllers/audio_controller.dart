import '../models/camera_state.dart';
import '../services/camera_service.dart';

/// Controller for audio-related operations.
class AudioController {
  AudioController({
    required this.getState,
    required this.updateState,
    required this.setError,
    required this.getService,
  });

  final CameraState Function() getState;
  final void Function(CameraState state) updateState;
  final void Function(String error) setError;
  final CameraService? Function() getService;

  /// Fetch fresh audio state
  Future<void> refresh() async {
    try {
      final audio = await getService()?.fetchAudioState();
      if (audio != null) {
        final state = getState();
        updateState(state.copyWith(audio: audio));
      }
    } catch (e) {
      setError('Failed to fetch audio state: $e');
    }
  }

  /// Set audio input type for a channel
  void setInput(int channelIndex, AudioInputType type) {
    final state = getState();
    final channels = List<AudioChannelState>.from(state.audio.channels);
    if (channelIndex < channels.length) {
      channels[channelIndex] = channels[channelIndex].copyWith(inputType: type);
      updateState(state.copyWith(audio: state.audio.copyWith(channels: channels)));
    }
    getService()?.setAudioInput(channelIndex, type).catchError((e) {
      setError('Failed to set audio input: $e');
    });
  }

  /// Set phantom power for a channel
  void setPhantomPower(int channelIndex, bool enabled) {
    final state = getState();
    final channels = List<AudioChannelState>.from(state.audio.channels);
    if (channelIndex < channels.length) {
      channels[channelIndex] = channels[channelIndex].copyWith(phantomPower: enabled);
      updateState(state.copyWith(audio: state.audio.copyWith(channels: channels)));
    }
    getService()?.setPhantomPower(channelIndex, enabled).catchError((e) {
      setError('Failed to set phantom power: $e');
    });
  }

  /// Set audio gain/level for a channel - debounced API call (for smooth dragging)
  void setGainDebounced(int channelIndex, double normalizedValue) {
    getService()?.setAudioLevelDebounced(channelIndex, normalized: normalizedValue);
  }

  /// Set audio gain/level for a channel - final value (optimistic update)
  void setGainFinal(int channelIndex, double normalizedValue) {
    final state = getState();
    final channels = List<AudioChannelState>.from(state.audio.channels);
    if (channelIndex < channels.length) {
      channels[channelIndex] = channels[channelIndex].copyWith(
        gainNormalized: normalizedValue,
      );
      updateState(state.copyWith(audio: state.audio.copyWith(channels: channels)));
    }
    getService()?.setAudioLevel(channelIndex, normalized: normalizedValue).catchError((e) {
      setError('Failed to set audio gain: $e');
    });
  }

  /// Set low cut filter for a channel
  void setLowCutFilter(int channelIndex, bool enabled) {
    final state = getState();
    final channels = List<AudioChannelState>.from(state.audio.channels);
    if (channelIndex < channels.length) {
      channels[channelIndex] = channels[channelIndex].copyWith(lowCutFilter: enabled);
      updateState(state.copyWith(audio: state.audio.copyWith(channels: channels)));
    }
    getService()?.setLowCutFilter(channelIndex, enabled).catchError((e) {
      setError('Failed to set low cut filter: $e');
    });
  }

  /// Set padding for a channel
  void setPadding(int channelIndex, bool enabled) {
    final state = getState();
    final channels = List<AudioChannelState>.from(state.audio.channels);
    if (channelIndex < channels.length) {
      channels[channelIndex] = channels[channelIndex].copyWith(padding: enabled);
      updateState(state.copyWith(audio: state.audio.copyWith(channels: channels)));
    }
    getService()?.setPadding(channelIndex, enabled).catchError((e) {
      setError('Failed to set padding: $e');
    });
  }
}
