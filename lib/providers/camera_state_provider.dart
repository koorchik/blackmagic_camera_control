import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/camera_state.dart';
import '../models/camera_capabilities.dart';
import '../services/camera_service.dart';
import '../controllers/lens_controller.dart';
import '../controllers/video_controller.dart';
import '../controllers/transport_controller.dart';
import '../controllers/slate_controller.dart';
import '../controllers/audio_controller.dart';
import '../controllers/media_controller.dart';
import '../controllers/monitoring_controller.dart';
import '../controllers/color_controller.dart';
import '../utils/camera_defaults.dart';

class CameraStateProvider extends ChangeNotifier {
  CameraStateProvider() {
    _initControllers();
  }

  CameraState _state = const CameraState();
  CameraCapabilities _capabilities = CameraCapabilities.defaults;
  bool _isLoading = false;
  String? _error;
  CameraService? _cameraService;

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  // Domain controllers
  late final LensController _lensController;
  late final VideoController _videoController;
  late final TransportController _transportController;
  late final SlateController _slateController;
  late final AudioController _audioController;
  late final MediaController _mediaController;
  late final MonitoringController _monitoringController;
  late final ColorController _colorController;

  // State getters
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

  void _initControllers() {
    _lensController = LensController(
      getState: () => _state,
      updateState: _updateState,
      setError: _setError,
      getService: () => _cameraService,
    );
    _videoController = VideoController(
      getState: () => _state,
      updateState: _updateState,
      setError: _setError,
      getService: () => _cameraService,
    );
    _transportController = TransportController(
      getState: () => _state,
      updateState: _updateState,
      setError: _setError,
      getService: () => _cameraService,
    );
    _slateController = SlateController(
      getState: () => _state,
      updateState: _updateState,
      setError: _setError,
      getService: () => _cameraService,
    );
    _audioController = AudioController(
      getState: () => _state,
      updateState: _updateState,
      setError: _setError,
      getService: () => _cameraService,
    );
    _mediaController = MediaController(
      getState: () => _state,
      updateState: _updateState,
      setError: _setError,
      getService: () => _cameraService,
    );
    _monitoringController = MonitoringController(
      getState: () => _state,
      updateState: _updateState,
      setError: _setError,
      getService: () => _cameraService,
    );
    _colorController = ColorController(
      getState: () => _state,
      updateState: _updateState,
      setError: _setError,
      getService: () => _cameraService,
    );
  }

