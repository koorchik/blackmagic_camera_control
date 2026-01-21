import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/camera_service.dart';
import '../services/mdns_resolver.dart';
import '../utils/constants.dart';

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

class CameraConnectionProvider extends ChangeNotifier {
  CameraConnectionProvider();

  ConnectionStatus _status = ConnectionStatus.disconnected;
  String _cameraHost = '';
  String _resolvedIp = '';
  String _errorMessage = '';
  CameraService? _cameraService;

  ConnectionStatus get status => _status;
  String get cameraIp => _cameraHost;
  String get resolvedIp => _resolvedIp;
  String get errorMessage => _errorMessage;
  CameraService? get cameraService => _cameraService;
  bool get isConnected => _status == ConnectionStatus.connected;

  /// Load the last used camera IP from preferences
  Future<void> loadSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    _cameraHost = prefs.getString(PrefsKeys.lastCameraIp) ?? '';
    notifyListeners();
  }

  /// Connect to a camera at the given hostname or IP address
  Future<bool> connect(String host) async {
    if (host.isEmpty) {
      _setError('Please enter a camera IP address');
      return false;
    }

    _status = ConnectionStatus.connecting;
    _cameraHost = host;
    _resolvedIp = '';
    _errorMessage = '';
    notifyListeners();

    try {
      // Resolve mDNS hostname if needed
      final resolvedHost = await MdnsResolver.resolveWithTimeout(host);
      _resolvedIp = resolvedHost;

      _cameraService = CameraService(host: resolvedHost);
      final connected = await _cameraService!.testConnection();

      if (connected) {
        await _cameraService!.connectWebSocket();
        _status = ConnectionStatus.connected;

        // Save hostname for next time
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(PrefsKeys.lastCameraIp, host);

        notifyListeners();
        return true;
      } else {
        _setError('Could not connect to camera at $host');
        return false;
      }
    } on MdnsResolutionException catch (e) {
      _setError('mDNS resolution failed: ${e.message}');
      return false;
    } catch (e) {
      _setError('Connection failed: ${e.toString()}');
      return false;
    }
  }

  /// Disconnect from the camera
  Future<void> disconnect() async {
    await _cameraService?.disconnectWebSocket();
    _cameraService?.dispose();
    _cameraService = null;
    _status = ConnectionStatus.disconnected;
    _resolvedIp = '';
    _errorMessage = '';
    notifyListeners();
  }

  void _setError(String message) {
    _status = ConnectionStatus.error;
    _errorMessage = message;
    _resolvedIp = '';
    _cameraService?.dispose();
    _cameraService = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _cameraService?.dispose();
    super.dispose();
  }
}
