import 'dart:async';
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

  Timer? _levelPollingTimer;
  bool _isPolling = false;

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
    final previousType = channelIndex < channels.length
        ? channels[channelIndex].inputType
        : AudioInputType.mic;

    if (channelIndex < channels.length) {
      channels[channelIndex] = channels[channelIndex].copyWith(inputType: type);
      updateState(state.copyWith(audio: state.audio.copyWith(channels: channels)));
    }

    getService()?.setAudioInput(channelIndex, type).catchError((e) {
      // Revert to previous value on error
      final currentState = getState();
      final currentChannels = List<AudioChannelState>.from(currentState.audio.channels);
      if (channelIndex < currentChannels.length) {
        currentChannels[channelIndex] = currentChannels[channelIndex].copyWith(inputType: previousType);
        updateState(currentState.copyWith(audio: currentState.audio.copyWith(channels: currentChannels)));
      }
      setError('Failed to set audio input: ${type.label} not supported');
    });
  }

  /// Set phantom power for a channel
  void setPhantomPower(int channelIndex, bool enabled) {
    final state = getState();
    final channels = List<AudioChannelState>.from(state.audio.channels);
    final previousValue = channelIndex < channels.length
        ? channels[channelIndex].phantomPower
        : false;

    if (channelIndex < channels.length) {
      channels[channelIndex] = channels[channelIndex].copyWith(phantomPower: enabled);
      updateState(state.copyWith(audio: state.audio.copyWith(channels: channels)));
    }

    getService()?.setPhantomPower(channelIndex, enabled).catchError((e) {
      // Revert to previous value on error
      final currentState = getState();
      final currentChannels = List<AudioChannelState>.from(currentState.audio.channels);
      if (channelIndex < currentChannels.length) {
        currentChannels[channelIndex] = currentChannels[channelIndex].copyWith(phantomPower: previousValue);
        updateState(currentState.copyWith(audio: currentState.audio.copyWith(channels: currentChannels)));
      }
      setError('Phantom power not supported on this channel');
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
    final previousValue = channelIndex < channels.length
        ? channels[channelIndex].lowCutFilter
        : false;

    if (channelIndex < channels.length) {
      channels[channelIndex] = channels[channelIndex].copyWith(lowCutFilter: enabled);
      updateState(state.copyWith(audio: state.audio.copyWith(channels: channels)));
    }

    getService()?.setLowCutFilter(channelIndex, enabled).catchError((e) {
      // Revert to previous value on error
      final currentState = getState();
      final currentChannels = List<AudioChannelState>.from(currentState.audio.channels);
      if (channelIndex < currentChannels.length) {
        currentChannels[channelIndex] = currentChannels[channelIndex].copyWith(lowCutFilter: previousValue);
        updateState(currentState.copyWith(audio: currentState.audio.copyWith(channels: currentChannels)));
      }
      setError('Low cut filter not supported on this camera');
    });
  }

  /// Set padding for a channel
  void setPadding(int channelIndex, bool enabled) {
    final state = getState();
    final channels = List<AudioChannelState>.from(state.audio.channels);
    final previousValue = channelIndex < channels.length
        ? channels[channelIndex].padding
        : false;

    if (channelIndex < channels.length) {
      channels[channelIndex] = channels[channelIndex].copyWith(padding: enabled);
      updateState(state.copyWith(audio: state.audio.copyWith(channels: channels)));
    }

    getService()?.setPadding(channelIndex, enabled).catchError((e) {
      // Revert to previous value on error
      final currentState = getState();
      final currentChannels = List<AudioChannelState>.from(currentState.audio.channels);
      if (channelIndex < currentChannels.length) {
        currentChannels[channelIndex] = currentChannels[channelIndex].copyWith(padding: previousValue);
        updateState(currentState.copyWith(audio: currentState.audio.copyWith(channels: currentChannels)));
      }
      setError('Padding not supported on this camera');
    });
  }

  /// Start polling audio levels (fallback when WebSocket doesn't provide updates)
  void startLevelPolling({Duration interval = const Duration(milliseconds: 200)}) {
    if (_isPolling) return;
    _isPolling = true;
    _levelPollingTimer = Timer.periodic(interval, (_) => _pollAudioLevels());
  }

  /// Stop polling audio levels
  void stopLevelPolling() {
    _isPolling = false;
    _levelPollingTimer?.cancel();
    _levelPollingTimer = null;
  }

  /// Whether audio level polling is active
  bool get isPolling => _isPolling;

  /// Poll audio levels once from the API
  Future<void> _pollAudioLevels() async {
    final service = getService();
    if (service == null) return;

    final state = getState();
    final channels = List<AudioChannelState>.from(state.audio.channels);

    for (var i = 0; i < channels.length; i++) {
      if (!channels[i].available) continue;
      try {
        final level = await service.getAudioLevel(i);
        channels[i] = channels[i].copyWith(levelNormalized: level);
      } catch (_) {
        // Ignore errors during polling
      }
    }

    updateState(state.copyWith(audio: state.audio.copyWith(channels: channels)));
  }

  /// Dispose of resources
  void dispose() {
    stopLevelPolling();
  }
}
