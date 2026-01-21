import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/camera_state.dart';
import '../models/camera_capabilities.dart';
import '../services/camera_service.dart';

class CameraStateProvider extends ChangeNotifier {
  CameraStateProvider();

  CameraState _state = const CameraState();
  CameraCapabilities _capabilities = CameraCapabilities.defaults;
  bool _isLoading = false;
  String? _error;
  CameraService? _cameraService;

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  CameraState get state => _state;
  LensState get lens => _state.lens;
  VideoState get video => _state.video;
  TransportState get transport => _state.transport;
  SlateState get slate => _state.slate;
  AudioState get audio => _state.audio;
  MediaState get media => _state.media;
  MonitoringState get monitoring => _state.monitoring;
  ColorCorrectionState get colorCorrection => _state.colorCorrection;
  CameraCapabilities get capabilities => _capabilities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize with a camera service
  void initialize(CameraService? service) {
    if (service == _cameraService) return;

    _cleanup();
    _cameraService = service;

    if (service != null) {
      _setupSubscriptions();
      _fetchInitialState();
    } else {
      _state = const CameraState();
      notifyListeners();
    }
  }

  void _setupSubscriptions() {
    final service = _cameraService;
    if (service == null) return;

    _subscriptions.add(
      service.lensUpdates.listen((lens) {
        _state = _state.copyWith(
          lens: _state.lens.copyWith(
            focus: lens.focus != 0.5 ? lens.focus : null,
            iris: lens.iris != 0.0 ? lens.iris : null,
            zoom: lens.zoom != 0.0 ? lens.zoom : null,
          ),
        );
        notifyListeners();
      }),
    );

    _subscriptions.add(
      service.videoUpdates.listen((video) {
        _state = _state.copyWith(
          video: _state.video.copyWith(
            iso: video.iso != 800 ? video.iso : null,
            shutterSpeed: video.shutterSpeed != 50 ? video.shutterSpeed : null,
            whiteBalance: video.whiteBalance != 5600 ? video.whiteBalance : null,
          ),
        );
        notifyListeners();
      }),
    );

    _subscriptions.add(
      service.transportUpdates.listen((transport) {
        _state = _state.copyWith(
          transport: _state.transport.copyWith(
            isRecording: transport.isRecording,
            timecode: transport.timecode.isNotEmpty ? transport.timecode : null,
          ),
        );
        notifyListeners();
      }),
    );

    _subscriptions.add(
      service.slateUpdates.listen((slate) {
        _state = _state.copyWith(slate: slate);
        notifyListeners();
      }),
    );

    _subscriptions.add(
      service.audioLevelUpdates.listen((levelMap) {
        // Update levels for specific channels
        final channels = List<AudioChannelState>.from(_state.audio.channels);
        for (final entry in levelMap.entries) {
          if (entry.key < channels.length) {
            channels[entry.key] = channels[entry.key].copyWith(
              levelNormalized: entry.value,
            );
          }
        }
        _state = _state.copyWith(audio: _state.audio.copyWith(channels: channels));
        notifyListeners();
      }),
    );

    _subscriptions.add(
      service.colorCorrectionUpdates.listen((colorUpdate) {
        // Merge partial color correction updates
        _state = _state.copyWith(
          colorCorrection: _state.colorCorrection.copyWith(
            lift: colorUpdate.lift.isDefault ? null : colorUpdate.lift,
            gamma: colorUpdate.gamma.isDefault ? null : colorUpdate.gamma,
            gain: colorUpdate.gain.isDefault ? null : colorUpdate.gain,
          ),
        );
        notifyListeners();
      }),
    );

    _subscriptions.add(
      service.mediaUpdates.listen((media) {
        _state = _state.copyWith(media: media);
        notifyListeners();
      }),
    );
  }

