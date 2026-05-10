/// A detected road incident received from the backend.
class Incident {
  const Incident({
    required this.incidentId,
    required this.type,
    required this.occurredAt,
    required this.reportedAt,
    required this.location,
    required this.recommendedAction,
    required this.evidence,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      incidentId: _readString(json, 'incident_id'),
      type: IncidentType.fromJson(_readString(json, 'type')),
      occurredAt: DateTime.parse(_readString(json, 'occurred_at')),
      reportedAt: DateTime.parse(_readString(json, 'reported_at')),
      location: IncidentLocation.fromJson(_readMap(json, 'location')),
      recommendedAction: RecommendedAction.fromJson(
        _readMap(json, 'recommended_action'),
      ),
      evidence: IncidentEvidence.fromJson(_readMap(json, 'evidence')),
    );
  }

  final String incidentId;
  final IncidentType type;
  final DateTime occurredAt;
  final DateTime reportedAt;
  final IncidentLocation location;
  final RecommendedAction recommendedAction;
  final IncidentEvidence evidence;

  @override
  String toString() {
    return 'Incident('
        'incidentId: $incidentId, '
        'type: ${type.jsonValue}, '
        'occurredAt: ${occurredAt.toIso8601String()}, '
        'reportedAt: ${reportedAt.toIso8601String()}, '
        'location: $location, '
        'recommendedAction: $recommendedAction, '
        'evidence: $evidence'
        ')';
  }
}

enum IncidentType {
  animalOnRoad('animal_on_road'),
  personOnRoad('person_on_road'),
  stoppedVehicle('stopped_vehicle'),
  roadObstruction('road_obstruction'),
  unknown('unknown');

  const IncidentType(this.jsonValue);

  final String jsonValue;

  static IncidentType fromJson(String value) {
    for (final type in values) {
      if (type.jsonValue == value) return type;
    }
    throw FormatException('Unsupported incident type: $value');
  }
}

class IncidentLocation {
  const IncidentLocation({
    required this.latitude,
    required this.longitude,
    required this.roadName,
    required this.direction,
    required this.mileMarker,
    required this.cameraId,
  });

  factory IncidentLocation.fromJson(Map<String, dynamic> json) {
    return IncidentLocation(
      latitude: _readNumber(json, 'latitude'),
      longitude: _readNumber(json, 'longitude'),
      roadName: _readNullableString(json, 'road_name'),
      direction: _readNullableString(json, 'direction'),
      mileMarker: _readNullableString(json, 'mile_marker'),
      cameraId: _readString(json, 'camera_id'),
    );
  }

  final double latitude;
  final double longitude;
  final String? roadName;
  final String? direction;
  final String? mileMarker;
  final String cameraId;

  @override
  String toString() {
    return 'IncidentLocation('
        'latitude: $latitude, '
        'longitude: $longitude, '
        'roadName: $roadName, '
        'direction: $direction, '
        'mileMarker: $mileMarker, '
        'cameraId: $cameraId'
        ')';
  }
}

class RecommendedAction {
  const RecommendedAction({required this.priority, required this.message});

  factory RecommendedAction.fromJson(Map<String, dynamic> json) {
    return RecommendedAction(
      priority: IncidentPriority.fromJson(_readString(json, 'priority')),
      message: _readString(json, 'message'),
    );
  }

  final IncidentPriority priority;
  final String message;

  @override
  String toString() {
    return 'RecommendedAction('
        'priority: ${priority.jsonValue}, '
        'message: $message'
        ')';
  }
}

enum IncidentPriority {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  const IncidentPriority(this.jsonValue);

  final String jsonValue;

  static IncidentPriority fromJson(String value) {
    for (final priority in values) {
      if (priority.jsonValue == value) return priority;
    }
    throw FormatException('Unsupported incident priority: $value');
  }
}

class IncidentEvidence {
  const IncidentEvidence({
    required this.snapshotUrl,
    required this.videoClipUrl,
  });

  factory IncidentEvidence.fromJson(Map<String, dynamic> json) {
    return IncidentEvidence(
      snapshotUrl: _readNullableString(json, 'snapshot_url'),
      videoClipUrl: _readNullableString(json, 'video_clip_url'),
    );
  }

  final String? snapshotUrl;
  final String? videoClipUrl;

  @override
  String toString() {
    return 'IncidentEvidence('
        'snapshotUrl: $snapshotUrl, '
        'videoClipUrl: $videoClipUrl'
        ')';
  }
}

String _readString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String) return value;
  throw FormatException('Expected "$key" to be a string.');
}

String? _readNullableString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null || value is String) return value as String?;
  throw FormatException('Expected "$key" to be a string or null.');
}

double _readNumber(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is num) return value.toDouble();
  throw FormatException('Expected "$key" to be a number.');
}

Map<String, dynamic> _readMap(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  throw FormatException('Expected "$key" to be an object.');
}
