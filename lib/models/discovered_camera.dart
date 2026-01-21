import 'package:flutter/foundation.dart';

/// Represents a camera discovered via mDNS service browsing
@immutable
class DiscoveredCamera {
  const DiscoveredCamera({
    required this.deviceName,
    required this.productName,
    required this.host,
    this.port = 80,
    this.ipAddress,
    this.softwareVersion,
  });

  /// Device name from camera API (user-configurable name)
  final String deviceName;

  /// Product name from camera API (e.g., "Blackmagic URSA Broadcast G2")
  final String productName;

  /// Hostname from mDNS SRV record
  final String host;

  /// Port number (typically 80)
  final int port;

  /// Resolved IP address from A record
  final String? ipAddress;

  /// Software version from camera API
  final String? softwareVersion;

  /// Returns the best address to connect to (IP if available, otherwise host)
  String get connectionAddress => ipAddress ?? host;

  /// Display name for UI (uses deviceName)
  String get displayName => deviceName;

  DiscoveredCamera copyWith({
    String? deviceName,
    String? productName,
    String? host,
    int? port,
    String? ipAddress,
    String? softwareVersion,
  }) {
    return DiscoveredCamera(
      deviceName: deviceName ?? this.deviceName,
      productName: productName ?? this.productName,
      host: host ?? this.host,
      port: port ?? this.port,
      ipAddress: ipAddress ?? this.ipAddress,
      softwareVersion: softwareVersion ?? this.softwareVersion,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiscoveredCamera &&
        other.deviceName == deviceName &&
        other.productName == productName &&
        other.host == host &&
        other.port == port &&
        other.ipAddress == ipAddress &&
        other.softwareVersion == softwareVersion;
  }

  @override
  int get hashCode =>
      Object.hash(deviceName, productName, host, port, ipAddress, softwareVersion);

  @override
  String toString() =>
      'DiscoveredCamera(deviceName: $deviceName, productName: $productName, '
      'host: $host, port: $port, ipAddress: $ipAddress, '
      'softwareVersion: $softwareVersion)';
}
