import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:animal_map/models/incident.dart';
import 'package:animal_map/services/incident_message_decoder.dart';

void main() {
  group('IncidentMessageDecoder', () {
    const decoder = IncidentMessageDecoder();

    test('decodes a well-formed incident payload', () {
      final incident = decoder.decode(jsonEncode(_validPayload(id: 'i-1')));

      expect(incident.incidentId, 'i-1');
      expect(incident.type, IncidentType.animalOnRoad);
      expect(incident.location.latitude, 33.6846);
      expect(incident.location.cameraId, 'camera-7');
      expect(incident.recommendedAction.priority, IncidentPriority.high);
    });

    test('decodes each supported IncidentType', () {
      for (final type in IncidentType.values) {
        final payload = _validPayload(id: 'i', type: type.jsonValue);
        expect(decoder.decode(jsonEncode(payload)).type, type);
      }
    });

    test('throws FormatException on malformed JSON', () {
      expect(
        () => decoder.decode('not json'),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when root is not an object', () {
      expect(
        () => decoder.decode('[1, 2, 3]'),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException when required field is missing', () {
      final payload = _validPayload(id: 'i')..remove('incident_id');
      expect(
        () => decoder.decode(jsonEncode(payload)),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws FormatException on unsupported incident type', () {
      final payload = _validPayload(id: 'i', type: 'martian_invasion');
      expect(
        () => decoder.decode(jsonEncode(payload)),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

Map<String, dynamic> _validPayload({
  required String id,
  String type = 'animal_on_road',
}) {
  return {
    'incident_id': id,
    'type': type,
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
  };
}
