import 'dart:async';
import 'camera_api_client.dart';
import 'camera_websocket.dart';
import '../models/camera_state.dart';
import '../utils/constants.dart';

/// Facade combining REST API and WebSocket clients
class CameraService {
  CameraService({
    required this.host,
    this.port = ApiEndpoints.defaultPort,
  })  : _apiClient = CameraApiClient(host: host, port: port),
        _webSocket = CameraWebSocket(host: host, port: port);

  final String host;
  final int port;
  final CameraApiClient _apiClient;
  final CameraWebSocket _webSocket;

  Timer? _debounceTimer;

  /// Get the API client for direct access
  CameraApiClient get api => _apiClient;

  /// Get the WebSocket client for direct access
  CameraWebSocket get webSocket => _webSocket;

  /// Stream of lens state updates from WebSocket
  Stream<LensState> get lensUpdates => _webSocket.lensUpdates;

  /// Stream of video state updates from WebSocket
  Stream<VideoState> get videoUpdates => _webSocket.videoUpdates;

  /// Stream of transport state updates from WebSocket
  Stream<TransportState> get transportUpdates => _webSocket.transportUpdates;

  /// Stream of connection state changes
  Stream<bool> get connectionUpdates => _webSocket.connectionUpdates;

  /// Test connection to the camera
  Future<bool> testConnection() => _apiClient.testConnection();

  /// Connect to WebSocket for real-time updates
  Future<void> connectWebSocket() => _webSocket.connect();

  /// Disconnect WebSocket
  Future<void> disconnectWebSocket() => _webSocket.disconnect();

  /// Fetch complete camera state via REST API
  Future<CameraState> fetchFullState() async {
    final results = await Future.wait([
      _safeCall(() => _apiClient.getFocus(), 0.5),
      _safeCall(() => _apiClient.getIris(), 0.0),
      _safeCall(() => _apiClient.getZoom(), 0.0),
      _safeCall(() => _apiClient.getIso(), 800),
      _safeCall(() => _apiClient.getShutter(), <String, dynamic>{}),
      _safeCall(() => _apiClient.getWhiteBalance(), 5600),
      _safeCall(() => _apiClient.getRecordingState(), false),
      _safeCall(() => _apiClient.getTimecode(), '00:00:00:00'),
    ]);

    final shutterData = results[4] as Map<String, dynamic>;

    return CameraState(
      lens: LensState(
        focus: results[0] as double,
        iris: results[1] as double,
        zoom: results[2] as double,
      ),
      video: VideoState(
        iso: results[3] as int,
        shutterSpeed: shutterData['shutterSpeed'] as int? ?? 50,
        shutterAuto: shutterData['continuousShutterAutoExposure'] as bool? ?? false,
        whiteBalance: results[5] as int,
      ),
      transport: TransportState(
        isRecording: results[6] as bool,
        timecode: results[7] as String,
      ),
    );
  }

  /// Set focus with debouncing to avoid API flooding
  void setFocusDebounced(double value) {
    _debounce(() => _apiClient.setFocus(value));
  }

  /// Set focus immediately (no debounce)
  Future<void> setFocus(double value) => _apiClient.setFocus(value);

  /// Trigger autofocus
  Future<void> triggerAutofocus() => _apiClient.triggerAutofocus();

  /// Get current focus position
  Future<double> getFocus() => _apiClient.getFocus();

  /// Set iris with debouncing
  void setIrisDebounced(double value) {
    _debounce(() => _apiClient.setIris(value));
  }

  /// Set iris immediately
  Future<void> setIris(double value) => _apiClient.setIris(value);

  /// Set zoom with debouncing
  void setZoomDebounced(double value) {
    _debounce(() => _apiClient.setZoom(value));
  }

  /// Set zoom immediately
  Future<void> setZoom(double value) => _apiClient.setZoom(value);

  /// Set ISO
  Future<void> setIso(int value) => _apiClient.setIso(value);

  /// Set shutter speed
  Future<void> setShutterSpeed(int value) => _apiClient.setShutterSpeed(value);

  /// Set auto exposure mode ("Off", "Continuous", "OneShot")
  Future<void> setAutoExposureMode(String mode) => _apiClient.setAutoExposureMode(mode);

  /// Set white balance
  Future<void> setWhiteBalance(int kelvin) => _apiClient.setWhiteBalance(kelvin);

  /// Set white balance tint
  Future<void> setWhiteBalanceTint(int tint) => _apiClient.setWhiteBalanceTint(tint);

  /// Start recording
  Future<void> startRecording() => _apiClient.startRecording();

  /// Stop recording
  Future<void> stopRecording() => _apiClient.stopRecording();

  /// Toggle recording
  Future<void> toggleRecording() => _apiClient.toggleRecording();

  void _debounce(Future<void> Function() action) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Durations.sliderDebounce, () {
      action();
    });
  }

  Future<T> _safeCall<T>(Future<T> Function() call, T defaultValue) async {
    try {
      return await call();
    } catch (e) {
      return defaultValue;
    }
  }

  /// Dispose of resources
  void dispose() {
    _debounceTimer?.cancel();
    _apiClient.dispose();
    _webSocket.dispose();
  }
}
