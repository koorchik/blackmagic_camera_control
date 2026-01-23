/// Web-compatible mDNS resolver stub.
/// Browsers cannot perform DNS lookups, so this only validates IP addresses.
class MdnsResolver {
  MdnsResolver._();

  /// IPv4 address regex pattern
  static final _ipv4Pattern = RegExp(
    r'^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$',
  );

  /// IPv6 address regex pattern (simplified)
  static final _ipv6Pattern = RegExp(
    r'^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$|'
    r'^::([0-9a-fA-F]{1,4}:){0,6}[0-9a-fA-F]{1,4}$|'
    r'^([0-9a-fA-F]{1,4}:){1,7}:$|'
    r'^([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}$|'
    r'^([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}$|'
    r'^([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}$|'
    r'^([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}$|'
    r'^([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}$|'
    r'^[0-9a-fA-F]{1,4}:(:[0-9a-fA-F]{1,4}){1,6}$',
  );

  /// Resolve a hostname to an IP address.
  /// On web, only IP addresses are supported - hostnames cannot be resolved.
  static Future<String> resolve(String hostname) async {
    if (_isIpAddress(hostname)) {
      return hostname;
    }

    throw MdnsResolutionException(
      'Hostname resolution is not supported on web. '
      'Please enter an IP address directly (e.g., 192.168.1.100).',
    );
  }

  /// Resolve with timeout.
  /// On web, only IP addresses are supported.
  static Future<String> resolveWithTimeout(
    String hostname, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    return resolve(hostname);
  }

  static bool _isIpAddress(String hostname) {
    return _ipv4Pattern.hasMatch(hostname) || _ipv6Pattern.hasMatch(hostname);
  }
}

class MdnsResolutionException implements Exception {
  final String message;
  MdnsResolutionException(this.message);

  @override
  String toString() => message;
}