  Future<void> _fetchInitialState() async {
    final service = _cameraService;
    if (service == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch camera state and capabilities in parallel
      final results = await Future.wait([
        service.fetchFullState(),
        service.fetchCapabilities(),
      ]);
      _state = results[0] as CameraState;
      _capabilities = results[1] as CameraCapabilities;
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch camera state: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh the camera state from the API
  Future<void> refresh() => _fetchInitialState();

  // ========== LENS CONTROLS ==========

  /// Set focus - debounced API call only (no state update, for smooth dragging)
  void setFocusDebounced(double value) {
    _cameraService?.setFocusDebounced(value);
  }

  /// Set focus position immediately (for drag end, fire and forget)
  void setFocusFinal(double value) {
    _state = _state.copyWith(lens: _state.lens.copyWith(focus: value));
    notifyListeners();
    _cameraService?.setFocus(value);
  }

  /// Trigger autofocus
  Future<void> triggerAutofocus() async {
    try {
      await _cameraService?.triggerAutofocus();
      // Wait a bit for AF to complete, then fetch new focus position
      await Future.delayed(const Duration(milliseconds: 500));
      final newFocus = await _cameraService?.getFocus();
      if (newFocus != null) {
        _state = _state.copyWith(lens: _state.lens.copyWith(focus: newFocus));
        notifyListeners();
      }
    } catch (e) {
      _error = 'Autofocus failed: $e';
      notifyListeners();
    }
  }

  /// Set iris - debounced API call only (no state update, for smooth dragging)
  void setIrisDebounced(double value) {
    _cameraService?.setIrisDebounced(value);
  }

  /// Set iris position immediately (for drag end, fire and forget)
  void setIrisFinal(double value) {
    _state = _state.copyWith(lens: _state.lens.copyWith(iris: value));
    notifyListeners();
    _cameraService?.setIris(value).then((_) => _refreshShutterIfAuto());
  }

  /// Set zoom - debounced API call only (no state update, for smooth dragging)
  void setZoomDebounced(double value) {
    _cameraService?.setZoomDebounced(value);
  }

  /// Set zoom position immediately (for drag end, fire and forget)
  void setZoomFinal(double value) {
    _state = _state.copyWith(lens: _state.lens.copyWith(zoom: value));
    notifyListeners();
    _cameraService?.setZoom(value);
  }

  // ========== VIDEO CONTROLS ==========

  /// Set ISO value (optimistic update - fire and forget)
  void setIso(int value) {
    _state = _state.copyWith(video: _state.video.copyWith(iso: value));
    notifyListeners();
    _cameraService?.setIso(value).then((_) => _refreshShutterIfAuto()).catchError((e) {
      _error = 'Failed to set ISO: $e';
      notifyListeners();
    });
  }

  /// Set shutter speed (optimistic update - fire and forget)
  void setShutterSpeed(int value) {
    _state = _state.copyWith(video: _state.video.copyWith(shutterSpeed: value));
    notifyListeners();
    _cameraService?.setShutterSpeed(value).catchError((e) {
      _error = 'Failed to set shutter: $e';
      notifyListeners();
    });
  }

  /// Set shutter auto exposure mode (optimistic update - fire and forget)
  void setShutterAutoExposure(bool enabled) {
    final mode = enabled ? 'Continuous' : 'Off';
    _state = _state.copyWith(video: _state.video.copyWith(shutterAuto: enabled));
    notifyListeners();
    _cameraService?.setAutoExposureMode(mode, type: 'Shutter').catchError((e) {
      _error = 'Failed to set shutter auto exposure: $e';
      notifyListeners();
    });
  }

  /// Toggle shutter auto exposure on/off
  void toggleShutterAuto() {
    setShutterAutoExposure(!_state.video.shutterAuto);
  }

  /// Refresh shutter value from camera (useful when in auto mode)
  Future<void> _refreshShutterIfAuto() async {
    if (!_state.video.shutterAuto) return;

    // Small delay to let camera adjust
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      final shutterData = await _cameraService?.api.getShutter();
      if (shutterData != null) {
        final newSpeed = shutterData['shutterSpeed'] as int?;
        if (newSpeed != null && newSpeed != _state.video.shutterSpeed) {
          _state = _state.copyWith(
            video: _state.video.copyWith(shutterSpeed: newSpeed),
          );
          notifyListeners();
        }
      }
    } catch (e) {
      // Ignore errors during refresh
    }
  }

  /// Set white balance in Kelvin (optimistic update - fire and forget)
  void setWhiteBalance(int kelvin) {
    _state = _state.copyWith(video: _state.video.copyWith(whiteBalance: kelvin));
    notifyListeners();
    _cameraService?.setWhiteBalance(kelvin).catchError((e) {
      _error = 'Failed to set white balance: $e';
      notifyListeners();
    });
  }

  /// Set white balance tint (optimistic update - fire and forget)
  void setWhiteBalanceTint(int tint) {
    _state = _state.copyWith(video: _state.video.copyWith(whiteBalanceTint: tint));
    notifyListeners();
    _cameraService?.setWhiteBalanceTint(tint).catchError((e) {
      _error = 'Failed to set tint: $e';
      notifyListeners();
    });
  }

  // ========== TRANSPORT CONTROLS ==========

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Start recording
  Future<void> startRecording() async {
    final service = _cameraService;
    if (service == null) return;

    _error = null; // Clear any previous error

    try {
      await service.startRecording();

      // Wait a moment for the camera to process the command
      await Future.delayed(const Duration(milliseconds: 300));

      // Verify the actual recording state
      final actualState = await service.api.getRecordingState();
      _state = _state.copyWith(
        transport: _state.transport.copyWith(isRecording: actualState),
      );
      notifyListeners();

      if (!actualState) {
        _error = 'Failed to start recording. Check media is inserted and has space.';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to start recording: $e';
      notifyListeners();
    }
  }

  /// Stop recording
  Future<void> stopRecording() async {
    final service = _cameraService;
    if (service == null) return;

    _error = null; // Clear any previous error

    try {
      await service.stopRecording();

      // Wait a moment for the camera to process the command
      await Future.delayed(const Duration(milliseconds: 300));

      // Verify the actual recording state
      final actualState = await service.api.getRecordingState();
      _state = _state.copyWith(
        transport: _state.transport.copyWith(isRecording: actualState),
      );
      notifyListeners();

      if (actualState) {
        _error = 'Failed to stop recording.';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to stop recording: $e';
      notifyListeners();
    }
  }

  /// Toggle recording state
  Future<void> toggleRecording() async {
    if (_state.transport.isRecording) {
      await stopRecording();
    } else {
      await startRecording();
    }
  }

  // ========== SLATE CONTROLS ==========

  /// Update slate scene
  void setSlateScene(String scene) {
    _state = _state.copyWith(slate: _state.slate.copyWith(scene: scene));
    notifyListeners();
    _cameraService?.updateSlate({'scene': scene}).catchError((e) {
      _error = 'Failed to update scene: $e';
      notifyListeners();
    });
  }

  /// Update slate take number
  void setSlateTake(int take) {
    _state = _state.copyWith(slate: _state.slate.copyWith(take: take));
    notifyListeners();
    _cameraService?.updateSlate({'take': take}).catchError((e) {
      _error = 'Failed to update take: $e';
      notifyListeners();
    });
  }

  /// Increment slate take number
  void incrementSlateTake() {
    setSlateTake(_state.slate.take + 1);
  }

  /// Update good take flag
  void setSlateGoodTake(bool goodTake) {
    _state = _state.copyWith(slate: _state.slate.copyWith(goodTake: goodTake));
    notifyListeners();
    _cameraService?.updateSlate({'goodTake': goodTake}).catchError((e) {
      _error = 'Failed to update good take: $e';
      notifyListeners();
    });
  }

  /// Update shot type
  void setSlateShotType(ShotType? shotType) {
    _state = _state.copyWith(
      slate: shotType == null
          ? _state.slate.copyWith(clearShotType: true)
          : _state.slate.copyWith(shotType: shotType),
    );
    notifyListeners();
    _cameraService?.updateSlate({
      'shotType': shotType?.code,
    }).catchError((e) {
      _error = 'Failed to update shot type: $e';
      notifyListeners();
    });
  }

  /// Update scene location
  void setSlateLocation(SceneLocation? location) {
    _state = _state.copyWith(
      slate: location == null
          ? _state.slate.copyWith(clearSceneLocation: true)
          : _state.slate.copyWith(sceneLocation: location),
    );
    notifyListeners();
    _cameraService?.updateSlate({
      'sceneLocation': location?.code,
    }).catchError((e) {
      _error = 'Failed to update location: $e';
      notifyListeners();
    });
  }

  /// Update scene time
  void setSlateTime(SceneTime? time) {
    _state = _state.copyWith(
      slate: time == null
          ? _state.slate.copyWith(clearSceneTime: true)
          : _state.slate.copyWith(sceneTime: time),
    );
    notifyListeners();
    _cameraService?.updateSlate({
      'sceneTime': time?.code,
    }).catchError((e) {
      _error = 'Failed to update time: $e';
      notifyListeners();
    });
  }

  /// Fetch fresh slate data
  Future<void> refreshSlate() async {
    try {
      final slate = await _cameraService?.getSlate();
      if (slate != null) {
        _state = _state.copyWith(slate: slate);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to fetch slate: $e';
      notifyListeners();
    }
  }

  // ========== AUDIO CONTROLS ==========

  /// Fetch fresh audio state
  Future<void> refreshAudio() async {
    try {
      final audio = await _cameraService?.fetchAudioState();
      if (audio != null) {
        _state = _state.copyWith(audio: audio);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to fetch audio state: $e';
      notifyListeners();
    }
  }

  /// Set audio input type for a channel
  void setAudioInput(int channelIndex, AudioInputType type) {
    final channels = List<AudioChannelState>.from(_state.audio.channels);
    if (channelIndex < channels.length) {
      channels[channelIndex] = channels[channelIndex].copyWith(inputType: type);
      _state = _state.copyWith(audio: _state.audio.copyWith(channels: channels));
      notifyListeners();
    }
    _cameraService?.setAudioInput(channelIndex, type).catchError((e) {
      _error = 'Failed to set audio input: $e';
      notifyListeners();
    });
  }

  /// Set phantom power for a channel
  void setPhantomPower(int channelIndex, bool enabled) {
    final channels = List<AudioChannelState>.from(_state.audio.channels);
    if (channelIndex < channels.length) {
      channels[channelIndex] = channels[channelIndex].copyWith(phantomPower: enabled);
      _state = _state.copyWith(audio: _state.audio.copyWith(channels: channels));
      notifyListeners();
    }
    _cameraService?.setPhantomPower(channelIndex, enabled).catchError((e) {
      _error = 'Failed to set phantom power: $e';
      notifyListeners();
    });
  }

  // ========== MEDIA CONTROLS ==========

  /// Fetch fresh media state
  Future<void> refreshMedia() async {
    try {
      final media = await _cameraService?.fetchMediaState();
      if (media != null) {
        _state = _state.copyWith(media: media);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to fetch media state: $e';
      notifyListeners();
    }
  }

  /// Format a media device
  Future<void> formatDevice(String deviceName, FilesystemType filesystem) async {
    _state = _state.copyWith(
      media: _state.media.copyWith(
        formatInProgress: true,
        formatDeviceName: deviceName,
      ),
    );
    notifyListeners();

    try {
      await _cameraService?.formatDevice(deviceName, filesystem);
      // Refresh media state after format
      await refreshMedia();
    } catch (e) {
      _error = 'Failed to format device: $e';
      notifyListeners();
    } finally {
      _state = _state.copyWith(
        media: _state.media.copyWith(
          formatInProgress: false,
          clearFormatDeviceName: true,
        ),
      );
      notifyListeners();
    }
  }

  // ========== MONITORING CONTROLS ==========

  /// Fetch fresh monitoring state
  Future<void> refreshMonitoring() async {
    try {
      final monitoring = await _cameraService?.fetchMonitoringState();
      if (monitoring != null) {
        _state = _state.copyWith(monitoring: monitoring);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to fetch monitoring state: $e';
      notifyListeners();
    }
  }

  /// Select a display for monitoring settings
  void selectDisplay(String displayName) {
    _state = _state.copyWith(
      monitoring: _state.monitoring.copyWith(selectedDisplay: displayName),
    );
    notifyListeners();
  }

  /// Set focus assist for current display
  void setFocusAssist(FocusAssistState focusAssist) {
    final displayName = _state.monitoring.selectedDisplay;
    if (displayName == null) return;

    final currentDisplay = _state.monitoring.displays[displayName];
    if (currentDisplay == null) return;

    final updatedDisplay = currentDisplay.copyWith(focusAssist: focusAssist);
    _state = _state.copyWith(
      monitoring: _state.monitoring.updateDisplay(displayName, updatedDisplay),
    );
    notifyListeners();

    _cameraService?.setFocusAssist(displayName, focusAssist).catchError((e) {
      _error = 'Failed to set focus assist: $e';
      notifyListeners();
    });
  }

  /// Set zebra enabled for current display
  void setZebraEnabled(bool enabled) {
    final displayName = _state.monitoring.selectedDisplay;
    if (displayName == null) return;

    final currentDisplay = _state.monitoring.displays[displayName];
    if (currentDisplay == null) return;

    final updatedDisplay = currentDisplay.copyWith(zebraEnabled: enabled);
    _state = _state.copyWith(
      monitoring: _state.monitoring.updateDisplay(displayName, updatedDisplay),
    );
    notifyListeners();

    _cameraService?.setZebraEnabled(displayName, enabled).catchError((e) {
      _error = 'Failed to set zebra: $e';
      notifyListeners();
    });
  }

  /// Set frame guides for current display
  void setFrameGuides(FrameGuidesState frameGuides) {
    final displayName = _state.monitoring.selectedDisplay;
    if (displayName == null) return;

    final currentDisplay = _state.monitoring.displays[displayName];
    if (currentDisplay == null) return;

    final updatedDisplay = currentDisplay.copyWith(frameGuides: frameGuides);
    _state = _state.copyWith(
      monitoring: _state.monitoring.updateDisplay(displayName, updatedDisplay),
    );
    notifyListeners();

    _cameraService?.setFrameGuides(displayName, frameGuides).catchError((e) {
      _error = 'Failed to set frame guides: $e';
      notifyListeners();
    });
  }

  // ========== COLOR CORRECTION CONTROLS ==========

  /// Fetch fresh color correction state
  Future<void> refreshColorCorrection() async {
    try {
      final colorCorrection = await _cameraService?.fetchColorCorrectionState();
      if (colorCorrection != null) {
        _state = _state.copyWith(colorCorrection: colorCorrection);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to fetch color correction state: $e';
      notifyListeners();
    }
  }

  /// Set color lift (shadows) - debounced
  void setColorLiftDebounced(ColorWheelValues values) {
    _cameraService?.setColorLiftDebounced(values);
  }

  /// Set color lift (shadows) - final value
  void setColorLiftFinal(ColorWheelValues values) {
    _state = _state.copyWith(
      colorCorrection: _state.colorCorrection.copyWith(lift: values),
    );
    notifyListeners();
    _cameraService?.setColorLift(values);
  }

  /// Set color gamma (midtones) - debounced
  void setColorGammaDebounced(ColorWheelValues values) {
    _cameraService?.setColorGammaDebounced(values);
  }

  /// Set color gamma (midtones) - final value
  void setColorGammaFinal(ColorWheelValues values) {
    _state = _state.copyWith(
      colorCorrection: _state.colorCorrection.copyWith(gamma: values),
    );
    notifyListeners();
    _cameraService?.setColorGamma(values);
  }

  /// Set color gain (highlights) - debounced
  void setColorGainDebounced(ColorWheelValues values) {
    _cameraService?.setColorGainDebounced(values);
  }

  /// Set color gain (highlights) - final value
  void setColorGainFinal(ColorWheelValues values) {
    _state = _state.copyWith(
      colorCorrection: _state.colorCorrection.copyWith(gain: values),
    );
    notifyListeners();
    _cameraService?.setColorGain(values);
  }

  /// Set saturation
  void setColorSaturation(double value) {
    _state = _state.copyWith(
      colorCorrection: _state.colorCorrection.copyWith(saturation: value),
    );
    notifyListeners();
    _cameraService?.setColorSaturation(value).catchError((e) {
      _error = 'Failed to set saturation: $e';
      notifyListeners();
    });
  }

  /// Set contrast
  void setColorContrast(double value) {
    _state = _state.copyWith(
      colorCorrection: _state.colorCorrection.copyWith(contrast: value),
    );
    notifyListeners();
    _cameraService?.setColorContrast(value).catchError((e) {
      _error = 'Failed to set contrast: $e';
      notifyListeners();
    });
  }

  /// Set hue
  void setColorHue(double value) {
    _state = _state.copyWith(
      colorCorrection: _state.colorCorrection.copyWith(hue: value),
    );
    notifyListeners();
    _cameraService?.setColorHue(value).catchError((e) {
      _error = 'Failed to set hue: $e';
      notifyListeners();
    });
  }

  /// Reset all color correction to default
  void resetColorCorrection() {
    _state = _state.copyWith(
      colorCorrection: _state.colorCorrection.reset(),
    );
    notifyListeners();
    // Reset each component with correct defaults
    // Lift and Gamma use 0.0 (additive), Gain uses 1.0 (multiplicative)
    _cameraService?.setColorLift(ColorWheelValues.liftGammaDefault);
    _cameraService?.setColorGamma(ColorWheelValues.liftGammaDefault);
    _cameraService?.setColorGain(ColorWheelValues.gainDefault);
    // Note: saturation, contrast, hue, lumaMix endpoints not supported by camera API
  }

  void _cleanup() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}
