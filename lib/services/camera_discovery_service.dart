import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/discovered_camera.dart';
import '../utils/constants.dart';
import '../utils/platform_capabilities.dart';
import 'mdns_resolver.dart';

/// Service for discovering Blackmagic cameras on the network.
///
/// Checks known default mDNS hostnames for Blackmagic cameras
/// and validates them by calling the camera API.
class CameraDiscoveryService {
  CameraDiscoveryService({
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  bool _isDiscovering = false;
  bool _cancelled = false;

  bool get isDiscovering => _isDiscovering;

  /// Discover cameras by checking known default hostnames.
  /// Returns a list of discovered cameras.
  Future<List<DiscoveredCamera>> discoverCameras({
    Duration timeout = DiscoveryConstants.discoveryTimeout,
  }) async {
    // mDNS discovery is not available on web platforms
    if (!PlatformCapabilities.canDiscoverCameras) {
      debugPrint('[Discovery] Not available on web platform');
      return [];
    }

    if (_isDiscovering) {
      return [];
    }

    _isDiscovering = true;
    _cancelled = false;

    debugPrint('[Discovery] Starting discovery...');

    final cameras = <DiscoveredCamera>[];

    try {
      // Check all known hostnames in parallel
      final futures = DiscoveryConstants.knownCameraHostnames.map(
        (hostname) => _checkHostname(hostname),
      );

      final results = await Future.wait(futures).timeout(
        timeout,
        onTimeout: () {
          debugPrint('[Discovery] Timeout reached');
          return List.filled(DiscoveryConstants.knownCameraHostnames.length, null);
        },
      );

      for (final camera in results) {
        if (camera != null && !_cancelled) {
          cameras.add(camera);
        }
      }
    } catch (e) {
      debugPrint('[Discovery] Error: $e');
    } finally {
      _isDiscovering = false;
      debugPrint('[Discovery] Complete. Found ${cameras.length} camera(s)');
    }

    return cameras;
  }

  Future<DiscoveredCamera?> _checkHostname(String hostname) async {
    if (_cancelled) return null;

    debugPrint('[Discovery] Checking $hostname...');

    try {
      // Resolve hostname to IP
      final ipAddress = await MdnsResolver.resolveWithTimeout(
        hostname,
        timeout: const Duration(seconds: 3),
      );

      debugPrint('[Discovery] $hostname -> $ipAddress');

      if (_cancelled) return null;

      // Validate as Blackmagic camera
      return await _validateCamera(
        host: hostname,
        ipAddress: ipAddress,
      );
    } on MdnsResolutionException catch (e) {
      debugPrint('[Discovery] $hostname: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('[Discovery] $hostname error: $e');
      return null;
    }
  }

  Future<DiscoveredCamera?> _validateCamera({
    required String host,
    required String ipAddress,
  }) async {
    // Use /system endpoint - returns 204 for Blackmagic cameras
    final url = 'http://$ipAddress:${ApiEndpoints.defaultPort}${ApiEndpoints.system}';

    debugPrint('[Discovery] Validating $url');

    try {
      final response = await _httpClient
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));

      debugPrint('[Discovery] Response status: ${response.statusCode}');
      debugPrint('[Discovery] Server header: ${response.headers['server']}');

      // Check if it's a Blackmagic camera by the Server header
      final server = response.headers['server'] ?? '';
      if (server.contains('BlackmagicDesign')) {
        // Extract product name from hostname (e.g., "micro-studio-camera-4k-g2" -> "Micro Studio Camera 4K G2")
        final productName = _formatProductName(host);

        debugPrint('[Discovery] Found Blackmagic camera: $productName');
        return DiscoveredCamera(
          deviceName: productName,
          productName: productName,
          host: host,
          port: ApiEndpoints.defaultPort,
          ipAddress: ipAddress,
        );
      } else {
        debugPrint('[Discovery] Not a Blackmagic camera (server: $server)');
      }
    } catch (e) {
      debugPrint('[Discovery] Validation failed: $e');
    }
    return null;
  }

  /// Convert hostname to readable product name
  /// e.g., "micro-studio-camera-4k-g2.local" -> "Micro Studio Camera 4K G2"
  String _formatProductName(String hostname) {
    return hostname
        .replaceAll('.local', '')
        .split('-')
        .map((word) => word.toUpperCase() == word
            ? word  // Keep acronyms like "4K" uppercase
            : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  void stopDiscovery() {
    _cancelled = true;
    _isDiscovering = false;
  }

  void dispose() {
    stopDiscovery();
    _httpClient.close();
  }
}
