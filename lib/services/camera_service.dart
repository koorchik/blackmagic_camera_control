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

  /// Trigger autofocus at a specific position in frame
  Future<void> triggerAutofocus({double x = 0.5, double y = 0.5}) =>
      _apiClient.triggerAutofocus(x: x, y: y);

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

  /// Trigger auto white balance
  Future<void> triggerAutoWhiteBalance() => _apiClient.triggerAutoWhiteBalance();

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

  /// Get total number of audio channels available
  Future<int> getAudioChannelCount() =>
      _apiClient.getAudioChannelCount();

  /// Get channel availability status
  Future<bool> getAudioChannelAvailable(int channelIndex) =>
      _apiClient.getAudioChannelAvailable(channelIndex);

  /// Get audio level for a channel (meter reading)
  Future<double> getAudioLevel(int channelIndex) =>
      _apiClient.getAudioLevel(channelIndex);

  /// Get full audio level data including gain settings for a channel
  Future<Map<String, dynamic>> getAudioLevelFull(int channelIndex) =>
      _apiClient.getAudioLevelFull(channelIndex);

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

  /// Get supported inputs for a channel
  /// Returns list of objects with 'input' (string) and 'available' (bool)
  Future<List<Map<String, dynamic>>> getSupportedInputs(int channelIndex) =>
      _apiClient.getSupportedInputs(channelIndex);

  /// Set audio level/gain for a channel
  Future<void> setAudioLevel(int channelIndex, {double? gain, double? normalized}) =>
      _apiClient.setAudioLevel(channelIndex, gain: gain, normalized: normalized);

  /// Set audio level with debouncing
  void setAudioLevelDebounced(int channelIndex, {double? gain, double? normalized}) {
    _debounce(() => _apiClient.setAudioLevel(channelIndex, gain: gain, normalized: normalized));
  }

  /// Get low cut filter state for a channel
  Future<bool> getLowCutFilter(int channelIndex) =>
      _apiClient.getLowCutFilter(channelIndex);

  /// Set low cut filter state for a channel
  Future<void> setLowCutFilter(int channelIndex, bool enabled) =>
      _apiClient.setLowCutFilter(channelIndex, enabled);

  /// Get padding state for a channel
  Future<bool> getPadding(int channelIndex) =>
      _apiClient.getPadding(channelIndex);

  /// Set padding state for a channel
  Future<void> setPadding(int channelIndex, bool enabled) =>
      _apiClient.setPadding(channelIndex, enabled);

  /// Get input description/capabilities for a channel
  Future<Map<String, dynamic>> getInputDescription(int channelIndex) =>
      _apiClient.getInputDescription(channelIndex);

  /// Fetch initial audio state for all channels
  Future<AudioState> fetchAudioState({int? channelCount}) async {
    // Get dynamic channel count from API if not provided
    final int count = channelCount ?? await _safeCall(() => getAudioChannelCount(), 2);

    final channels = <AudioChannelState>[];
    for (var i = 0; i < count; i++) {
      try {
        // Check if channel is available first
        final available = await _safeCall(() => getAudioChannelAvailable(i), true);
        if (!available) {
          channels.add(AudioChannelState(index: i, available: false));
          continue;
        }

        final input = await _safeCall(() => getAudioInput(i), AudioInputType.mic);
        final phantom = await _safeCall(() => getPhantomPower(i), false);
        final lowCut = await _safeCall(() => getLowCutFilter(i), false);
        final padding = await _safeCall(() => getPadding(i), false);
        final supportedInputsData = await _safeCall(() => getSupportedInputs(i), <Map<String, dynamic>>[]);
        final inputDesc = await _safeCall(() => getInputDescription(i), <String, dynamic>{});

        // Get level/gain data from the level endpoint
        final levelData = await _safeCall(() => getAudioLevelFull(i), <String, dynamic>{});

        // Parse all possible gain-related fields
        // The 'normalised' field could be gain OR meter level depending on camera
        final normalised = (levelData['normalised'] as num?)?.toDouble() ?? 0.5;
        final gainFromResponse = (levelData['gain'] as num?)?.toDouble();
        final inputLevel = (levelData['inputLevel'] as num?)?.toDouble();

        // Use 'gain' field if present, otherwise fall back to 'normalised'
        final gainNormalized = inputLevel ?? normalised;
        final gain = gainFromResponse ?? 0.0;

        // For VU meter - will be updated by polling, start at 0
        final levelNormalized = 0.0;

        // Parse gain range from input description
        // API returns: { "description": { "gainRange": { "Min": ..., "Max": ... }, ... } }
        final description = inputDesc['description'] as Map<String, dynamic>?;
        final gainRange = description?['gainRange'] as Map<String, dynamic>?;
        // Note: API uses uppercase 'Min' and 'Max' keys
        final minGain = (gainRange?['Min'] as num?)?.toDouble() ?? 0.0;
        final maxGain = (gainRange?['Max'] as num?)?.toDouble() ?? 36.0;

        // Extract input names from supported inputs data
        // API returns: [ { "input": "Mic", "available": true }, ... ]
        final supportedTypes = supportedInputsData
            .map((item) => AudioInputType.fromString(item['input'] as String?))
            .toList();

        channels.add(AudioChannelState(
          index: i,
          levelNormalized: levelNormalized,
          gain: gain,
          gainNormalized: gainNormalized,
          inputType: input,
          phantomPower: phantom,
          lowCutFilter: lowCut,
          padding: padding,
          supportedInputs: supportedTypes,
          minGain: minGain,
          maxGain: maxGain,
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

  /// Set focus assist enabled for a display (per-display toggle)
  Future<void> setFocusAssistEnabled(String displayName, bool enabled) =>
      _apiClient.setFocusAssistEnabled(displayName, enabled);

  /// Get global focus assist settings (camera-wide)
  Future<FocusAssistState> getGlobalFocusAssist() =>
      _apiClient.getGlobalFocusAssist();

  /// Set global focus assist settings (camera-wide: mode, color, intensity)
  Future<void> setGlobalFocusAssist(FocusAssistState state) =>
      _apiClient.setGlobalFocusAssist(state);

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

  /// Get frame guide ratio (camera-wide setting)
  Future<String> getFrameGuideRatio() => _apiClient.getFrameGuideRatio();

  /// Set frame guide ratio (camera-wide setting)
  Future<void> setFrameGuideRatio(String ratio) =>
      _apiClient.setFrameGuideRatio(ratio);

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

  /// Get color bars enabled
  Future<bool> getColorBarsEnabled() => _apiClient.getColorBarsEnabled();

  /// Set color bars enabled
  Future<void> setColorBarsEnabled(bool enabled) =>
      _apiClient.setColorBarsEnabled(enabled);

  /// Get false color enabled for a display
  Future<bool> getFalseColorEnabled(String displayName) =>
      _apiClient.getFalseColorEnabled(displayName);

  /// Set false color enabled for a display
  Future<void> setFalseColorEnabled(String displayName, bool enabled) =>
      _apiClient.setFalseColorEnabled(displayName, enabled);

  /// Get safe area enabled for a display
  Future<bool> getSafeAreaEnabled(String displayName) =>
      _apiClient.getSafeAreaEnabled(displayName);

  /// Set safe area enabled for a display
  Future<void> setSafeAreaEnabled(String displayName, bool enabled) =>
      _apiClient.setSafeAreaEnabled(displayName, enabled);

  /// Get safe area percentage (camera-wide)
  Future<int> getSafeAreaPercent() => _apiClient.getSafeAreaPercent();

  /// Set safe area percentage (camera-wide)
  Future<void> setSafeAreaPercent(int percent) =>
      _apiClient.setSafeAreaPercent(percent);

  /// Get frame grids enabled for a display
  Future<bool> getFrameGridsEnabled(String displayName) =>
      _apiClient.getFrameGridsEnabled(displayName);

  /// Set frame grids enabled for a display
  Future<void> setFrameGridsEnabled(String displayName, bool enabled) =>
      _apiClient.setFrameGridsEnabled(displayName, enabled);

  /// Get global frame grids settings (camera-wide)
  Future<List<String>> getGlobalFrameGrids() =>
      _apiClient.getGlobalFrameGrids();

  /// Set global frame grids settings (camera-wide)
  Future<void> setGlobalFrameGrids(List<String> grids) =>
      _apiClient.setGlobalFrameGrids(grids);

  /// Get current video format
  Future<Map<String, dynamic>> getVideoFormat() => _apiClient.getVideoFormat();

  /// Set video format (tries separate API first, falls back to combined API)
  Future<void> setVideoFormat(String name, String frameRate) async {
    // Try separate video format API first
    try {
      await _apiClient.setVideoFormat(name, frameRate);
      return;
    } catch (e) {
      // If it fails (e.g., "Not implemented"), try combined format API
    }

    // Fall back to combined format API - need to send full format object
    final currentFormat = await _apiClient.getSystemFormat();
    if (currentFormat.isEmpty) {
      throw ApiException('Cannot set video format: unable to get current format');
    }

    // Parse frame rate - remove 'p' suffix if present (e.g., "24p" -> "24")
    var cleanFrameRate = frameRate.replaceAll('p', '').replaceAll('i', '');

    // Update frame rate in current format
    currentFormat['frameRate'] = cleanFrameRate;

    // Send full format back to API
    await _apiClient.setSystemFormat(currentFormat);
  }

  /// Get current codec format
  Future<Map<String, dynamic>> getCodecFormat() => _apiClient.getCodecFormat();

  /// Set codec format (tries separate API first, falls back to combined API)
  Future<void> setCodecFormat(String codec, String container) async {
    // Try separate codec format API first
    try {
      await _apiClient.setCodecFormat(codec, container);
      return;
    } catch (e) {
      // If it fails (e.g., "Not implemented"), try combined format API
    }

    // Fall back to combined format API - need to send full format object
    // First get current format, then update codec and send back
    final currentFormat = await _apiClient.getSystemFormat();
    if (currentFormat.isEmpty) {
      throw ApiException('Cannot set codec: unable to get current format');
    }

    // Update codec in current format
    currentFormat['codec'] = codec;

    // Send full format back to API
    await _apiClient.setSystemFormat(currentFormat);
  }

  /// Get current system format (combined API)
  Future<Map<String, dynamic>> getSystemFormat() => _apiClient.getSystemFormat();

  /// Set system format (combined API)
  Future<void> setSystemFormat(Map<String, dynamic> format) =>
      _apiClient.setSystemFormat(format);

  /// Get supported formats (combined API)
  Future<List<Map<String, dynamic>>> getSupportedFormats() =>
      _apiClient.getSupportedFormats();

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
        final falseColorEnabled =
            await _safeCall(() => getFalseColorEnabled(name), false);
        final safeAreaEnabled =
            await _safeCall(() => getSafeAreaEnabled(name), false);
        final frameGridsEnabled =
            await _safeCall(() => getFrameGridsEnabled(name), false);

        displayStates[name] = DisplayState(
          name: name,
          focusAssist: focusAssist,
          zebraEnabled: zebraEnabled,
          frameGuides: frameGuides,
          cleanFeedEnabled: cleanFeedEnabled,
          displayLutEnabled: displayLutEnabled,
          falseColorEnabled: falseColorEnabled,
          safeAreaEnabled: safeAreaEnabled,
          frameGridsEnabled: frameGridsEnabled,
        );
      } catch (e) {
        // Display not accessible
      }
    }

    // Fetch camera-wide settings
    final programFeedEnabled =
        await _safeCall(() => getProgramFeedEnabled(), false);

    // Try separate video/codec format APIs first, fall back to combined API
    var videoFormatData =
        await _safeCall(() => getVideoFormat(), <String, dynamic>{});
    var codecFormatData =
        await _safeCall(() => getCodecFormat(), <String, dynamic>{});

    // If separate APIs didn't work, try combined format API
    if (videoFormatData.isEmpty && codecFormatData.isEmpty) {
      final systemFormat = await _safeCall(() => getSystemFormat(), <String, dynamic>{});
      if (systemFormat.isNotEmpty) {
        videoFormatData = systemFormat;
        codecFormatData = systemFormat;
      }
    }

    final currentVideoFormat = _formatVideoFormatString(videoFormatData);
    final currentCodecFormat = _parseCodecFormat(codecFormatData);

    // Fetch frame guide ratio (camera-wide setting)
    final frameGuideRatioStr =
        await _safeCall(() => getFrameGuideRatio(), '16:9');
    final frameGuideRatio = FrameGuideRatio.values.cast<FrameGuideRatio?>().firstWhere(
      (r) => r?.label == frameGuideRatioStr,
      orElse: () => FrameGuideRatio.ratio16x9,
    )!;

    // Fetch global focus assist settings (camera-wide)
    final globalFocusAssist =
        await _safeCall(() => getGlobalFocusAssist(), const FocusAssistState());

    // Fetch color bars enabled (camera-wide)
    final colorBarsEnabled =
        await _safeCall(() => getColorBarsEnabled(), false);

    // Fetch safe area percent (camera-wide)
    final safeAreaPercent =
        await _safeCall(() => getSafeAreaPercent(), 80);

    // Fetch active frame grids (camera-wide)
    final frameGridStrings =
        await _safeCall(() => getGlobalFrameGrids(), <String>[]);
    final activeFrameGrids = frameGridStrings
        .map((g) => FrameGridType.fromString(g))
        .toList();

    return MonitoringState(
      availableDisplays: displays,
      selectedDisplay: displays.isNotEmpty ? displays.first : null,
      displays: displayStates,
      programFeedEnabled: programFeedEnabled,
      currentVideoFormat: currentVideoFormat,
      currentCodecFormat: currentCodecFormat,
      currentFrameGuideRatio: frameGuideRatio,
      globalFocusAssistSettings: globalFocusAssist,
      colorBarsEnabled: colorBarsEnabled,
      safeAreaPercent: safeAreaPercent,
      activeFrameGrids: activeFrameGrids,
    );
  }

  /// Format video format data into a display string
  /// Handles various response formats from the camera API
  String? _formatVideoFormatString(Map<String, dynamic> data) {
    if (data.isEmpty) return null;

    // Try standard format: {"name": "1920x1080", "frameRate": "23.98p"}
    final name = data['name'] as String?;
    final frameRate = data['frameRate'] as String?;
    if (name != null) {
      if (frameRate != null) {
        return '$name $frameRate';
      }
      return name;
    }

    // Try combined format API: {"recordResolution": {"width": 3840, "height": 2160}, "frameRate": "24"}
    final recordResolution = data['recordResolution'] as Map<String, dynamic>?;
    if (recordResolution != null) {
      final width = recordResolution['width'] as int?;
      final height = recordResolution['height'] as int?;
      final resDesc = data['resolutionDescriptor'] as Map<String, dynamic>?;
      final description = resDesc?['description'] as String?;

      if (width != null && height != null) {
        final resolutionStr = description ?? '${width}x$height';
        if (frameRate != null) {
          return '$resolutionStr ${frameRate}p';
        }
        return resolutionStr;
      }
    }

    // Try alternative format with resolution and fps fields
    final resolution = data['resolution'] as String?;
    final fps = data['fps'] as String?;
    if (resolution != null) {
      if (fps != null) {
        return '$resolution $fps';
      }
      return resolution;
    }

    // Try format with width/height
    final width = data['width'] as int?;
    final height = data['height'] as int?;
    if (width != null && height != null) {
      final resolutionStr = '${width}x$height';
      if (frameRate != null) {
        return '$resolutionStr $frameRate';
      }
      return resolutionStr;
    }

    // Fallback: try to build from any available fields
    final displayName = data['displayName'] as String?;
    if (displayName != null) return displayName;

    return null;
  }

  /// Parse codec format from API response
  /// Handles both separate API ({"codec": "ProRes:HQ", "container": "MOV"})
  /// and combined API ({"codec": "BRaw:8_1", ...})
  CodecFormat? _parseCodecFormat(Map<String, dynamic> data) {
    if (data.isEmpty) return null;

    final codec = data['codec'] as String?;
    if (codec == null || codec.isEmpty) return null;

    // Separate API has container field, combined API doesn't
    final container = data['container'] as String? ?? '';

    return CodecFormat(codec: codec, container: container);
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

  /// Get color properties (hue and saturation) from combined endpoint
  Future<Map<String, double>> getColorProperties() =>
      _apiClient.getColorProperties();

  /// Set color properties (hue and/or saturation)
  Future<void> setColorProperties({double? hue, double? saturation}) =>
      _apiClient.setColorProperties(hue: hue, saturation: saturation);

  /// Set color properties with debouncing
  void setColorPropertiesDebounced({double? hue, double? saturation}) {
    _colorDebounce(() => _apiClient.setColorProperties(hue: hue, saturation: saturation));
  }

  /// Get color offset
  Future<ColorWheelValues> getColorOffset() => _apiClient.getColorOffset();

  /// Set color offset
  Future<void> setColorOffset(ColorWheelValues values) =>
      _apiClient.setColorOffset(values);

  /// Set color offset with debouncing
  void setColorOffsetDebounced(ColorWheelValues values) {
    _colorDebounce(() => _apiClient.setColorOffset(values));
  }

  /// Get contrast with pivot
  Future<Map<String, dynamic>> getColorContrastWithPivot() =>
      _apiClient.getColorContrastWithPivot();

  /// Set contrast with pivot
  Future<void> setColorContrastWithPivot(double adjust, double pivot) =>
      _apiClient.setColorContrastWithPivot(adjust, pivot);

  /// Set contrast with pivot (debounced)
  void setColorContrastWithPivotDebounced(double adjust, double pivot) {
    _colorDebounce(() => _apiClient.setColorContrastWithPivot(adjust, pivot));
  }

  /// Get luma contribution
  Future<double> getColorLumaContribution() =>
      _apiClient.getColorLumaContribution();

  /// Set luma contribution
  Future<void> setColorLumaContribution(double value) =>
      _apiClient.setColorLumaContribution(value);

  /// Set luma contribution with debouncing
  void setColorLumaContributionDebounced(double value) {
    _colorDebounce(() => _apiClient.setColorLumaContribution(value));
  }

  /// Fetch initial color correction state
  Future<ColorCorrectionState> fetchColorCorrectionState() async {
    // Fetch color wheels
    final lift = await _safeCall(() => getColorLift(), const ColorWheelValues());
    final gamma = await _safeCall(() => getColorGamma(), const ColorWheelValues());
    final gain = await _safeCall(() => getColorGain(), ColorWheelValues.gainDefault);
    final offset = await _safeCall(() => getColorOffset(), const ColorWheelValues());

    // Fetch combined hue/saturation from /colorCorrection/color
    final colorProps = await _safeCall(
        () => getColorProperties(), {'hue': 0.0, 'saturation': 1.0});
    final hue = colorProps['hue'] ?? 0.0;
    final saturation = colorProps['saturation'] ?? 1.0;

    // Fetch contrast with pivot from /colorCorrection/contrast
    final contrastData = await _safeCall(
        () => getColorContrastWithPivot(), <String, dynamic>{});
    // API returns 'adjust' for contrast value, 'pivot' for pivot point
    final contrast = (contrastData['adjust'] as num?)?.toDouble() ?? 1.0;
    final contrastPivot = (contrastData['pivot'] as num?)?.toDouble() ?? 0.5;

    // Fetch luma contribution
    final lumaContribution = await _safeCall(() => getColorLumaContribution(), 1.0);

    return ColorCorrectionState(
      lift: lift,
      gamma: gamma,
      gain: gain,
      offset: offset,
      saturation: saturation,
      hue: hue,
      contrast: contrast,
      contrastPivot: contrastPivot,
      lumaContribution: lumaContribution,
    );
  }

  // ========== STATUS INDICATORS ==========

  /// Get power status
  Future<PowerState> getPowerStatus() async {
    final data = await _safeCall(() => _apiClient.getPowerStatus(), <String, dynamic>{});
    if (data.isEmpty) return const PowerState();
    return PowerState.fromJson(data);
  }

  /// Get tally status
  Future<TallyStatus> getTallyStatus() async {
    final data = await _safeCall(() => _apiClient.getTallyStatus(), <String, dynamic>{});
    final status = data['status'] as String?;
    return TallyStatus.fromString(status);
  }

  // ========== PRESETS ==========

  /// Get list of presets
  Future<List<String>> getPresets() => _apiClient.getPresets();

  /// Get active preset
  Future<String?> getActivePreset() => _apiClient.getActivePreset();

  /// Load/apply a preset
  Future<void> loadPreset(String name) => _apiClient.setActivePreset(name);

  /// Save current settings as a preset
  Future<void> savePreset(String name) => _apiClient.savePreset(name);

  /// Delete a preset
  Future<void> deletePreset(String name) => _apiClient.deletePreset(name);

  /// Fetch preset state
  /// Note: Strips .cset extension from preset names for cleaner display
  Future<PresetState> fetchPresetState() async {
    final presets = await _safeCall(() => getPresets(), <String>[]);
    final activePreset = await _safeCall(() => getActivePreset(), null);

    // Strip .cset extension for cleaner display
    final cleanPresets = presets.map((p) =>
        p.endsWith('.cset') ? p.substring(0, p.length - 5) : p).toList();
    final cleanActive = activePreset != null && activePreset.endsWith('.cset')
        ? activePreset.substring(0, activePreset.length - 5)
        : activePreset;

    return PresetState(
      availablePresets: cleanPresets,
      activePreset: cleanActive,
    );
  }

  // ========== SYSTEM INFO ==========

  /// Get system/product info (model name, etc.)
  Future<Map<String, dynamic>> getSystemInfo() => _apiClient.getSystemInfo();

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
    var formats = results[3] as List<Map<String, dynamic>>;
    var codecs = results[4] as List<Map<String, dynamic>>;

    // If separate format APIs returned nothing, try combined format API
    if (formats.isEmpty && codecs.isEmpty) {
      final combinedFormats = await _safeCall(() => getSupportedFormats(), <Map<String, dynamic>>[]);
      if (combinedFormats.isNotEmpty) {
        final parsed = _parseCombinedFormats(combinedFormats);
        formats = parsed['formats'] as List<Map<String, dynamic>>;
        codecs = parsed['codecs'] as List<Map<String, dynamic>>;
      }
    }

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

  /// Parse combined format API response into separate video formats and codecs
  /// Input: [{ "codecs": [...], "frameRates": [...], "recordResolution": {...} }, ...]
  /// Output: { "formats": [...], "codecs": [...] }
  Map<String, List<Map<String, dynamic>>> _parseCombinedFormats(
    List<Map<String, dynamic>> combinedFormats,
  ) {
    final videoFormats = <Map<String, dynamic>>[];
    final codecFormats = <Map<String, dynamic>>[];
    final seenCodecs = <String>{};

    for (final group in combinedFormats) {
      final codecsList = group['codecs'] as List<dynamic>? ?? [];
      final frameRates = group['frameRates'] as List<dynamic>? ?? [];
      final resolution = group['recordResolution'] as Map<String, dynamic>?;
      final resDesc = group['resolutionDescriptor'] as Map<String, dynamic>?;

      final width = resolution?['width'] as int?;
      final height = resolution?['height'] as int?;
      final description = resDesc?['description'] as String?;
      final resolutionName = description ?? (width != null && height != null ? '${width}x$height' : '');

      // Create video formats for each resolution + frame rate combination
      for (final fr in frameRates) {
        final frameRate = fr.toString();
        videoFormats.add({
          'name': resolutionName,
          'frameRate': '${frameRate}p',
          'width': width,
          'height': height,
        });
      }

      // Collect unique codecs
      for (final codec in codecsList) {
        final codecStr = codec.toString();
        if (!seenCodecs.contains(codecStr)) {
          seenCodecs.add(codecStr);
          codecFormats.add({
            'codec': codecStr,
            'container': '', // Combined API doesn't specify container
          });
        }
      }
    }

    return {
      'formats': videoFormats,
      'codecs': codecFormats,
    };
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
