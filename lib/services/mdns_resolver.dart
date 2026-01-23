// Conditional export for platform-specific mDNS resolver implementations.
//
// - Native platforms (Linux, Windows, macOS, Android, iOS): Full mDNS resolution
// - Web: IP address validation only (browsers cannot perform DNS lookups)
export 'mdns_resolver_native.dart'
    if (dart.library.html) 'mdns_resolver_web.dart';
