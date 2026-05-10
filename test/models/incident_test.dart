import 'package:animal_map/models/incident.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Incident', () {
    test('deserializes the backend incident contract', () {
      final incident = Incident.fromJson({
        'incident_id': 'incident-123',
        'type': 'animal_on_road',
        'occurred_at': '2026-05-10T12:30:00Z',
        'reported_at': '2026-05-10T12:31:00Z',
        'location': {
          'latitude': 33.6846,
          'longitude': -117.8265,
          'road_name': 'I-405',
          'direction': 'northbound',
          'mile_marker': null,
          'camera_id': 'camera-7',
        },
        'recommended_action': {
          'priority': 'high',
          'message': 'Slow down and prepare to stop.',
        },
        'evidence': {
          'snapshot_url': 'https://example.com/snapshot.jpg',
          'video_clip_url': null,
        },
      });

      expect(incident.incidentId, 'incident-123');
      expect(incident.type, IncidentType.animalOnRoad);
      expect(incident.occurredAt, DateTime.parse('2026-05-10T12:30:00Z'));
      expect(incident.reportedAt, DateTime.parse('2026-05-10T12:31:00Z'));
      expect(incident.location.latitude, 33.6846);
      expect(incident.location.longitude, -117.8265);
      expect(incident.location.roadName, 'I-405');
      expect(incident.location.direction, 'northbound');
      expect(incident.location.mileMarker, isNull);
      expect(incident.location.cameraId, 'camera-7');
      expect(incident.recommendedAction.priority, IncidentPriority.high);
      expect(
        incident.recommendedAction.message,
        'Slow down and prepare to stop.',
      );
      expect(incident.evidence.snapshotUrl, 'https://example.com/snapshot.jpg');
      expect(incident.evidence.videoClipUrl, isNull);
    });

    test('rejects unsupported incident type', () {
      expect(
        () => IncidentType.fromJson('bad_type'),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects missing required fields', () {
      expect(
        () => Incident.fromJson(const <String, dynamic>{}),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
