import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

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

  /// Trigger autofocus
  Future<void> triggerAutofocus() async {
    final response = await _httpClient
        .put(Uri.parse('$_baseUrl${ApiEndpoints.lensDoAutoFocus}'))
        .timeout(Durations.connectionTimeout);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException('Autofocus failed: ${response.statusCode}');
    }
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