  void _updateState(CameraState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

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
            focus: lens.focus != CameraDefaults.focus ? lens.focus : null,
            iris: lens.iris != CameraDefaults.iris ? lens.iris : null,
            zoom: lens.zoom != CameraDefaults.zoom ? lens.zoom : null,
          ),
        );
        notifyListeners();
      }),
    );

    _subscriptions.add(
      service.videoUpdates.listen((video) {
        // When in auto shutter mode, always apply shutter updates from camera
        // (camera auto-adjusts shutter when ISO/iris changes)
        final shouldApplyShutter = _state.video.shutterAuto ||
            video.shutterSpeed != CameraDefaults.shutterSpeed;
        _state = _state.copyWith(
          video: _state.video.copyWith(
            iso: video.iso != CameraDefaults.iso ? video.iso : null,
            shutterSpeed: shouldApplyShutter ? video.shutterSpeed : null,
            whiteBalance: video.whiteBalance != CameraDefaults.whiteBalance ? video.whiteBalance : null,
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

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ========== LENS CONTROLS (delegated) ==========
  void setFocusDebounced(double value) => _lensController.setFocusDebounced(value);
  void setFocusFinal(double value) => _lensController.setFocusFinal(value);
  Future<void> triggerAutofocus({double x = 0.5, double y = 0.5}) =>
      _lensController.triggerAutofocus(x: x, y: y);
  void setIrisDebounced(double value) => _lensController.setIrisDebounced(value);
  void setIrisFinal(double value) => _lensController.setIrisFinal(
        value,
        onComplete: () => _videoController.refreshShutterIfAuto(),
      );
  void setZoomDebounced(double value) => _lensController.setZoomDebounced(value);
  void setZoomFinal(double value) => _lensController.setZoomFinal(value);

  // ========== VIDEO CONTROLS (delegated) ==========
  void setIso(int value) => _videoController.setIso(
        value,
        onComplete: () => _videoController.refreshShutterIfAuto(),
      );
  void setShutterSpeed(int value) => _videoController.setShutterSpeed(value);
  void setShutterAutoExposure(bool enabled) => _videoController.setShutterAutoExposure(enabled);
  void toggleShutterAuto() => _videoController.toggleShutterAuto();
  void setWhiteBalance(int kelvin) => _videoController.setWhiteBalance(kelvin);
  void setWhiteBalanceTint(int tint) => _videoController.setWhiteBalanceTint(tint);

  // ========== TRANSPORT CONTROLS (delegated) ==========
  Future<void> startRecording() => _transportController.startRecording();
  Future<void> stopRecording() => _transportController.stopRecording();
  Future<void> toggleRecording() => _transportController.toggleRecording();

  // ========== SLATE CONTROLS (delegated) ==========
  void setSlateScene(String scene) => _slateController.setScene(scene);
  void setSlateTake(int take) => _slateController.setTake(take);
  void incrementSlateTake() => _slateController.incrementTake();
  void setSlateGoodTake(bool goodTake) => _slateController.setGoodTake(goodTake);
  void setSlateShotType(ShotType? shotType) => _slateController.setShotType(shotType);
  void setSlateLocation(SceneLocation? location) => _slateController.setLocation(location);
  void setSlateTime(SceneTime? time) => _slateController.setTime(time);
  void resetSlate() => _slateController.reset();
  Future<void> refreshSlate() => _slateController.refresh();

  // ========== AUDIO CONTROLS (delegated) ==========
  Future<void> refreshAudio() => _audioController.refresh();
  void setAudioInput(int channelIndex, AudioInputType type) => _audioController.setInput(channelIndex, type);
  void setPhantomPower(int channelIndex, bool enabled) => _audioController.setPhantomPower(channelIndex, enabled);
  void setAudioGainDebounced(int channelIndex, double normalizedValue) => _audioController.setGainDebounced(channelIndex, normalizedValue);
  void setAudioGainFinal(int channelIndex, double normalizedValue) => _audioController.setGainFinal(channelIndex, normalizedValue);
  void setLowCutFilter(int channelIndex, bool enabled) => _audioController.setLowCutFilter(channelIndex, enabled);
  void setAudioPadding(int channelIndex, bool enabled) => _audioController.setPadding(channelIndex, enabled);

  // ========== MEDIA CONTROLS (delegated) ==========
  Future<void> refreshMedia() => _mediaController.refresh();
  Future<void> formatDevice(String deviceName, FilesystemType filesystem) => _mediaController.formatDevice(deviceName, filesystem);

  // ========== MONITORING CONTROLS (delegated) ==========
  Future<void> refreshMonitoring() => _monitoringController.refresh();
  void selectDisplay(String displayName) => _monitoringController.selectDisplay(displayName);
  void setFocusAssistEnabled(bool enabled) => _monitoringController.setFocusAssistEnabled(enabled);
  void setFocusAssistSettings(FocusAssistState settings) => _monitoringController.setFocusAssistSettings(settings);
  @Deprecated('Use setFocusAssistEnabled and setFocusAssistSettings instead')
  void setFocusAssist(FocusAssistState focusAssist) => _monitoringController.setFocusAssist(focusAssist);
  void setZebraEnabled(bool enabled) => _monitoringController.setZebraEnabled(enabled);
  void setFrameGuidesEnabled(bool enabled) => _monitoringController.setFrameGuidesEnabled(enabled);
  void setFrameGuideRatio(FrameGuideRatio ratio) => _monitoringController.setFrameGuideRatio(ratio);
  @Deprecated('Use setFrameGuidesEnabled and setFrameGuideRatio instead')
  void setFrameGuides(FrameGuidesState frameGuides) => _monitoringController.setFrameGuides(frameGuides);
  void setCleanFeedEnabled(bool enabled) => _monitoringController.setCleanFeedEnabled(enabled);
  void setDisplayLutEnabled(bool enabled) => _monitoringController.setDisplayLutEnabled(enabled);
  void setProgramFeedEnabled(bool enabled) => _monitoringController.setProgramFeedEnabled(enabled);
  void setVideoFormat(String name, String frameRate) => _monitoringController.setVideoFormat(name, frameRate);

  // ========== COLOR CORRECTION CONTROLS (delegated) ==========
  Future<void> refreshColorCorrection() => _colorController.refresh();
  void setColorLiftDebounced(ColorWheelValues values) => _colorController.setLiftDebounced(values);
  void setColorLiftFinal(ColorWheelValues values) => _colorController.setLiftFinal(values);
  void setColorGammaDebounced(ColorWheelValues values) => _colorController.setGammaDebounced(values);
  void setColorGammaFinal(ColorWheelValues values) => _colorController.setGammaFinal(values);
  void setColorGainDebounced(ColorWheelValues values) => _colorController.setGainDebounced(values);
  void setColorGainFinal(ColorWheelValues values) => _colorController.setGainFinal(values);
  void setColorSaturation(double value) => _colorController.setSaturation(value);
  void setColorContrast(double value) => _colorController.setContrast(value);
  void setColorHue(double value) => _colorController.setHue(value);
  void resetColorCorrection() => _colorController.reset();

  Future<void> _cleanup() async {
    // Await all subscription cancellations
    await Future.wait(_subscriptions.map((sub) => sub.cancel()));
    _subscriptions.clear();
  }

  @override
  void dispose() {
    // Note: dispose() can't be async, but we still clean up synchronously
    // The subscriptions will be cancelled, though not awaited
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
    super.dispose();
  }
}
