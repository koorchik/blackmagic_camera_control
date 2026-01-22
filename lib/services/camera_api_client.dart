import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/camera_state.dart';

/// HTTP REST API client for Blackmagic Camera
class CameraApiClient {
  CameraApiClient({
    required this.host,
    this.port = ApiEndpoints.defaultPort,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String host;
  final int port;
  final http.Client _httpClient;

  String get _baseUrl => 'http://$host:$port';

  /// Test connection to the camera
  Future<bool> testConnection() async {
    try {
      final response = await _httpClient
          .get(Uri.parse('$_baseUrl${ApiEndpoints.lensFocus}'))
          .timeout(Durations.connectionTimeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ========== LENS CONTROL ==========

  /// Get current focus position (0.0-1.0)
  Future<double> getFocus() async {
    final data = await _get(ApiEndpoints.lensFocus);
    return (data['normalised'] as num?)?.toDouble() ?? 0.5;
  }

  /// Set focus position (0.0 = near, 1.0 = far)
  Future<void> setFocus(double value) async {
    await _put(ApiEndpoints.lensFocus, {'normalised': value.clamp(0.0, 1.0)});
  }

  /// Trigger autofocus at a specific position in frame
  /// [x] and [y] are normalized coordinates (0.0-1.0), defaulting to center
  Future<void> triggerAutofocus({double x = 0.5, double y = 0.5}) async {
    await _put(ApiEndpoints.lensDoAutoFocus, {
      'position': {'x': x.clamp(0.0, 1.0), 'y': y.clamp(0.0, 1.0)},
    });
  }

  /// Get current iris value
  Future<double> getIris() async {
    final data = await _get(ApiEndpoints.lensIris);
    return (data['normalised'] as num?)?.toDouble() ?? 0.0;
  }

  /// Set iris (normalized 0.0-1.0, where 0.0 is wide open)
  Future<void> setIris(double value) async {
    await _put(ApiEndpoints.lensIris, {'normalised': value.clamp(0.0, 1.0)});
  }

  /// Get current zoom position
  Future<double> getZoom() async {
    final data = await _get(ApiEndpoints.lensZoom);
    return (data['normalised'] as num?)?.toDouble() ?? 0.0;
  }

  /// Set zoom (normalized 0.0-1.0)
  Future<void> setZoom(double value) async {
    await _put(ApiEndpoints.lensZoom, {'normalised': value.clamp(0.0, 1.0)});
  }

  /// Get optical image stabilization state
  Future<bool> getOIS() async {
    try {
      final data = await _get(ApiEndpoints.lensOIS);
      return data['enabled'] as bool? ?? false;
    } on FeatureNotSupportedException {
      return false;
    }
  }

  /// Set optical image stabilization enabled
  Future<void> setOIS(bool enabled) async {
    await _put(ApiEndpoints.lensOIS, {'enabled': enabled});
  }

  // ========== VIDEO SETTINGS ==========

  /// Get current ISO
  Future<int> getIso() async {
    final data = await _get(ApiEndpoints.videoIso);
    return data['iso'] as int? ?? 800;
  }

  /// Set ISO value
  Future<void> setIso(int value) async {
    await _put(ApiEndpoints.videoIso, {'iso': value});
  }

  /// Get shutter settings
  Future<Map<String, dynamic>> getShutter() async {
    return await _get(ApiEndpoints.videoShutter);
  }

  /// Set shutter speed (as denominator, e.g., 50 for 1/50)
  Future<void> setShutterSpeed(int value) async {
    await _put(ApiEndpoints.videoShutter, {'shutterSpeed': value});
  }

  /// Get auto exposure mode
  Future<Map<String, dynamic>> getAutoExposure() async {
    return await _get(ApiEndpoints.videoAutoExposure);
  }

  /// Set auto exposure mode ("Off", "Continuous", "OneShot")
  Future<void> setAutoExposureMode(String mode, {String type = 'Shutter'}) async {
    await _put(ApiEndpoints.videoAutoExposure, {'mode': mode, 'type': type});
  }

  /// Get white balance in Kelvin
  Future<int> getWhiteBalance() async {
    final data = await _get(ApiEndpoints.videoWhiteBalance);
    return data['whiteBalance'] as int? ?? 5600;
  }

  /// Set white balance in Kelvin
  Future<void> setWhiteBalance(int kelvin) async {
    await _put(ApiEndpoints.videoWhiteBalance, {'whiteBalance': kelvin});
  }

  /// Get white balance tint
  Future<int> getWhiteBalanceTint() async {
    final data = await _get(ApiEndpoints.videoWhiteBalanceTint);
    return data['whiteBalanceTint'] as int? ?? 0;
  }

  /// Set white balance tint (-50 to +50)
  Future<void> setWhiteBalanceTint(int tint) async {
    await _put(ApiEndpoints.videoWhiteBalanceTint, {'whiteBalanceTint': tint.clamp(-50, 50)});
  }

  /// Get ND filter value
  Future<Map<String, dynamic>> getNDFilter() async {
    return await _get(ApiEndpoints.videoNDFilter);
  }

  /// Set ND filter stop value
  Future<void> setNDFilter(double stop) async {
    await _put(ApiEndpoints.videoNDFilter, {'stop': stop});
  }

  /// Get ND filter display mode
  Future<String> getNDFilterDisplayMode() async {
    final data = await _get(ApiEndpoints.videoNDFilterDisplayMode);
    return data['displayMode'] as String? ?? 'Stop';
  }

  /// Set ND filter display mode
  Future<void> setNDFilterDisplayMode(String mode) async {
    await _put(ApiEndpoints.videoNDFilterDisplayMode, {'displayMode': mode});
  }

  /// Get shutter measurement mode (ShutterSpeed or ShutterAngle)
  Future<String> getShutterMeasurement() async {
    final data = await _get(ApiEndpoints.videoShutterMeasurement);
    return data['measurement'] as String? ?? 'ShutterSpeed';
  }

  /// Set shutter measurement mode
  Future<void> setShutterMeasurement(String measurement) async {
    await _put(ApiEndpoints.videoShutterMeasurement, {'measurement': measurement});
  }

  /// Set shutter angle
  Future<void> setShutterAngle(double angle) async {
    await _put(ApiEndpoints.videoShutter, {'shutterAngle': angle});
  }

  /// Get detail sharpening state
  Future<bool> getDetailSharpening() async {
    try {
      final data = await _get(ApiEndpoints.videoDetailSharpening);
      return data['enabled'] as bool? ?? false;
    } on FeatureNotSupportedException {
      return false;
    }
  }

  /// Set detail sharpening enabled
  Future<void> setDetailSharpening(bool enabled) async {
    await _put(ApiEndpoints.videoDetailSharpening, {'enabled': enabled});
  }

  /// Get detail sharpening level
  Future<String> getDetailSharpeningLevel() async {
    try {
      final data = await _get(ApiEndpoints.videoDetailSharpeningLevel);
      return data['level'] as String? ?? 'Medium';
    } on FeatureNotSupportedException {
      return 'Medium';
    }
  }

  /// Set detail sharpening level ('Low', 'Medium', 'High')
  Future<void> setDetailSharpeningLevel(String level) async {
    await _put(ApiEndpoints.videoDetailSharpeningLevel, {'level': level});
  }

  // ========== TRANSPORT CONTROL ==========

  /// Get recording state
  Future<bool> getRecordingState() async {
    final data = await _get(ApiEndpoints.transportRecord);
    return data['recording'] as bool? ?? false;
  }

  /// Start recording
  Future<void> startRecording() async {
    await _put(ApiEndpoints.transportRecord, {'recording': true});
  }

  /// Stop recording
  Future<void> stopRecording() async {
    await _put(ApiEndpoints.transportRecord, {'recording': false});
  }

  /// Toggle recording state
  Future<void> toggleRecording() async {
    final isRecording = await getRecordingState();
    if (isRecording) {
      await stopRecording();
    } else {
      await startRecording();
    }
  }

  /// Get current timecode
  Future<String> getTimecode() async {
    final data = await _get(ApiEndpoints.transportTimecode);
    final timecodeInt = data['timecode'] as int? ?? 0;
    return _formatTimecode(timecodeInt);
  }

  /// Convert BCD timecode integer to HH:MM:SS:FF string
  String _formatTimecode(int bcd) {
    final frames = bcd & 0xFF;
    final seconds = (bcd >> 8) & 0xFF;
    final minutes = (bcd >> 16) & 0xFF;
    final hours = (bcd >> 24) & 0xFF;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}:'
        '${frames.toString().padLeft(2, '0')}';
  }

  // ========== SLATE/METADATA CONTROL ==========

  /// Get slate/metadata for next clip
  Future<SlateState> getSlate() async {
    final data = await _get(ApiEndpoints.slateNextClip);
    return SlateState.fromJson(data);
  }

  /// Set slate/metadata for next clip
  Future<void> setSlate(SlateState slate) async {
    await _put(ApiEndpoints.slateNextClip, slate.toJson());
  }

  /// Update specific slate fields
  Future<void> updateSlate(Map<String, dynamic> fields) async {
    await _put(ApiEndpoints.slateNextClip, fields);
  }

  // ========== AUDIO CONTROL ==========

  /// Get total number of audio channels available
  Future<int> getAudioChannelCount() async {
    try {
      final data = await _get(ApiEndpoints.audioChannels);
      return data['channels'] as int? ?? 2;
    } on FeatureNotSupportedException {
      return 2; // Default fallback
    }
  }

  /// Get channel availability status
  Future<bool> getAudioChannelAvailable(int channelIndex) async {
    try {
      final data = await _get(ApiEndpoints.audioChannelAvailable(channelIndex));
      return data['available'] as bool? ?? true;
    } on FeatureNotSupportedException {
      return true; // Assume available if endpoint not supported
    }
  }

  /// Get audio level for a channel (meter reading)
  Future<double> getAudioLevel(int channelIndex) async {
    final data = await _get(ApiEndpoints.audioChannelLevel(channelIndex));
    return (data['normalised'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get full audio level data including gain settings for a channel
  /// Returns a map with: normalised (meter), gain (dB), gainNormalised (0-1)
  Future<Map<String, dynamic>> getAudioLevelFull(int channelIndex) async {
    final data = await _get(ApiEndpoints.audioChannelLevel(channelIndex));
    return data;
  }

  /// Get audio input type for a channel
  Future<AudioInputType> getAudioInput(int channelIndex) async {
    final data = await _get(ApiEndpoints.audioChannelInput(channelIndex));
    final inputStr = data['input'] as String?;
    return AudioInputType.fromString(inputStr);
  }

  /// Set audio input type for a channel
  Future<void> setAudioInput(int channelIndex, AudioInputType type) async {
    await _put(ApiEndpoints.audioChannelInput(channelIndex), {
      'input': type.code,
    });
  }

  /// Get phantom power state for a channel
  Future<bool> getPhantomPower(int channelIndex) async {
    final data = await _get(ApiEndpoints.audioChannelPhantom(channelIndex));
    return data['enabled'] as bool? ?? false;
  }

  /// Set phantom power state for a channel
  Future<void> setPhantomPower(int channelIndex, bool enabled) async {
    await _put(ApiEndpoints.audioChannelPhantom(channelIndex), {
      'enabled': enabled,
    });
  }

  /// Get supported inputs for a channel
  /// Returns a list of supported input info objects with 'input' (string) and 'available' (bool)
  Future<List<Map<String, dynamic>>> getSupportedInputs(int channelIndex) async {
    try {
      final data = await _getArray(ApiEndpoints.audioChannelSupportedInputs(channelIndex));
      return data.map((e) => e as Map<String, dynamic>).toList();
    } on FeatureNotSupportedException {
      return [];
    }
  }

  /// Set audio level/gain for a channel
  Future<void> setAudioLevel(int channelIndex, {double? gain, double? normalized}) async {
    final body = <String, dynamic>{};
    if (gain != null) body['gain'] = gain;
    if (normalized != null) body['normalised'] = normalized.clamp(0.0, 1.0);
    if (body.isEmpty) return;
    await _put(ApiEndpoints.audioChannelLevel(channelIndex), body);
  }

  /// Get low cut filter state for a channel
  Future<bool> getLowCutFilter(int channelIndex) async {
    try {
      final data = await _get(ApiEndpoints.audioChannelLowCutFilter(channelIndex));
      return data['enabled'] as bool? ?? false;
    } on FeatureNotSupportedException {
      return false;
    }
  }

  /// Set low cut filter state for a channel
  Future<void> setLowCutFilter(int channelIndex, bool enabled) async {
    await _put(ApiEndpoints.audioChannelLowCutFilter(channelIndex), {
      'enabled': enabled,
    });
  }

  /// Get padding state for a channel
  Future<bool> getPadding(int channelIndex) async {
    try {
      final data = await _get(ApiEndpoints.audioChannelPadding(channelIndex));
      return data['enabled'] as bool? ?? false;
    } on FeatureNotSupportedException {
      return false;
    }
  }

  /// Set padding state for a channel
  Future<void> setPadding(int channelIndex, bool enabled) async {
    await _put(ApiEndpoints.audioChannelPadding(channelIndex), {
      'enabled': enabled,
    });
  }

  /// Get input description/capabilities for a channel
  /// Returns min/max gain, phantom power support, padding support
  Future<Map<String, dynamic>> getInputDescription(int channelIndex) async {
    try {
      return await _get(ApiEndpoints.audioChannelInputDescription(channelIndex));
    } on FeatureNotSupportedException {
      return {};
    }
  }

  // ========== MEDIA MANAGEMENT ==========

  /// Get media working set (active recording slot)
  Future<int> getMediaWorkingSet() async {
    final data = await _get(ApiEndpoints.mediaWorkingSet);
    return data['workingsetIndex'] as int? ?? 0;
  }

  /// Set media working set (active recording slot)
  Future<void> setMediaWorkingSet(int index) async {
    await _put(ApiEndpoints.mediaWorkingSet, {'workingsetIndex': index});
  }

  /// Get all media devices
  Future<List<MediaDevice>> getMediaDevices() async {
    final data = await _get(ApiEndpoints.mediaDevices);
    final devicesJson = data['devices'] as List<dynamic>? ?? [];
    return devicesJson
        .map((d) => MediaDevice.fromJson(d as Map<String, dynamic>))
        .toList();
  }

  /// Get a specific media device
  Future<MediaDevice> getMediaDevice(String deviceName) async {
    final data = await _get(ApiEndpoints.mediaDevice(deviceName));
    return MediaDevice.fromJson(data);
  }

  /// Start format operation - returns format key for confirmation
  Future<String> getFormatKey(String deviceName) async {
    final data = await _get(ApiEndpoints.mediaFormat(deviceName));
    return data['key'] as String? ?? '';
  }

  /// Confirm format operation with key and filesystem type
  Future<void> confirmFormat(
    String deviceName,
    String key,
    FilesystemType filesystem,
  ) async {
    await _put(ApiEndpoints.mediaFormat(deviceName), {
      'key': key,
      'filesystem': filesystem.code,
    });
  }

  // ========== MONITORING CONTROL ==========

  /// Get available displays
  Future<List<String>> getAvailableDisplays() async {
    final response = await _httpClient
        .get(Uri.parse('$_baseUrl${ApiEndpoints.monitoringDisplays}'))
        .timeout(Durations.connectionTimeout);

    if (response.statusCode == 200) {
      final body = response.body;
      final decoded = jsonDecode(body);

      // Handle different possible response formats:
      // 1. Direct array: ["HDMI", "LCD"]
      if (decoded is List) {
        return decoded.cast<String>();
      }

      // 2. Object with 'displays' key: {"displays": ["HDMI", "LCD"]}
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('displays')) {
          final displays = decoded['displays'] as List<dynamic>? ?? [];
          return displays.cast<String>();
        }
        // 3. Object with display names as keys: {"HDMI": {...}, "LCD": {...}}
        // Filter out non-display keys if present
        final displayNames = decoded.keys
            .where((key) => !key.startsWith('_'))
            .toList();
        if (displayNames.isNotEmpty) {
          return displayNames;
        }
      }

      return [];
    } else if (response.statusCode == 404) {
      throw FeatureNotSupportedException(ApiEndpoints.monitoringDisplays);
    } else {
      throw ApiException('GET ${ApiEndpoints.monitoringDisplays} failed: ${response.statusCode}');
    }
  }

  /// Get focus assist settings for a display
  Future<FocusAssistState> getFocusAssist(String displayName) async {
    final data = await _get(ApiEndpoints.focusAssist(displayName));
    return FocusAssistState.fromJson(data);
  }

  /// Set focus assist enabled for a display (per-display toggle)
  Future<void> setFocusAssistEnabled(String displayName, bool enabled) async {
    await _put(ApiEndpoints.focusAssist(displayName), {'enabled': enabled});
  }

  /// Get global focus assist settings (camera-wide)
  Future<FocusAssistState> getGlobalFocusAssist() async {
    final data = await _get(ApiEndpoints.globalFocusAssist);
    return FocusAssistState.fromJson(data);
  }

  /// Set global focus assist settings (camera-wide: mode, color, intensity)
  /// Note: Some camera models (e.g., Micro Studio Camera 4K G2) don't support
  /// changing these settings via API - they return 422 Unprocessable Entity.
  Future<void> setGlobalFocusAssist(FocusAssistState state) async {
    final body = state.toSettingsJson();
    final response = await _httpClient
        .put(
          Uri.parse('$_baseUrl${ApiEndpoints.globalFocusAssist}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(Durations.connectionTimeout);

    if (response.statusCode == 422) {
      throw FeatureNotSupportedException(
          '${ApiEndpoints.globalFocusAssist} (focus assist settings cannot be changed via API on this camera)');
    }
    if (response.statusCode != 200 && response.statusCode != 204) {
      if (response.statusCode == 404) {
        throw FeatureNotSupportedException(ApiEndpoints.globalFocusAssist);
      }
      throw ApiException('PUT ${ApiEndpoints.globalFocusAssist} failed: ${response.statusCode}');
    }
  }

  /// Get zebra settings for a display
  Future<bool> getZebraEnabled(String displayName) async {
    final data = await _get(ApiEndpoints.zebra(displayName));
    return data['enabled'] as bool? ?? false;
  }

  /// Set zebra enabled for a display
  Future<void> setZebraEnabled(String displayName, bool enabled) async {
    await _put(ApiEndpoints.zebra(displayName), {'enabled': enabled});
  }

  /// Get frame guides settings for a display
  Future<FrameGuidesState> getFrameGuides(String displayName) async {
    final data = await _get(ApiEndpoints.frameGuides(displayName));
    return FrameGuidesState.fromJson(data);
  }

  /// Set frame guides settings for a display
  Future<void> setFrameGuides(
    String displayName,
    FrameGuidesState state,
  ) async {
    await _put(ApiEndpoints.frameGuides(displayName), state.toJson());
  }

  /// Get frame guide ratio (camera-wide setting)
  Future<String> getFrameGuideRatio() async {
    final data = await _get(ApiEndpoints.frameGuideRatio);
    return data['ratio'] as String? ?? '16:9';
  }

  /// Set frame guide ratio (camera-wide setting)
  Future<void> setFrameGuideRatio(String ratio) async {
    await _put(ApiEndpoints.frameGuideRatio, {'ratio': ratio});
  }

  /// Get clean feed enabled for a display
  Future<bool> getCleanFeedEnabled(String displayName) async {
    final data = await _get(ApiEndpoints.cleanFeed(displayName));
    return data['enabled'] as bool? ?? false;
  }

  /// Set clean feed enabled for a display
  Future<void> setCleanFeedEnabled(String displayName, bool enabled) async {
    await _put(ApiEndpoints.cleanFeed(displayName), {'enabled': enabled});
  }

  /// Get display LUT enabled for a display
  Future<bool> getDisplayLutEnabled(String displayName) async {
    final data = await _get(ApiEndpoints.displayLut(displayName));
    return data['enabled'] as bool? ?? false;
  }

  /// Set display LUT enabled for a display
  Future<void> setDisplayLutEnabled(String displayName, bool enabled) async {
    await _put(ApiEndpoints.displayLut(displayName), {'enabled': enabled});
  }

  /// Get program feed display enabled
  Future<bool> getProgramFeedEnabled() async {
    final data = await _get(ApiEndpoints.programFeedDisplay);
    return data['enabled'] as bool? ?? false;
  }

  /// Set program feed display enabled
  Future<void> setProgramFeedEnabled(bool enabled) async {
    await _put(ApiEndpoints.programFeedDisplay, {'enabled': enabled});
  }

  /// Get false color enabled for a display
  Future<bool> getFalseColorEnabled(String displayName) async {
    try {
      final data = await _get(ApiEndpoints.falseColor(displayName));
      return data['enabled'] as bool? ?? false;
    } on FeatureNotSupportedException {
      return false;
    }
  }

  /// Set false color enabled for a display
  Future<void> setFalseColorEnabled(String displayName, bool enabled) async {
    await _put(ApiEndpoints.falseColor(displayName), {'enabled': enabled});
  }

  /// Get safe area enabled for a display
  Future<bool> getSafeAreaEnabled(String displayName) async {
    try {
      final data = await _get(ApiEndpoints.safeArea(displayName));
      return data['enabled'] as bool? ?? false;
    } on FeatureNotSupportedException {
      return false;
    }
  }

  /// Set safe area enabled for a display
  Future<void> setSafeAreaEnabled(String displayName, bool enabled) async {
    await _put(ApiEndpoints.safeArea(displayName), {'enabled': enabled});
  }

  /// Get safe area percentage (camera-wide)
  Future<int> getSafeAreaPercent() async {
    try {
      final data = await _get(ApiEndpoints.globalSafeAreaPercent);
      return data['percent'] as int? ?? 80;
    } on FeatureNotSupportedException {
      return 80;
    }
  }

  /// Set safe area percentage (camera-wide)
  Future<void> setSafeAreaPercent(int percent) async {
    await _put(ApiEndpoints.globalSafeAreaPercent, {'percent': percent.clamp(50, 100)});
  }

  /// Get frame grids enabled for a display
  Future<bool> getFrameGridsEnabled(String displayName) async {
    try {
      final data = await _get(ApiEndpoints.frameGrids(displayName));
      return data['enabled'] as bool? ?? false;
    } on FeatureNotSupportedException {
      return false;
    }
  }

  /// Set frame grids enabled for a display
  Future<void> setFrameGridsEnabled(String displayName, bool enabled) async {
    await _put(ApiEndpoints.frameGrids(displayName), {'enabled': enabled});
  }

  /// Get global frame grids settings (camera-wide)
  Future<List<String>> getGlobalFrameGrids() async {
    try {
      final data = await _get(ApiEndpoints.globalFrameGrids);
      final grids = data['frameGrids'] as List<dynamic>?;
      return grids?.cast<String>() ?? [];
    } on FeatureNotSupportedException {
      return [];
    }
  }

  /// Set global frame grids settings (camera-wide)
  Future<void> setGlobalFrameGrids(List<String> grids) async {
    await _put(ApiEndpoints.globalFrameGrids, {'frameGrids': grids});
  }

  /// Get current video format
  Future<Map<String, dynamic>> getVideoFormat() async {
    return await _get(ApiEndpoints.videoFormat);
  }

  /// Set video format
  Future<void> setVideoFormat(String name, String frameRate) async {
    await _put(ApiEndpoints.videoFormat, {
      'name': name,
      'frameRate': frameRate,
    });
  }

  // ========== COLOR CORRECTION CONTROL ==========

  /// Get color lift (shadows)
  Future<ColorWheelValues> getColorLift() async {
    final data = await _get(ApiEndpoints.colorLift);
    return ColorWheelValues.fromJson(data);
  }

  /// Set color lift (shadows)
  Future<void> setColorLift(ColorWheelValues values) async {
    await _put(ApiEndpoints.colorLift, values.toJson());
  }

  /// Get color gamma (midtones)
  Future<ColorWheelValues> getColorGamma() async {
    final data = await _get(ApiEndpoints.colorGamma);
    return ColorWheelValues.fromJson(data);
  }

  /// Set color gamma (midtones)
  Future<void> setColorGamma(ColorWheelValues values) async {
    await _put(ApiEndpoints.colorGamma, values.toJson());
  }

  /// Get color gain (highlights)
  Future<ColorWheelValues> getColorGain() async {
    final data = await _get(ApiEndpoints.colorGain);
    return ColorWheelValues.fromJson(data);
  }

  /// Set color gain (highlights)
  Future<void> setColorGain(ColorWheelValues values) async {
    await _put(ApiEndpoints.colorGain, values.toJson());
  }

  /// Get color properties (hue and saturation) from /colorCorrection/color
  /// Returns: {hue: double, saturation: double}
  Future<Map<String, double>> getColorProperties() async {
    try {
      final data = await _get(ApiEndpoints.colorColor);
      return {
        'hue': (data['hue'] as num?)?.toDouble() ?? 0.0,
        'saturation': (data['saturation'] as num?)?.toDouble() ?? 1.0,
      };
    } on FeatureNotSupportedException {
      return {'hue': 0.0, 'saturation': 1.0};
    }
  }

  /// Set color properties (hue and/or saturation) via /colorCorrection/color
  Future<void> setColorProperties({double? hue, double? saturation}) async {
    final body = <String, dynamic>{};
    if (hue != null) body['hue'] = hue;
    if (saturation != null) body['saturation'] = saturation;
    if (body.isEmpty) return;
    await _put(ApiEndpoints.colorColor, body);
  }

  /// Get color offset
  Future<ColorWheelValues> getColorOffset() async {
    try {
      final data = await _get(ApiEndpoints.colorOffset);
      return ColorWheelValues.fromJson(data);
    } on FeatureNotSupportedException {
      return const ColorWheelValues();
    }
  }

  /// Set color offset
  Future<void> setColorOffset(ColorWheelValues values) async {
    await _put(ApiEndpoints.colorOffset, values.toJson());
  }

  /// Get contrast with pivot
  Future<Map<String, dynamic>> getColorContrastWithPivot() async {
    final data = await _get(ApiEndpoints.colorContrast);
    return data;
  }

  /// Set contrast with pivot
  Future<void> setColorContrastWithPivot(double adjust, double pivot) async {
    await _put(ApiEndpoints.colorContrast, {'adjust': adjust, 'pivot': pivot});
  }

  /// Get luma contribution
  Future<double> getColorLumaContribution() async {
    try {
      final data = await _get(ApiEndpoints.colorLumaContribution);
      return (data['lumaContribution'] as num?)?.toDouble() ?? 1.0;
    } on FeatureNotSupportedException {
      return 1.0;
    }
  }

  /// Set luma contribution
  Future<void> setColorLumaContribution(double value) async {
    await _put(ApiEndpoints.colorLumaContribution, {'lumaContribution': value});
  }

  // ========== CAMERA CONTROL ==========

  /// Get color bars status
  Future<bool> getColorBarsEnabled() async {
    try {
      final data = await _get(ApiEndpoints.cameraColorBars);
      return data['enabled'] as bool? ?? false;
    } on FeatureNotSupportedException {
      return false;
    }
  }

  /// Set color bars status
  Future<void> setColorBarsEnabled(bool enabled) async {
    await _put(ApiEndpoints.cameraColorBars, {'enabled': enabled});
  }

  /// Get power status
  Future<Map<String, dynamic>> getPowerStatus() async {
    try {
      return await _get(ApiEndpoints.cameraPower);
    } on FeatureNotSupportedException {
      return {};
    }
  }

  /// Get tally status
  Future<Map<String, dynamic>> getTallyStatus() async {
    try {
      return await _get(ApiEndpoints.cameraTallyStatus);
    } on FeatureNotSupportedException {
      return {};
    }
  }

  // ========== CODEC FORMAT ==========

  /// Get current codec format
  Future<Map<String, dynamic>> getCodecFormat() async {
    try {
      return await _get(ApiEndpoints.systemCodecFormat);
    } on FeatureNotSupportedException {
      return {};
    }
  }

  /// Set codec format
  Future<void> setCodecFormat(String codec, String container) async {
    await _put(ApiEndpoints.systemCodecFormat, {'codec': codec, 'container': container});
  }

  // ========== COMBINED FORMAT API (alternative endpoints) ==========

  /// Get current format (combined codec + video format)
  /// Used by cameras that don't support separate codecFormat/videoFormat endpoints
  Future<Map<String, dynamic>> getSystemFormat() async {
    try {
      return await _get(ApiEndpoints.systemFormat);
    } on FeatureNotSupportedException {
      return {};
    }
  }

  /// Set system format (combined codec + video format)
  Future<void> setSystemFormat(Map<String, dynamic> format) async {
    await _put(ApiEndpoints.systemFormat, format);
  }

  /// Get supported formats (combined codec + video format list)
  /// Returns format groups with codecs and frameRates arrays
  Future<List<Map<String, dynamic>>> getSupportedFormats() async {
    try {
      final data = await _get(ApiEndpoints.systemSupportedFormats);
      final formats = data['supportedFormats'] as List<dynamic>?;
      if (formats != null) {
        return formats.cast<Map<String, dynamic>>();
      }
      return [];
    } on FeatureNotSupportedException {
      return [];
    }
  }

  // ========== PRESETS ==========

  /// Get list of presets
  Future<List<String>> getPresets() async {
    try {
      final data = await _get(ApiEndpoints.presets);
      final presets = data['presets'] as List<dynamic>?;
      return presets?.cast<String>() ?? [];
    } on FeatureNotSupportedException {
      return [];
    }
  }

  /// Get active preset
  Future<String?> getActivePreset() async {
    try {
      final data = await _get(ApiEndpoints.presetsActive);
      return data['preset'] as String?;
    } on FeatureNotSupportedException {
      return null;
    }
  }

  /// Set active preset (apply a preset)
  Future<void> setActivePreset(String presetName) async {
    await _put(ApiEndpoints.presetsActive, {'preset': presetName});
  }

  /// Save current state as a preset
  Future<void> savePreset(String presetName) async {
    await _put(ApiEndpoints.preset(presetName), {});
  }

  /// Delete a preset
  Future<void> deletePreset(String presetName) async {
    final response = await _httpClient
        .delete(Uri.parse('$_baseUrl${ApiEndpoints.preset(presetName)}'))
        .timeout(Durations.connectionTimeout);

    if (response.statusCode != 200 && response.statusCode != 204) {
      if (response.statusCode == 404) {
        throw FeatureNotSupportedException(ApiEndpoints.preset(presetName));
      }
      throw ApiException('DELETE preset failed: ${response.statusCode}');
    }
  }

  // ========== SYSTEM INFO ==========

  /// Get system/product info (model name, etc.)
  Future<Map<String, dynamic>> getSystemInfo() async {
    try {
      return await _get(ApiEndpoints.systemProduct);
    } catch (e) {
      // Return empty map if endpoint not available
      return {};
    }
  }

  // ========== CAPABILITIES DISCOVERY ==========

  /// Get supported ISO values
  Future<List<int>> getSupportedISOs() async {
    try {
      final data = await _get(ApiEndpoints.supportedISOs);
      final isos = data['supportedISOs'] as List<dynamic>?;
      if (isos != null) {
        return isos.map((e) => e as int).toList()..sort();
      }
      return [];
    } on FeatureNotSupportedException {
      return [];
    }
  }

  /// Get supported shutter speeds
  Future<List<int>> getSupportedShutterSpeeds() async {
    try {
      final data = await _get(ApiEndpoints.supportedShutterSpeeds);
      final speeds = data['supportedShutterSpeeds'] as List<dynamic>?;
      if (speeds != null) {
        return speeds.map((e) => e as int).toList()..sort();
      }
      return [];
    } on FeatureNotSupportedException {
      return [];
    }
  }

  /// Get supported ND filter stops
  Future<List<double>> getSupportedNDFilters() async {
    try {
      final data = await _get(ApiEndpoints.supportedNDFilters);
      final filters = data['supportedNDFilters'] as List<dynamic>?;
      if (filters != null) {
        return filters.map((e) => (e as num).toDouble()).toList()..sort();
      }
      return [];
    } on FeatureNotSupportedException {
      return [];
    }
  }

  /// Get supported video formats (resolution + frame rate combinations)
  Future<List<Map<String, dynamic>>> getSupportedVideoFormats() async {
    try {
      final data = await _get(ApiEndpoints.supportedVideoFormats);
      // API returns formats under 'formats' key (per SystemControl.yaml spec)
      final formats = data['formats'] as List<dynamic>?;
      if (formats != null) {
        return formats.cast<Map<String, dynamic>>();
      }
      return [];
    } on FeatureNotSupportedException {
      return [];
    }
  }

  /// Get supported codec formats
  Future<List<Map<String, dynamic>>> getSupportedCodecFormats() async {
    try {
      final data = await _get(ApiEndpoints.supportedCodecFormats);
      // API returns codecs under 'codecs' key (per SystemControl.yaml spec)
      final codecs = data['codecs'] as List<dynamic>?;
      if (codecs != null) {
        return codecs.cast<Map<String, dynamic>>();
      }
      return [];
    } on FeatureNotSupportedException {
      return [];
    }
  }

  // ========== PRIVATE METHODS ==========

  Future<Map<String, dynamic>> _get(String endpoint) async {
    final response = await _httpClient
        .get(Uri.parse('$_baseUrl$endpoint'))
        .timeout(Durations.connectionTimeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 404) {
      throw FeatureNotSupportedException(endpoint);
    } else {
      throw ApiException('GET $endpoint failed: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> _getArray(String endpoint) async {
    final response = await _httpClient
        .get(Uri.parse('$_baseUrl$endpoint'))
        .timeout(Durations.connectionTimeout);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else if (response.statusCode == 404) {
      throw FeatureNotSupportedException(endpoint);
    } else {
      throw ApiException('GET $endpoint failed: ${response.statusCode}');
    }
  }

  Future<void> _put(String endpoint, Map<String, dynamic> body) async {
    final response = await _httpClient
        .put(
          Uri.parse('$_baseUrl$endpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(Durations.connectionTimeout);

    if (response.statusCode != 200 && response.statusCode != 204) {
      if (response.statusCode == 404) {
        throw FeatureNotSupportedException(endpoint);
      }
      throw ApiException('PUT $endpoint failed: ${response.statusCode}');
    }
  }

  void dispose() {
    _httpClient.close();
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

class FeatureNotSupportedException implements Exception {
  final String endpoint;
  FeatureNotSupportedException(this.endpoint);

  @override
  String toString() => 'Feature not supported: $endpoint';
}
