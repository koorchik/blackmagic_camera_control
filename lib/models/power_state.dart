import 'package:flutter/foundation.dart';

/// Power source types
enum PowerSource {
  battery('Battery'),
  ac('AC'),
  fiber('Fiber'),
  usb('USB'),
  poe('PoE'),
  unknown('Unknown');

  const PowerSource(this.label);
  final String label;

  static PowerSource fromString(String? value) {
    return PowerSource.values.firstWhere(
      (s) => s.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => PowerSource.unknown,
    );
  }
}

/// Battery information
@immutable
class BatteryInfo {
  const BatteryInfo({
    this.percent = 0,
    this.voltageMillivolts = 0,
  });

  final int percent;
  final int voltageMillivolts;

  factory BatteryInfo.fromJson(Map<String, dynamic> json) {
    return BatteryInfo(
      percent: json['percent'] as int? ?? 0,
      voltageMillivolts: json['voltage'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BatteryInfo &&
        other.percent == percent &&
        other.voltageMillivolts == voltageMillivolts;
  }

  @override
  int get hashCode => Object.hash(percent, voltageMillivolts);
}

/// Tally status
enum TallyStatus {
  none('None'),
  preview('Preview'),
  program('Program');

  const TallyStatus(this.label);
  final String label;

  static TallyStatus fromString(String? value) {
    return TallyStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == value?.toLowerCase(),
      orElse: () => TallyStatus.none,
    );
  }
}

/// Power state information
@immutable
class PowerState {
  const PowerState({
    this.source = PowerSource.unknown,
    this.voltageMillivolts = 0,
    this.batteries = const [],
    this.charging = false,
  });

  final PowerSource source;
  final int voltageMillivolts;
  final List<BatteryInfo> batteries;
  final bool charging;

  /// Get primary battery percentage (first battery if available)
  int get primaryBatteryPercent =>
      batteries.isNotEmpty ? batteries.first.percent : 0;

  /// Check if running on battery power
  bool get isOnBattery =>
      source == PowerSource.battery || batteries.isNotEmpty;

  /// Get voltage in volts
  double get voltageVolts => voltageMillivolts / 1000.0;

  PowerState copyWith({
    PowerSource? source,
    int? voltageMillivolts,
    List<BatteryInfo>? batteries,
    bool? charging,
  }) {
    return PowerState(
      source: source ?? this.source,
      voltageMillivolts: voltageMillivolts ?? this.voltageMillivolts,
      batteries: batteries ?? this.batteries,
      charging: charging ?? this.charging,
    );
  }

  factory PowerState.fromJson(Map<String, dynamic> json) {
    final batteriesList = json['batteries'] as List<dynamic>? ?? [];
    final batteries = batteriesList
        .map((b) => BatteryInfo.fromJson(b as Map<String, dynamic>))
        .toList();

    return PowerState(
      source: PowerSource.fromString(json['source'] as String?),
      voltageMillivolts: json['voltage'] as int? ?? 0,
      batteries: batteries,
      charging: json['charging'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PowerState &&
        other.source == source &&
        other.voltageMillivolts == voltageMillivolts &&
        listEquals(other.batteries, batteries) &&
        other.charging == charging;
  }

  @override
  int get hashCode => Object.hash(
        source,
        voltageMillivolts,
        Object.hashAll(batteries),
        charging,
      );

  @override
  String toString() =>
      'PowerState(source: ${source.label}, battery: $primaryBatteryPercent%)';
}
