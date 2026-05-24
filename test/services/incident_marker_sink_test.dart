import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:animal_map/models/incident.dart';
import 'package:animal_map/filters/incident_filter.dart';
import 'package:animal_map/services/incident_marker_sink.dart';

import '../fakes/fake_incident_socket_service.dart';
import '../fakes/fake_marker_manager.dart';
import '../fakes/incident_factory.dart';

/// A pass-through [IncidentFilter] stub — all incidents pass.
class _AllowAll implements IncidentFilter {
  @override
  bool passes(Incident incident) => true;
}

/// A reject-all [IncidentFilter] stub — no incidents pass.
class _RejectAll implements IncidentFilter {
  @override
  bool passes(Incident incident) => false;
}

void main() {
  group('IncidentMarkerSink', () {
    late FakeIncidentSocketService socketService;
    late FakeMarkerManager markerManager;

    setUp(() {
      socketService = FakeIncidentSocketService();
      markerManager = FakeMarkerManager();
    });

    IncidentMarkerSink buildSink({IncidentFilter? filter}) {
      return IncidentMarkerSink(
        socketService: socketService,
        filter: filter ?? _AllowAll(),
        markerManager: markerManager,
      );
    }

    test('is not attached before attach() is called', () {
      final sink = buildSink();
      expect(sink.isAttached, isFalse);
    });

    test('is attached after attach()', () {
      final sink = buildSink();
      sink.attach();
      expect(sink.isAttached, isTrue);
      sink.detach();
    });

    test('is not attached after detach()', () {
      final sink = buildSink();
      sink.attach();
      sink.detach();
      expect(sink.isAttached, isFalse);
    });

    test('calling attach twice is a no-op (no duplicate markers)', () async {
      final sink = buildSink();
      sink.attach();
      sink.attach();

      socketService.emit(makeIncident());
      await Future<void>.delayed(Duration.zero);

      expect(markerManager.addedMarkers.length, 1);
      sink.detach();
    });

    test('forwards a passing incident as a marker', () async {
      final sink = buildSink();
      sink.attach();

      const pos = LatLng(32.88, -117.23);
      socketService.emit(
        makeIncident(
          type: IncidentType.animalOnRoad,
          latitude: pos.latitude,
          longitude: pos.longitude,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(markerManager.addedMarkers.length, 1);
      expect(markerManager.addedMarkers.first.position, pos);
      sink.detach();
    });

    test('marker has the correct incidentType', () async {
      final sink = buildSink();
      sink.attach();

      socketService.emit(makeIncident(type: IncidentType.stoppedVehicle));
      await Future<void>.delayed(Duration.zero);

      expect(
        markerManager.addedMarkers.first.incidentType,
        IncidentType.stoppedVehicle,
      );
      sink.detach();
    });

    test('rejects incident when filter returns false', () async {
      final sink = buildSink(filter: _RejectAll());
      sink.attach();

      socketService.emit(makeIncident());
      await Future<void>.delayed(Duration.zero);

      expect(markerManager.addedMarkers, isEmpty);
      sink.detach();
    });

    test('multiple incidents produce multiple markers', () async {
      final sink = buildSink();
      sink.attach();

      for (var i = 0; i < 4; i++) {
        socketService.emit(makeIncident(
          incidentId: 'id-$i',
          latitude: 32.88 + i * 0.001,
          longitude: -117.23,
        ));
      }
      await Future<void>.delayed(Duration.zero);

      expect(markerManager.addedMarkers.length, 4);
      sink.detach();
    });

    test('stream error does not crash the sink', () async {
      final sink = buildSink();
      sink.attach();

      socketService.emitError(StateError('oops'));
      socketService.emit(makeIncident());
      await Future<void>.delayed(Duration.zero);

      // Sink survived the error and processed the next incident.
      expect(markerManager.addedMarkers.length, 1);
      sink.detach();
    });

    test('no markers added after detach', () async {
      final sink = buildSink();
      sink.attach();
      sink.detach();

      socketService.emit(makeIncident());
      await Future<void>.delayed(Duration.zero);

      expect(markerManager.addedMarkers, isEmpty);
    });
  });
}
