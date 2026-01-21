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
  static const String systemProduct = '/control/api/v1/system/product';

  // Slate/Metadata endpoints
  static const String slateNextClip = '/control/api/v1/slates/nextClip';

  // Audio endpoints
  static String audioChannelLevel(int index) =>
      '/control/api/v1/audio/channel/$index/level';
  static String audioChannelInput(int index) =>
      '/control/api/v1/audio/channel/$index/input';
  static String audioChannelPhantom(int index) =>
      '/control/api/v1/audio/channel/$index/phantomPower';

  // Media endpoints
  static const String mediaWorkingSet = '/control/api/v1/media/workingset';
  static const String mediaDevices = '/control/api/v1/media/devices';
  static String mediaDevice(String deviceName) =>
      '/control/api/v1/media/devices/$deviceName';
  static String mediaFormat(String deviceName) =>
      '/control/api/v1/media/devices/$deviceName/doformat';

  // Monitoring endpoints
  static const String monitoringDisplays = '/control/api/v1/monitoring/display';
  static String focusAssist(String displayName) =>
      '/control/api/v1/monitoring/$displayName/focusAssist';
  static String zebra(String displayName) =>
      '/control/api/v1/monitoring/$displayName/zebra';
  static String frameGuides(String displayName) =>
      '/control/api/v1/monitoring/$displayName/frameGuide';
  static String cleanFeed(String displayName) =>
      '/control/api/v1/monitoring/$displayName/cleanFeed';
  static String displayLut(String displayName) =>
      '/control/api/v1/monitoring/$displayName/displayLUT';

  // Camera output endpoints
  static const String programFeedDisplay =
      '/control/api/v1/camera/programFeedDisplay';
  static const String videoFormat = '/control/api/v1/system/videoFormat';

  // Color Correction endpoints
  static const String colorLift = '/control/api/v1/colorCorrection/lift';
  static const String colorGamma = '/control/api/v1/colorCorrection/gamma';
  static const String colorGain = '/control/api/v1/colorCorrection/gain';
  static const String colorSaturation =
      '/control/api/v1/colorCorrection/saturation';
  static const String colorContrast =
      '/control/api/v1/colorCorrection/contrast';
  static const String colorHue = '/control/api/v1/colorCorrection/hue';

  // Capabilities Discovery endpoints
  static const String supportedISOs = '/control/api/v1/video/supportedISOs';
  static const String supportedShutterSpeeds =
      '/control/api/v1/video/supportedShutterSpeeds';
  static const String supportedNDFilters =
      '/control/api/v1/video/supportedNDFilters';
  static const String supportedVideoFormats =
      '/control/api/v1/system/supportedVideoFormats';
  static const String supportedCodecFormats =
      '/control/api/v1/system/supportedCodecFormats';

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
  static const Duration colorCorrectionDebounce = Duration(milliseconds: 100);
  static const Duration connectionTimeout = Duration(seconds: 5);
  static const Duration websocketReconnect = Duration(seconds: 3);
}

/// Discovery constants for camera autodiscovery
class DiscoveryConstants {
  DiscoveryConstants._();

  /// Timeout for the entire discovery operation
  static const Duration discoveryTimeout = Duration(seconds: 15);

  /// Timeout for validating individual cameras
  static const Duration validationTimeout = Duration(seconds: 2);

  /// Known default mDNS hostnames for Blackmagic cameras
  static const List<String> knownCameraHostnames = [
    'micro-studio-camera-4k-g2.local',
    'studio-camera-4k-pro.local',
    'studio-camera-4k-pro-g2.local',
    'studio-camera-4k-plus.local',
    'studio-camera-4k-plus-g2.local',
    'studio-camera-6k-pro.local',
    'ursa-broadcast-g2.local',
    'cinema-camera-6k.local',
    'pyxis-6k.local',
    'ursa-cine-12k-lf.local',
  ];
}
