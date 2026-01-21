import 'package:multicast_dns/multicast_dns.dart';

/// Resolves mDNS (.local) hostnames to IP addresses
class MdnsResolver {
  MdnsResolver._();

  /// Resolve a hostname to an IP address
  /// If it's a .local hostname, uses mDNS resolution
  /// Otherwise returns the hostname as-is (assuming it's an IP or regular DNS)
  static Future<String> resolve(String hostname) async {
    if (!hostname.endsWith('.local')) {
      return hostname;
    }

    final client = MDnsClient();
    try {
      await client.start();

      // Query for A records (IPv4)
      final query = ResourceRecordQuery.addressIPv4(hostname);

      await for (final record in client.lookup<IPAddressResourceRecord>(query)) {
        final ip = record.address.address;
        client.stop();
        return ip;
      }

      // If no IPv4, try IPv6
      final queryV6 = ResourceRecordQuery.addressIPv6(hostname);
      await for (final record in client.lookup<IPAddressResourceRecord>(queryV6)) {
        final ip = record.address.address;
        client.stop();
        return ip;
      }

      throw MdnsResolutionException('Could not resolve $hostname via mDNS');
    } finally {
      client.stop();
    }
  }

  /// Resolve with timeout
  static Future<String> resolveWithTimeout(
    String hostname, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (!hostname.endsWith('.local')) {
      return hostname;
    }

    return resolve(hostname).timeout(
      timeout,
      onTimeout: () => throw MdnsResolutionException(
        'mDNS resolution timed out for $hostname',
      ),
    );
  }
}

class MdnsResolutionException implements Exception {
  final String message;
  MdnsResolutionException(this.message);

  @override
  String toString() => message;
}
