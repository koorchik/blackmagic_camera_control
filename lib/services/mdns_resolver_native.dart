import 'dart:io';

/// Resolves hostnames (including mDNS .local) to IP addresses
/// Uses the system's DNS resolver which includes mDNS via avahi/nsswitch
class MdnsResolver {
  MdnsResolver._();

  /// Resolve a hostname to an IP address
  /// Uses system DNS resolver (supports mDNS via avahi on Linux)
  static Future<String> resolve(String hostname) async {
    // If it looks like an IP address, return as-is
    if (_isIpAddress(hostname)) {
      return hostname;
    }

    try {
      final results = await InternetAddress.lookup(hostname);
      if (results.isNotEmpty) {
        // Prefer IPv4
        for (final result in results) {
          if (result.type == InternetAddressType.IPv4) {
            return result.address;
          }
        }
        // Fall back to first result
        return results.first.address;
      }
      throw MdnsResolutionException('No addresses found for $hostname');
    } on SocketException catch (e) {
      throw MdnsResolutionException('Could not resolve $hostname: ${e.message}');
    }
  }

  /// Resolve with timeout
  static Future<String> resolveWithTimeout(
    String hostname, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (_isIpAddress(hostname)) {
      return hostname;
    }

    return resolve(hostname).timeout(
      timeout,
      onTimeout: () => throw MdnsResolutionException(
        'DNS resolution timed out for $hostname',
      ),
    );
  }

  static bool _isIpAddress(String hostname) {
    return InternetAddress.tryParse(hostname) != null;
  }
}

class MdnsResolutionException implements Exception {
  final String message;
  MdnsResolutionException(this.message);

  @override
  String toString() => message;
}
