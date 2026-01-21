import 'package:flutter/foundation.dart';

/// Shot type for slate metadata
enum ShotType {
  ws('WS', 'Wide Shot'),
  ms('MS', 'Medium Shot'),
  mcu('MCU', 'Medium Close-Up'),
  cu('CU', 'Close-Up'),
  bcu('BCU', 'Big Close-Up'),
  ecu('ECU', 'Extreme Close-Up');

  const ShotType(this.code, this.label);
  final String code;
  final String label;
}

/// Scene location for slate metadata
enum SceneLocation {
  interior('INT', 'Interior'),
  exterior('EXT', 'Exterior');

  const SceneLocation(this.code, this.label);
  final String code;
  final String label;
}

/// Scene time for slate metadata
enum SceneTime {
  day('DAY', 'Day'),
  night('NIGHT', 'Night'),
  dawn('DAWN', 'Dawn'),
  dusk('DUSK', 'Dusk');

  const SceneTime(this.code, this.label);
  final String code;
  final String label;
}

@immutable
class SlateState {
  const SlateState({
    this.scene = '',
    this.take = 1,
    this.goodTake = false,
    this.shotType,
    this.sceneLocation,
    this.sceneTime,
    this.projectName = '',
    this.director = '',
    this.cameraOperator = '',
    this.lens = '',
    this.comments = '',
  });

  /// Scene name/number
  final String scene;

  /// Take number
  final int take;

  /// Whether this is marked as a good take
  final bool goodTake;

  /// Shot type (WS, MS, CU, etc.)
  final ShotType? shotType;

  /// Scene location (Interior/Exterior)
  final SceneLocation? sceneLocation;

  /// Scene time (Day/Night/etc.)
  final SceneTime? sceneTime;

  /// Project name
  final String projectName;

  /// Director name
  final String director;

  /// Camera operator name
  final String cameraOperator;

  /// Lens information
  final String lens;

  /// Additional comments
  final String comments;

  SlateState copyWith({
    String? scene,
    int? take,
    bool? goodTake,
    ShotType? shotType,
    bool clearShotType = false,
    SceneLocation? sceneLocation,
    bool clearSceneLocation = false,
    SceneTime? sceneTime,
    bool clearSceneTime = false,
    String? projectName,
    String? director,
    String? cameraOperator,
    String? lens,
    String? comments,
  }) {
    return SlateState(
      scene: scene ?? this.scene,
      take: take ?? this.take,
      goodTake: goodTake ?? this.goodTake,
      shotType: clearShotType ? null : (shotType ?? this.shotType),
      sceneLocation: clearSceneLocation ? null : (sceneLocation ?? this.sceneLocation),
      sceneTime: clearSceneTime ? null : (sceneTime ?? this.sceneTime),
      projectName: projectName ?? this.projectName,
      director: director ?? this.director,
      cameraOperator: cameraOperator ?? this.cameraOperator,
      lens: lens ?? this.lens,
      comments: comments ?? this.comments,
    );
  }

  factory SlateState.fromJson(Map<String, dynamic> json) {
    return SlateState(
      scene: json['scene'] as String? ?? '',
      take: json['take'] as int? ?? 1,
      goodTake: json['goodTake'] as bool? ?? false,
      shotType: _shotTypeFromString(json['shotType'] as String?),
      sceneLocation: _locationFromString(json['sceneLocation'] as String?),
      sceneTime: _timeFromString(json['sceneTime'] as String?),
      projectName: json['projectName'] as String? ?? '',
      director: json['director'] as String? ?? '',
      cameraOperator: json['cameraOperator'] as String? ?? '',
      lens: json['lens'] as String? ?? '',
      comments: json['comments'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scene': scene,
      'take': take,
      'goodTake': goodTake,
      if (shotType != null) 'shotType': shotType!.code,
      if (sceneLocation != null) 'sceneLocation': sceneLocation!.code,
      if (sceneTime != null) 'sceneTime': sceneTime!.code,
      'projectName': projectName,
      'director': director,
      'cameraOperator': cameraOperator,
      'lens': lens,
      'comments': comments,
    };
  }

  static ShotType? _shotTypeFromString(String? value) {
    if (value == null) return null;
    return ShotType.values.cast<ShotType?>().firstWhere(
      (e) => e?.code == value,
      orElse: () => null,
    );
  }

  static SceneLocation? _locationFromString(String? value) {
    if (value == null) return null;
    return SceneLocation.values.cast<SceneLocation?>().firstWhere(
      (e) => e?.code == value,
      orElse: () => null,
    );
  }

  static SceneTime? _timeFromString(String? value) {
    if (value == null) return null;
    return SceneTime.values.cast<SceneTime?>().firstWhere(
      (e) => e?.code == value,
      orElse: () => null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SlateState &&
        other.scene == scene &&
        other.take == take &&
        other.goodTake == goodTake &&
        other.shotType == shotType &&
        other.sceneLocation == sceneLocation &&
        other.sceneTime == sceneTime &&
        other.projectName == projectName &&
        other.director == director &&
        other.cameraOperator == cameraOperator &&
        other.lens == lens &&
        other.comments == comments;
  }

  @override
  int get hashCode => Object.hash(
        scene,
        take,
        goodTake,
        shotType,
        sceneLocation,
        sceneTime,
        projectName,
        director,
        cameraOperator,
        lens,
        comments,
      );

  @override
  String toString() => 'SlateState(scene: $scene, take: $take)';
}
