import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:animal_map/config/map_config.dart';
import 'package:animal_map/models/incident_type.dart';
import 'package:animal_map/services/marker_manager_impl.dart';

import '../fakes/fake_marker_icon_loader.dart';

void main() {
  group('MarkerManagerImpl', () {
    late FakeMarkerIconLoader fakeIconLoader;
    late MarkerManagerImpl manager;

    setUp(() {
      fakeIconLoader = FakeMarkerIconLoader();
      manager = MarkerManagerImpl(iconLoader: fakeIconLoader);
    });

    test('starts with an empty marker set', () {
      expect(manager.markers, isEmpty);
    });

    test('addMarker creates a marker at the given position', () {
      const position = LatLng(33.6846, -117.8265);

      manager.addMarker(position: position, incidentType: IncidentType.animalOnRoad);

      expect(manager.markers.length, 1);
      expect(manager.markers.first.position, position);
    });

    test('addMarker returns a unique ID', () {
      const position = LatLng(33.6846, -117.8265);

      final id1 = manager.addMarker(position: position, incidentType: IncidentType.animalOnRoad);
      final id2 = manager.addMarker(position: position, incidentType: IncidentType.animalOnRoad);

      expect(id1, isNot(id2));
    });

    test('addMarker wires onTap to call onMarkerTapped with correct args', () {
      const position = LatLng(33.6846, -117.8265);

      String? tappedId;
      IncidentType? tappedType;
      manager.onMarkerTapped = (id, type) {
        tappedId = id;
        tappedType = type;
      };

      final id = manager.addMarker(position: position, incidentType: IncidentType.animalOnRoad);
      manager.markers.first.onTap!();

      expect(tappedId, id);
      expect(tappedType, IncidentType.animalOnRoad);
    });

    test('addMarker with null animal type calls onMarkerTapped with null', () {
      const position = LatLng(33.6846, -117.8265);

      IncidentType? tappedType = IncidentType.animalOnRoad; // sentinel
      manager.onMarkerTapped = (_, type) => tappedType = type;

      manager.addMarker(position: position, incidentType: null);
      manager.markers.first.onTap!();

      expect(tappedType, isNull);
    });

    test('addMarker delegates to icon loader with correct animal type', () {
      const position = LatLng(33.6846, -117.8265);

      manager.addMarker(position: position, incidentType: IncidentType.animalOnRoad);
      manager.addMarker(position: position, incidentType: null);

      expect(fakeIconLoader.loadedTypes, [IncidentType.animalOnRoad, null]);
    });

    test('multiple markers appear in the markers set', () {
      manager.addMarker(
        position: const LatLng(33.68, -117.82),
        incidentType: IncidentType.animalOnRoad,
      );
      manager.addMarker(
        position: const LatLng(33.69, -117.83),
        incidentType: IncidentType.animalOnRoad,
      );
      manager.addMarker(
        position: const LatLng(33.70, -117.84),
        incidentType: null,
      );

      expect(manager.markers.length, 3);
    });

    test('removeMarker removes the specified marker', () {
      final id = manager.addMarker(
        position: const LatLng(33.6846, -117.8265),
        incidentType: IncidentType.animalOnRoad,
      );

      manager.removeMarker(id);

      expect(manager.markers, isEmpty);
    });

    test('removeMarker with unknown ID does nothing', () {
      manager.addMarker(
        position: const LatLng(33.6846, -117.8265),
        incidentType: IncidentType.animalOnRoad,
      );

      manager.removeMarker('nonexistent');

      expect(manager.markers.length, 1);
    });

    test('clear removes all markers', () {
      manager.addMarker(
        position: const LatLng(33.68, -117.82),
        incidentType: IncidentType.animalOnRoad,
      );
      manager.addMarker(
        position: const LatLng(33.69, -117.83),
        incidentType: IncidentType.animalOnRoad,
      );

      manager.clear();

      expect(manager.markers, isEmpty);
    });

    test('updateMarkerSize with 0 hides all markers', () {
      manager.addMarker(
        position: const LatLng(33.68, -117.82),
        incidentType: IncidentType.animalOnRoad,
      );

      manager.updateMarkerSize(0);

      expect(manager.markers, isEmpty);
    });

    test('updateMarkerSize with positive size shows markers after being hidden', () {
      manager.addMarker(
        position: const LatLng(33.68, -117.82),
        incidentType: IncidentType.animalOnRoad,
      );

      manager.updateMarkerSize(0);
      expect(manager.markers, isEmpty);

      manager.updateMarkerSize(48);
      expect(manager.markers.length, 1);
    });

    test('updateMarkerSize rebuilds markers with new icon size', () {
      manager.addMarker(
        position: const LatLng(33.68, -117.82),
        incidentType: IncidentType.animalOnRoad,
      );

      final initialLoadCount = fakeIconLoader.loadCallCount;

      manager.updateMarkerSize(48);

      expect(fakeIconLoader.loadCallCount, initialLoadCount + 1);
      expect(fakeIconLoader.loadedSizes.last, 48);
    });

    test('markers added after updateMarkerSize use the current size', () {
      manager.updateMarkerSize(48);

      manager.addMarker(
        position: const LatLng(33.68, -117.82),
        incidentType: IncidentType.animalOnRoad,
      );

      expect(fakeIconLoader.loadedSizes.last, 48);
    });

    test('setMarkerScale rebuilds marker at bucketed scaled size', () {
      final id = manager.addMarker(
        position: const LatLng(33.68, -117.82),
        incidentType: IncidentType.animalOnRoad,
      );

      manager.setMarkerScale(id, scale: 1.3);

      // 84 * 1.3 = 109.2 → bucketed to nearest 8 = 112.
      final bucketed = ((MapConfig.markerSize * 1.3) / 8).round() * 8.0;
      expect(fakeIconLoader.loadedSizes.last, bucketed);
    });

    test('setMarkerScale with 1.0 restores to bucketed normal size', () {
      final id = manager.addMarker(
        position: const LatLng(33.68, -117.82),
        incidentType: IncidentType.animalOnRoad,
      );

      manager.setMarkerScale(id, scale: 1.3);
      manager.setMarkerScale(id, scale: 1.0);

      // 84 * 1.0 = 84 → bucketed to nearest 8 = 88.
      final bucketed = (MapConfig.markerSize / 8).round() * 8.0;
      expect(fakeIconLoader.loadedSizes.last, bucketed);
    });

    test('setMarkerScale with unknown ID does nothing', () {
      final loadCount = fakeIconLoader.loadCallCount;

      manager.setMarkerScale('nonexistent', scale: 1.3);

      expect(fakeIconLoader.loadCallCount, loadCount);
    });

    group('skip-rebuild optimisation', () {
      test('updateMarkerSize does not reload icon when bucketed size unchanged', () {
        manager.addMarker(
          position: const LatLng(33.68, -117.82),
          incidentType: IncidentType.animalOnRoad,
        );

        // Both sizes round to the same 8-px bucket (48).
        manager.updateMarkerSize(48);
        final countAfterFirst = fakeIconLoader.loadCallCount;
        manager.updateMarkerSize(48);

        expect(fakeIconLoader.loadCallCount, countAfterFirst);
      });

      test('updateMarkerSize reloads icon when bucketed size changes', () {
        manager.addMarker(
          position: const LatLng(33.68, -117.82),
          incidentType: IncidentType.animalOnRoad,
        );

        manager.updateMarkerSize(48);
        final countAfterFirst = fakeIconLoader.loadCallCount;
        manager.updateMarkerSize(56); // different bucket

        expect(fakeIconLoader.loadCallCount, greaterThan(countAfterFirst));
      });

      test('markers getter returns same Set instance when nothing changed', () {
        manager.addMarker(
          position: const LatLng(33.68, -117.82),
          incidentType: IncidentType.animalOnRoad,
        );

        final first = manager.markers;
        final second = manager.markers;

        expect(identical(first, second), isTrue);
      });

      test('markers getter returns new Set instance after mutation', () {
        manager.addMarker(
          position: const LatLng(33.68, -117.82),
          incidentType: IncidentType.animalOnRoad,
        );

        final before = manager.markers;
        manager.addMarker(
          position: const LatLng(33.69, -117.83),
          incidentType: IncidentType.animalOnRoad,
        );
        final after = manager.markers;

        expect(identical(before, after), isFalse);
      });
    });

    group('ChangeNotifier', () {
      test('notifies listeners when a marker is added', () {
        var notified = false;
        manager.addListener(() => notified = true);

        manager.addMarker(
          position: const LatLng(33.68, -117.82),
          incidentType: IncidentType.animalOnRoad,
        );

        expect(notified, isTrue);
      });

      test('notifies listeners when a marker is removed', () {
        final id = manager.addMarker(
          position: const LatLng(33.68, -117.82),
          incidentType: IncidentType.animalOnRoad,
        );

        var notified = false;
        manager.addListener(() => notified = true);
        manager.removeMarker(id);

        expect(notified, isTrue);
      });

      test('notifies listeners when markers are cleared', () {
        manager.addMarker(
          position: const LatLng(33.68, -117.82),
          incidentType: IncidentType.animalOnRoad,
        );

        var notified = false;
        manager.addListener(() => notified = true);
        manager.clear();

        expect(notified, isTrue);
      });

      test('notifies listeners when marker size changes bucket', () {
        manager.addMarker(
          position: const LatLng(33.68, -117.82),
          incidentType: IncidentType.animalOnRoad,
        );

        manager.updateMarkerSize(48);
        var notified = false;
        manager.addListener(() => notified = true);
        manager.updateMarkerSize(56);

        expect(notified, isTrue);
      });

      test('does not notify listeners when bucketed size is unchanged', () {
        manager.addMarker(
          position: const LatLng(33.68, -117.82),
          incidentType: IncidentType.animalOnRoad,
        );

        manager.updateMarkerSize(48);
        var notified = false;
        manager.addListener(() => notified = true);
        manager.updateMarkerSize(48);

        expect(notified, isFalse);
      });
    });
  });
}
