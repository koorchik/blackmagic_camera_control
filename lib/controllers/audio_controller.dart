import 'dart:async';
import '../models/camera_state.dart';
import 'base_controller.dart';

/// Controller for audio-related operations.
class AudioController extends BaseController {
  AudioController({
    required super.getState,
    required super.updateState,
    required super.setError,
    required super.getService,
  });

  Timer? _levelPollingTimer;
  bool _isPolling = false;

  /// Helper to update a boolean channel property with optimistic update and revert on error.
  void _updateChannelBool({
    required int channelIndex,
    required bool Function(AudioChannelState) getValue,
    required AudioChannelState Function(AudioChannelState, bool) copyWithValue,
    required bool newValue,
    required Future<void> Function() apiCall,
    required String errorMessage,
  }) {
    final state = getState();
    final channels = List<AudioChannelState>.from(state.audio.channels);
    if (channelIndex >= channels.length) return;

    final previousValue = getValue(channels[channelIndex]);
    channels[channelIndex] = copyWithValue(channels[channelIndex], newValue);
    updateState(state.copyWith(audio: state.audio.copyWith(channels: channels)));

    apiCall().catchError((e) {
      // Revert to previous value on error
      final currentState = getState();
      final currentChannels = List<AudioChannelState>.from(currentState.audio.channels);
      if (channelIndex < currentChannels.length) {
        currentChannels[channelIndex] = copyWithValue(currentChannels[channelIndex], previousValue);
        updateState(currentState.copyWith(audio: currentState.audio.copyWith(channels: currentChannels)));
      }
      setError(errorMessage);
    });
  }

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
    _updateChannelBool(
      channelIndex: channelIndex,
      getValue: (ch) => ch.phantomPower,
      copyWithValue: (ch, v) => ch.copyWith(phantomPower: v),
      newValue: enabled,
      apiCall: () => getService()!.setPhantomPower(channelIndex, enabled),
      errorMessage: 'Phantom power not supported on this channel',
    );
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
    _updateChannelBool(
      channelIndex: channelIndex,
      getValue: (ch) => ch.lowCutFilter,
      copyWithValue: (ch, v) => ch.copyWith(lowCutFilter: v),
      newValue: enabled,
      apiCall: () => getService()!.setLowCutFilter(channelIndex, enabled),
      errorMessage: 'Low cut filter not supported on this camera',
    );
  }

  /// Set padding for a channel
  void setPadding(int channelIndex, bool enabled) {
    _updateChannelBool(
      channelIndex: channelIndex,
      getValue: (ch) => ch.padding,
      copyWithValue: (ch, v) => ch.copyWith(padding: v),
      newValue: enabled,
      apiCall: () => getService()!.setPadding(channelIndex, enabled),
      errorMessage: 'Padding not supported on this camera',
    );
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
