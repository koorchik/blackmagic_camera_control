/// API endpoints for Blackmagic Camera REST API
class ApiEndpoints {
  ApiEndpoints._();

  static const int defaultPort = 80;

  // Lens endpoints
  static const String lensFocus = '/control/api/v1/lens/focus';
  static const String lensDoAutoFocus = '/control/api/v1/lens/focus/doAutoFocus';
  static const String lensIris = '/control/api/v1/lens/iris';
  static const String lensZoom = '/control/api/v1/lens/zoom';

  // Video endpoints
  static const String videoIso = '/control/api/v1/video/iso';
  static const String videoShutter = '/control/api/v1/video/shutter';
  static const String videoAutoExposure = '/control/api/v1/video/autoExposure';
  static const String videoWhiteBalance = '/control/api/v1/video/whiteBalance';
  static const String videoWhiteBalanceTint =
      '/control/api/v1/video/whiteBalanceTint';
  static const String videoGain = '/control/api/v1/video/gain';

  // Transport endpoints
  static const String transportRecord = '/control/api/v1/transports/0/record';
  static const String transportTimecode =
      '/control/api/v1/transports/0/timecode';
  static const String transportPlay = '/control/api/v1/transports/0/play';
  static const String transportStop = '/control/api/v1/transports/0/stop';

  // System endpoints
  static const String system = '/control/api/v1/system';

  // WebSocket endpoint
  static String webSocket(String host, [int port = defaultPort]) =>
      'ws://$host:$port/control/api/v1/event/websocket';
}

/// Shared preferences keys
class PrefsKeys {
  PrefsKeys._();

  static const String lastCameraIp = 'last_camera_ip';
}

/// Debounce durations
class Durations {
  Durations._();

  static const Duration sliderDebounce = Duration(milliseconds: 50);
  static const Duration connectionTimeout = Duration(seconds: 5);
  static const Duration websocketReconnect = Duration(seconds: 3);
}
