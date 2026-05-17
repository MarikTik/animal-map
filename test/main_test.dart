import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:animal_map/main.dart';
import 'package:animal_map/models/incident.dart';

void main() {
  group('listenForIncidents', () {
    test('decodes a single valid message into an Incident', () async {
      final controller = StreamController<dynamic>();
      Incident? received;

      listenForIncidents(
        controller.stream,
        onIncident: (incident) => received = incident,
      );

      controller.add(jsonEncode(_validPayload(id: 'incident-1')));
      await controller.close();

      expect(received, isNotNull);
      expect(received!.incidentId, 'incident-1');
      expect(received!.type, IncidentType.animalOnRoad);
      expect(received!.location.latitude, 33.6846);
    });

    test('forwards multiple messages in order', () async {
      final controller = StreamController<dynamic>();
      final received = <String>[];

      listenForIncidents(
        controller.stream,
        onIncident: (incident) => received.add(incident.incidentId),
      );

      controller.add(jsonEncode(_validPayload(id: 'a')));
      controller.add(jsonEncode(_validPayload(id: 'b')));
      controller.add(jsonEncode(_validPayload(id: 'c')));
      await controller.close();

      expect(received, ['a', 'b', 'c']);
    });

    test('invokes onDone when the stream closes', () async {
      final controller = StreamController<dynamic>();
      var doneCalled = false;

      listenForIncidents(
        controller.stream,
        onIncident: (_) {},
        onDone: () => doneCalled = true,
      );

      await controller.close();
      expect(doneCalled, isTrue);
    });

    test('forwards stream errors to onError', () async {
      final controller = StreamController<dynamic>();
      Object? capturedError;

      listenForIncidents(
        controller.stream,
        onIncident: (_) {},
        onError: (error, _) => capturedError = error,
      );

      controller.addError(StateError('socket dropped'));
      await Future<void>.delayed(Duration.zero);
      await controller.close();

      expect(capturedError, isA<StateError>());
    });
  });
}

Map<String, dynamic> _validPayload({required String id}) {
  return {
    'incident_id': id,
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
  };
}
