import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:animal_map/models/incident.dart';
import 'package:animal_map/filters/proximity_filter.dart';

import '../fakes/incident_factory.dart';

void main() {
  // Reference point: UCSD campus area.
  const ref = LatLng(32.88, -117.23);

  group('ProximityFilter', () {
    late ProximityFilter filter;

    setUp(() {
      filter = ProximityFilter(referencePoint: ref);
    });

    test('passes an incident within the threshold for its type', () {
      // ~0 m away — same coordinates as ref.
      final incident = makeIncident(
        type: IncidentType.animalOnRoad,
        latitude: ref.latitude,
        longitude: ref.longitude,
      );

      expect(filter.passes(incident), isTrue);
    });

    test('rejects an incident beyond the threshold for its type', () {
      // animalOnRoad threshold is 5 000 m; ~570 km away (LA area).
      final incident = makeIncident(
        type: IncidentType.animalOnRoad,
        latitude: 34.05,
        longitude: -118.24,
      );

      expect(filter.passes(incident), isFalse);
    });

    test('uses per-type threshold — personOnRoad has a tighter radius', () {
      // ~3 km away — within animalOnRoad (5 000 m) but outside personOnRoad (2 000 m).
      final incident = makeIncident(
        type: IncidentType.personOnRoad,
        latitude: ref.latitude + 0.027, // ~3 km north
        longitude: ref.longitude,
      );

      expect(filter.passes(incident), isFalse);
    });

    test('passes all types when incident is at the reference point', () {
      for (final type in IncidentType.values) {
        final incident = makeIncident(
          type: type,
          latitude: ref.latitude,
          longitude: ref.longitude,
        );
        expect(filter.passes(incident), isTrue, reason: 'failed for $type');
      }
    });

    test('passes incident well within a tight threshold', () {
      // Build a filter with a tight 500 m threshold for animalOnRoad.
      final tightFilter = ProximityFilter(
        referencePoint: ref,
        thresholds: {IncidentType.animalOnRoad: 500},
      );

      // ~222 m north (0.002° ≈ 222 m at this latitude).
      final incident = makeIncident(
        type: IncidentType.animalOnRoad,
        latitude: ref.latitude + 0.002,
        longitude: ref.longitude,
      );

      expect(tightFilter.passes(incident), isTrue);
    });

    test('rejects incident just beyond a tight threshold', () {
      final tightFilter = ProximityFilter(
        referencePoint: ref,
        thresholds: {IncidentType.animalOnRoad: 500},
      );

      // ~1 110 m north — beyond 500 m.
      final incident = makeIncident(
        type: IncidentType.animalOnRoad,
        latitude: ref.latitude + 0.01,
        longitude: ref.longitude,
      );

      expect(tightFilter.passes(incident), isFalse);
    });

    test('updateReferencePoint changes which incidents pass', () {
      // Far from ref — rejected.
      final incident = makeIncident(
        type: IncidentType.animalOnRoad,
        latitude: 34.05,
        longitude: -118.24,
      );
      expect(filter.passes(incident), isFalse);

      // Move ref to the incident location — now within 0 m.
      filter.updateReferencePoint(LatLng(34.05, -118.24));
      expect(filter.passes(incident), isTrue);
    });

    test('custom threshold map overrides defaults', () {
      final strictFilter = ProximityFilter(
        referencePoint: ref,
        thresholds: {IncidentType.animalOnRoad: 10}, // 10 m — very tight
      );

      // ~100 m away.
      final incident = makeIncident(
        type: IncidentType.animalOnRoad,
        latitude: ref.latitude + 0.001,
        longitude: ref.longitude,
      );

      expect(strictFilter.passes(incident), isFalse);
    });
  });
}
