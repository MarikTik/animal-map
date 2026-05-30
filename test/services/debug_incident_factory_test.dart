import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:animal_map/models/incident.dart';
import 'package:animal_map/services/debug_incident_factory.dart';

void main() {
  group('DebugIncidentFactory', () {
    const here = LatLng(32.88, -117.23);

    test('places the incident close to the reference point', () {
      final factory = DebugIncidentFactory();
      final incident = factory.near(here, offsetMeters: 250);

      final distance = Geolocator.distanceBetween(
        here.latitude,
        here.longitude,
        incident.location.latitude,
        incident.location.longitude,
      );

      // Within a small tolerance of the requested offset.
      expect(distance, closeTo(250, 30));
    });

    test('produces a valid IncidentType', () {
      final factory = DebugIncidentFactory();
      final incident = factory.near(here);

      expect(IncidentType.values, contains(incident.type));
    });

    test('uses a seeded Random for deterministic type selection', () {
      final factory = DebugIncidentFactory(random: Random(1));
      final a = factory.near(here);

      final factory2 = DebugIncidentFactory(random: Random(1));
      final b = factory2.near(here);

      expect(a.type, b.type);
    });

    test('generates unique incident ids', () {
      final factory = DebugIncidentFactory();
      final a = factory.near(here);
      final b = factory.near(here);

      expect(a.incidentId, isNot(b.incidentId));
    });
  });
}
