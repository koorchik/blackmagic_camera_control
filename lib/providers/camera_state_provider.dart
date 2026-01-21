import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/camera_state.dart';
import '../services/camera_service.dart';

class CameraStateProvider extends ChangeNotifier {
  CameraStateProvider();

  CameraState _state = const CameraState();
  bool _isLoading = false;
  String? _error;
  CameraService? _cameraService;

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  CameraState get state => _state;
  LensState get lens => _state.lens;
  VideoState get video => _state.video;
  TransportState get transport => _state.transport;
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
  }

  Future<void> _fetchInitialState() async {
    final service = _cameraService;
    if (service == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _state = await service.fetchFullState();
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
    _cameraService?.setIris(value);
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
    _cameraService?.setIso(value).catchError((e) {
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

  /// Set auto exposure mode (optimistic update - fire and forget)
  void setAutoExposureMode(String mode) {
    final isAuto = mode != 'Off';
    _state = _state.copyWith(video: _state.video.copyWith(shutterAuto: isAuto));
    notifyListeners();
    _cameraService?.setAutoExposureMode(mode).catchError((e) {
      _error = 'Failed to set auto exposure: $e';
      notifyListeners();
    });
  }

  /// Toggle shutter auto exposure on/off
  void toggleShutterAuto() {
    final newMode = _state.video.shutterAuto ? 'Off' : 'Continuous';
    setAutoExposureMode(newMode);
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

  /// Start recording
  Future<void> startRecording() async {
    try {
      await _cameraService?.startRecording();
      _state = _state.copyWith(transport: _state.transport.copyWith(isRecording: true));
      notifyListeners();
    } catch (e) {
      _error = 'Failed to start recording: $e';
      notifyListeners();
    }
  }

  /// Stop recording
  Future<void> stopRecording() async {
    try {
      await _cameraService?.stopRecording();
      _state = _state.copyWith(transport: _state.transport.copyWith(isRecording: false));
      notifyListeners();
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
