import 'dart:async';
import 'camera_api_client.dart';
import 'camera_websocket.dart';
import '../models/camera_state.dart';
import '../models/camera_capabilities.dart';
import '../utils/constants.dart';

export 'camera_api_client.dart' show ApiException, FeatureNotSupportedException;

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
  Timer? _colorDebounceTimer;

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

  /// Stream of slate state updates from WebSocket
  Stream<SlateState> get slateUpdates => _webSocket.slateUpdates;

  /// Stream of audio level updates from WebSocket
  Stream<Map<int, double>> get audioLevelUpdates => _webSocket.audioLevelUpdates;

  /// Stream of color correction state updates from WebSocket
  Stream<ColorCorrectionState> get colorCorrectionUpdates =>
      _webSocket.colorCorrectionUpdates;

  /// Stream of media state updates from WebSocket
  Stream<MediaState> get mediaUpdates => _webSocket.mediaUpdates;

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

  /// Set auto exposure mode ("Off", "Continuous", "OneShot") for a specific type
  Future<void> setAutoExposureMode(String mode, {String type = 'Shutter'}) =>
      _apiClient.setAutoExposureMode(mode, type: type);

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

  // ========== SLATE/METADATA CONTROL ==========

  /// Get slate/metadata for next clip
  Future<SlateState> getSlate() => _apiClient.getSlate();

  /// Set slate/metadata for next clip
  Future<void> setSlate(SlateState slate) => _apiClient.setSlate(slate);

  /// Update specific slate fields
  Future<void> updateSlate(Map<String, dynamic> fields) =>
      _apiClient.updateSlate(fields);

  // ========== AUDIO CONTROL ==========

  /// Get audio level for a channel
  Future<double> getAudioLevel(int channelIndex) =>
      _apiClient.getAudioLevel(channelIndex);

  /// Get audio input type for a channel
  Future<AudioInputType> getAudioInput(int channelIndex) =>
      _apiClient.getAudioInput(channelIndex);

  /// Set audio input type for a channel
  Future<void> setAudioInput(int channelIndex, AudioInputType type) =>
      _apiClient.setAudioInput(channelIndex, type);

  /// Get phantom power state for a channel
  Future<bool> getPhantomPower(int channelIndex) =>
      _apiClient.getPhantomPower(channelIndex);

  /// Set phantom power state for a channel
  Future<void> setPhantomPower(int channelIndex, bool enabled) =>
      _apiClient.setPhantomPower(channelIndex, enabled);

  /// Fetch initial audio state for all channels
  Future<AudioState> fetchAudioState({int channelCount = 2}) async {
    final channels = <AudioChannelState>[];
    for (var i = 0; i < channelCount; i++) {
      try {
        final input = await _safeCall(() => getAudioInput(i), AudioInputType.mic);
        final phantom = await _safeCall(() => getPhantomPower(i), false);
        final level = await _safeCall(() => getAudioLevel(i), 0.0);
        channels.add(AudioChannelState(
          index: i,
          levelNormalized: level,
          inputType: input,
          phantomPower: phantom,
        ));
      } catch (e) {
        // Channel not available
        channels.add(AudioChannelState(index: i, available: false));
      }
    }
    return AudioState(channels: channels);
  }

  // ========== MEDIA MANAGEMENT ==========

  /// Get media working set (active recording slot)
  Future<int> getMediaWorkingSet() => _apiClient.getMediaWorkingSet();

  /// Set media working set (active recording slot)
  Future<void> setMediaWorkingSet(int index) =>
      _apiClient.setMediaWorkingSet(index);

  /// Get all media devices
  Future<List<MediaDevice>> getMediaDevices() => _apiClient.getMediaDevices();

  /// Get a specific media device
  Future<MediaDevice> getMediaDevice(String deviceName) =>
      _apiClient.getMediaDevice(deviceName);

  /// Fetch initial media state
  Future<MediaState> fetchMediaState() async {
    final devices = await _safeCall(() => getMediaDevices(), <MediaDevice>[]);
    final workingSet = await _safeCall(() => getMediaWorkingSet(), 0);
    return MediaState(
      devices: devices,
      workingsetIndex: workingSet,
    );
  }

  /// Format a media device (two-step operation)
  Future<void> formatDevice(String deviceName, FilesystemType filesystem) async {
    final key = await _apiClient.getFormatKey(deviceName);
    if (key.isEmpty) {
      throw ApiException('Failed to get format key');
    }
    await _apiClient.confirmFormat(deviceName, key, filesystem);
  }

  // ========== MONITORING CONTROL ==========

  /// Get available displays
  Future<List<String>> getAvailableDisplays() =>
      _apiClient.getAvailableDisplays();

  /// Get focus assist settings for a display
  Future<FocusAssistState> getFocusAssist(String displayName) =>
      _apiClient.getFocusAssist(displayName);

  /// Set focus assist settings for a display
  Future<void> setFocusAssist(String displayName, FocusAssistState state) =>
      _apiClient.setFocusAssist(displayName, state);

  /// Get zebra enabled for a display
  Future<bool> getZebraEnabled(String displayName) =>
      _apiClient.getZebraEnabled(displayName);

  /// Set zebra enabled for a display
  Future<void> setZebraEnabled(String displayName, bool enabled) =>
      _apiClient.setZebraEnabled(displayName, enabled);

  /// Get frame guides settings for a display
  Future<FrameGuidesState> getFrameGuides(String displayName) =>
      _apiClient.getFrameGuides(displayName);

  /// Set frame guides settings for a display
  Future<void> setFrameGuides(String displayName, FrameGuidesState state) =>
      _apiClient.setFrameGuides(displayName, state);

  /// Get clean feed enabled for a display
  Future<bool> getCleanFeedEnabled(String displayName) =>
      _apiClient.getCleanFeedEnabled(displayName);

  /// Set clean feed enabled for a display
  Future<void> setCleanFeedEnabled(String displayName, bool enabled) =>
      _apiClient.setCleanFeedEnabled(displayName, enabled);

  /// Get display LUT enabled for a display
  Future<bool> getDisplayLutEnabled(String displayName) =>
      _apiClient.getDisplayLutEnabled(displayName);

  /// Set display LUT enabled for a display
  Future<void> setDisplayLutEnabled(String displayName, bool enabled) =>
      _apiClient.setDisplayLutEnabled(displayName, enabled);

  /// Get program feed display enabled
  Future<bool> getProgramFeedEnabled() => _apiClient.getProgramFeedEnabled();

  /// Set program feed display enabled
  Future<void> setProgramFeedEnabled(bool enabled) =>
      _apiClient.setProgramFeedEnabled(enabled);

  /// Get current video format
  Future<Map<String, dynamic>> getVideoFormat() => _apiClient.getVideoFormat();

  /// Set video format
  Future<void> setVideoFormat(String name, String frameRate) =>
      _apiClient.setVideoFormat(name, frameRate);

  /// Fetch initial monitoring state
  Future<MonitoringState> fetchMonitoringState() async {
    final displays = await _safeCall(() => getAvailableDisplays(), <String>[]);
    final displayStates = <String, DisplayState>{};

    for (final name in displays) {
      try {
        final focusAssist =
            await _safeCall(() => getFocusAssist(name), const FocusAssistState());
        final zebraEnabled = await _safeCall(() => getZebraEnabled(name), false);
        final frameGuides =
            await _safeCall(() => getFrameGuides(name), const FrameGuidesState());
        final cleanFeedEnabled =
            await _safeCall(() => getCleanFeedEnabled(name), false);
        final displayLutEnabled =
            await _safeCall(() => getDisplayLutEnabled(name), false);

        displayStates[name] = DisplayState(
          name: name,
          focusAssist: focusAssist,
          zebraEnabled: zebraEnabled,
          frameGuides: frameGuides,
          cleanFeedEnabled: cleanFeedEnabled,
          displayLutEnabled: displayLutEnabled,
        );
      } catch (e) {
        // Display not accessible
      }
    }

    // Fetch camera-wide settings
    final programFeedEnabled =
        await _safeCall(() => getProgramFeedEnabled(), false);
    final videoFormatData =
        await _safeCall(() => getVideoFormat(), <String, dynamic>{});
    final currentVideoFormat = _formatVideoFormatString(videoFormatData);

    return MonitoringState(
      availableDisplays: displays,
      selectedDisplay: displays.isNotEmpty ? displays.first : null,
      displays: displayStates,
      programFeedEnabled: programFeedEnabled,
      currentVideoFormat: currentVideoFormat,
    );
  }

  /// Format video format data into a display string
  String? _formatVideoFormatString(Map<String, dynamic> data) {
    if (data.isEmpty) return null;
    final name = data['name'] as String?;
    final frameRate = data['frameRate'] as String?;
    if (name == null) return null;
    if (frameRate != null) {
      return '$name $frameRate';
    }
    return name;
  }

  // ========== COLOR CORRECTION CONTROL ==========

  /// Get color lift (shadows)
  Future<ColorWheelValues> getColorLift() => _apiClient.getColorLift();

  /// Set color lift (shadows)
  Future<void> setColorLift(ColorWheelValues values) =>
      _apiClient.setColorLift(values);

  /// Set color lift with debouncing
  void setColorLiftDebounced(ColorWheelValues values) {
    _colorDebounce(() => _apiClient.setColorLift(values));
  }

  /// Get color gamma (midtones)
  Future<ColorWheelValues> getColorGamma() => _apiClient.getColorGamma();

  /// Set color gamma (midtones)
  Future<void> setColorGamma(ColorWheelValues values) =>
      _apiClient.setColorGamma(values);

  /// Set color gamma with debouncing
  void setColorGammaDebounced(ColorWheelValues values) {
    _colorDebounce(() => _apiClient.setColorGamma(values));
  }

  /// Get color gain (highlights)
  Future<ColorWheelValues> getColorGain() => _apiClient.getColorGain();

  /// Set color gain (highlights)
  Future<void> setColorGain(ColorWheelValues values) =>
      _apiClient.setColorGain(values);

  /// Set color gain with debouncing
  void setColorGainDebounced(ColorWheelValues values) {
    _colorDebounce(() => _apiClient.setColorGain(values));
  }

  /// Get saturation
  Future<double> getColorSaturation() => _apiClient.getColorSaturation();

  /// Set saturation
  Future<void> setColorSaturation(double value) =>
      _apiClient.setColorSaturation(value);

  /// Get contrast
  Future<double> getColorContrast() => _apiClient.getColorContrast();

  /// Set contrast
  Future<void> setColorContrast(double value) =>
      _apiClient.setColorContrast(value);

  /// Get hue
  Future<double> getColorHue() => _apiClient.getColorHue();

  /// Set hue
  Future<void> setColorHue(double value) => _apiClient.setColorHue(value);

  /// Fetch initial color correction state
  Future<ColorCorrectionState> fetchColorCorrectionState() async {
    final lift = await _safeCall(() => getColorLift(), const ColorWheelValues());
    final gamma = await _safeCall(() => getColorGamma(), const ColorWheelValues());
    final gain = await _safeCall(() => getColorGain(), const ColorWheelValues());
    final saturation = await _safeCall(() => getColorSaturation(), 1.0);
    final contrast = await _safeCall(() => getColorContrast(), 1.0);
    final hue = await _safeCall(() => getColorHue(), 0.0);

    return ColorCorrectionState(
      lift: lift,
      gamma: gamma,
      gain: gain,
      saturation: saturation,
      contrast: contrast,
      hue: hue,
    );
  }

  // ========== CAPABILITIES DISCOVERY ==========

  /// Fetch camera capabilities (supported ISOs, shutter speeds, etc.)
  Future<CameraCapabilities> fetchCapabilities() async {
    final results = await Future.wait([
      _safeCall(() => _apiClient.getSupportedISOs(), <int>[]),
      _safeCall(() => _apiClient.getSupportedShutterSpeeds(), <int>[]),
      _safeCall(() => _apiClient.getSupportedNDFilters(), <double>[]),
      _safeCall(() => _apiClient.getSupportedVideoFormats(), <Map<String, dynamic>>[]),
      _safeCall(() => _apiClient.getSupportedCodecFormats(), <Map<String, dynamic>>[]),
    ]);

    final isos = results[0] as List<int>;
    final shutters = results[1] as List<int>;
    final nds = results[2] as List<double>;
    final formats = results[3] as List<Map<String, dynamic>>;
    final codecs = results[4] as List<Map<String, dynamic>>;

    // If we got no capabilities from the camera, use defaults
    if (isos.isEmpty && shutters.isEmpty) {
      return CameraCapabilities.defaults;
    }

    return CameraCapabilities(
      supportedISOs: isos.isNotEmpty ? isos : CameraCapabilities.defaults.supportedISOs,
      supportedShutterSpeeds: shutters.isNotEmpty ? shutters : CameraCapabilities.defaults.supportedShutterSpeeds,
      supportedNDFilters: nds.isNotEmpty ? nds : CameraCapabilities.defaults.supportedNDFilters,
      supportedVideoFormats: formats.map((f) => VideoFormat.fromJson(f)).toList(),
      supportedCodecFormats: codecs.map((c) => CodecFormat.fromJson(c)).toList(),
      isLoaded: true,
    );
  }

  void _colorDebounce(Future<void> Function() action) {
    _colorDebounceTimer?.cancel();
    _colorDebounceTimer = Timer(Durations.colorCorrectionDebounce, () {
      action();
    });
  }

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
    _colorDebounceTimer?.cancel();
    _apiClient.dispose();
    _webSocket.dispose();
  }
}
