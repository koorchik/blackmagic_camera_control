import 'package:flutter/foundation.dart';

/// Filesystem type for media formatting
enum FilesystemType {
  hfsPlus('HFS+', 'HFS+ (Mac)'),
  exFat('ExFAT', 'ExFAT (Universal)');

  const FilesystemType(this.code, this.label);
  final String code;
  final String label;
}

@immutable
class MediaDevice {
  const MediaDevice({
    required this.deviceName,
    this.remainingRecordTime = 0,
    this.totalSpace = 0,
    this.remainingSpace = 0,
    this.clipName = '',
    this.isActive = false,
  });

  /// Device name/identifier (e.g., "sd1", "cfast1")
  final String deviceName;

  /// Remaining recording time in seconds
  final int remainingRecordTime;

  /// Total storage space in bytes
  final int totalSpace;

  /// Remaining storage space in bytes
  final int remainingSpace;

  /// Current clip name on this device
  final String clipName;

  /// Whether this is the active recording device
  final bool isActive;

  /// Get used space in bytes
  int get usedSpace => totalSpace - remainingSpace;

  /// Get used space as percentage (0.0 to 1.0)
  double get usedPercentage {
    if (totalSpace == 0) return 0.0;
    return usedSpace / totalSpace;
  }

  /// Format remaining time as HH:MM:SS
  String get remainingTimeFormatted {
    final hours = remainingRecordTime ~/ 3600;
    final minutes = (remainingRecordTime % 3600) ~/ 60;
    final seconds = remainingRecordTime % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Format space in human readable format
  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get totalSpaceFormatted => formatBytes(totalSpace);
  String get remainingSpaceFormatted => formatBytes(remainingSpace);
  String get usedSpaceFormatted => formatBytes(usedSpace);

  MediaDevice copyWith({
    String? deviceName,
    int? remainingRecordTime,
    int? totalSpace,
    int? remainingSpace,
    String? clipName,
    bool? isActive,
  }) {
    return MediaDevice(
      deviceName: deviceName ?? this.deviceName,
      remainingRecordTime: remainingRecordTime ?? this.remainingRecordTime,
      totalSpace: totalSpace ?? this.totalSpace,
      remainingSpace: remainingSpace ?? this.remainingSpace,
      clipName: clipName ?? this.clipName,
      isActive: isActive ?? this.isActive,
    );
  }

  factory MediaDevice.fromJson(Map<String, dynamic> json) {
    return MediaDevice(
      deviceName: json['deviceName'] as String? ?? '',
      remainingRecordTime: json['remainingRecordTime'] as int? ?? 0,
      totalSpace: json['totalSpace'] as int? ?? 0,
      remainingSpace: json['remainingSpace'] as int? ?? 0,
      clipName: json['clipName'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaDevice &&
        other.deviceName == deviceName &&
        other.remainingRecordTime == remainingRecordTime &&
        other.totalSpace == totalSpace &&
        other.remainingSpace == remainingSpace &&
        other.clipName == clipName &&
        other.isActive == isActive;
  }

  @override
  int get hashCode => Object.hash(
        deviceName,
        remainingRecordTime,
        totalSpace,
        remainingSpace,
        clipName,
        isActive,
      );

  @override
  String toString() =>
      'MediaDevice(name: $deviceName, remaining: $remainingTimeFormatted)';
}

@immutable
class MediaState {
  const MediaState({
    this.devices = const [],
    this.formatInProgress = false,
    this.formatDeviceName,
    this.workingsetIndex = 0,
  });

  /// List of media devices
  final List<MediaDevice> devices;

  /// Whether a format operation is currently in progress
  final bool formatInProgress;

  /// Name of device being formatted
  final String? formatDeviceName;

  /// Current working set index (active slot)
  final int workingsetIndex;

  /// Get device by name
  MediaDevice? getDevice(String name) {
    return devices.cast<MediaDevice?>().firstWhere(
      (d) => d?.deviceName == name,
      orElse: () => null,
    );
  }

  /// Get active device
  MediaDevice? get activeDevice {
    return devices.cast<MediaDevice?>().firstWhere(
      (d) => d?.isActive == true,
      orElse: () => devices.isNotEmpty ? devices.first : null,
    );
  }

  MediaState copyWith({
    List<MediaDevice>? devices,
    bool? formatInProgress,
    String? formatDeviceName,
    bool clearFormatDeviceName = false,
    int? workingsetIndex,
  }) {
    return MediaState(
      devices: devices ?? this.devices,
      formatInProgress: formatInProgress ?? this.formatInProgress,
      formatDeviceName: clearFormatDeviceName
          ? null
          : (formatDeviceName ?? this.formatDeviceName),
      workingsetIndex: workingsetIndex ?? this.workingsetIndex,
    );
  }

  factory MediaState.fromJson(Map<String, dynamic> json) {
    final devicesJson = json['devices'] as List<dynamic>? ?? [];
    final devices = devicesJson
        .map((d) => MediaDevice.fromJson(d as Map<String, dynamic>))
        .toList();
    return MediaState(
      devices: devices,
      workingsetIndex: json['workingsetIndex'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MediaState &&
        listEquals(other.devices, devices) &&
        other.formatInProgress == formatInProgress &&
        other.formatDeviceName == formatDeviceName &&
        other.workingsetIndex == workingsetIndex;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(devices),
        formatInProgress,
        formatDeviceName,
        workingsetIndex,
      );

  @override
  String toString() =>
      'MediaState(devices: ${devices.length}, formatting: $formatInProgress)';
}
