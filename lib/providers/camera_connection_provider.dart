import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/discovered_camera.dart';
import '../services/camera_discovery_service.dart';
import '../services/camera_service.dart';
import '../services/mdns_resolver.dart';
import '../utils/constants.dart';

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

enum DiscoveryStatus {
  idle,
  discovering,
  completed,
  error,
}

class CameraConnectionProvider extends ChangeNotifier {
  CameraConnectionProvider();

  // Connection state
  ConnectionStatus _status = ConnectionStatus.disconnected;
  String _cameraHost = '';
  String _resolvedIp = '';
  String _errorMessage = '';
  CameraService? _cameraService;

  // Discovery state
  DiscoveryStatus _discoveryStatus = DiscoveryStatus.idle;
  List<DiscoveredCamera> _discoveredCameras = [];
  String _discoveryErrorMessage = '';
  CameraDiscoveryService? _discoveryService;

  // Connection getters
  ConnectionStatus get status => _status;
  String get cameraIp => _cameraHost;
  String get resolvedIp => _resolvedIp;
  String get errorMessage => _errorMessage;
  CameraService? get cameraService => _cameraService;
  bool get isConnected => _status == ConnectionStatus.connected;

  // Discovery getters
  DiscoveryStatus get discoveryStatus => _discoveryStatus;
  List<DiscoveredCamera> get discoveredCameras => List.unmodifiable(_discoveredCameras);
  String get discoveryErrorMessage => _discoveryErrorMessage;
  bool get isDiscovering => _discoveryStatus == DiscoveryStatus.discovering;

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

  // ========== DISCOVERY METHODS ==========

  /// Start discovering cameras on the network
  Future<void> startDiscovery() async {
    if (_discoveryStatus == DiscoveryStatus.discovering) {
      return;
    }

    _discoveryStatus = DiscoveryStatus.discovering;
    _discoveredCameras = [];
    _discoveryErrorMessage = '';
    notifyListeners();

    try {
      _discoveryService = CameraDiscoveryService();
      final cameras = await _discoveryService!.discoverCameras();

      _discoveredCameras = cameras;
      _discoveryStatus = DiscoveryStatus.completed;
      notifyListeners();
    } catch (e) {
      _setDiscoveryError('Discovery failed: $e');
    } finally {
      _discoveryService?.dispose();
      _discoveryService = null;
    }
  }

  /// Stop the current discovery operation
  void stopDiscovery() {
    _discoveryService?.stopDiscovery();
    _discoveryService?.dispose();
    _discoveryService = null;

    if (_discoveryStatus == DiscoveryStatus.discovering) {
      _discoveryStatus = DiscoveryStatus.completed;
      notifyListeners();
    }
  }

  /// Connect to a discovered camera
  Future<bool> connectToDiscoveredCamera(DiscoveredCamera camera) async {
    stopDiscovery();
    return connect(camera.connectionAddress);
  }

  void _setDiscoveryError(String message) {
    _discoveryStatus = DiscoveryStatus.error;
    _discoveryErrorMessage = message;
    _discoveryService?.dispose();
    _discoveryService = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopDiscovery();
    _cameraService?.dispose();
    super.dispose();
  }
}
