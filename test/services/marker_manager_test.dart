import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:animal_map/config/map_config.dart';
import 'package:animal_map/models/hazard_type.dart';
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

      manager.addMarker(position: position, hazardType: HazardType.deer);

      expect(manager.markers.length, 1);
      expect(manager.markers.first.position, position);
    });

    test('addMarker returns a unique ID', () {
      const position = LatLng(33.6846, -117.8265);

      final id1 = manager.addMarker(position: position, hazardType: HazardType.deer);
      final id2 = manager.addMarker(position: position, hazardType: HazardType.fox);

      expect(id1, isNot(id2));
    });

    test('addMarker wires onTap to call onMarkerTapped with correct args', () {
      const position = LatLng(33.6846, -117.8265);

      String? tappedId;
      HazardType? tappedType;
      manager.onMarkerTapped = (id, type) {
        tappedId = id;
        tappedType = type;
      };

      final id = manager.addMarker(position: position, hazardType: HazardType.deer);
      manager.markers.first.onTap!();

      expect(tappedId, id);
      expect(tappedType, HazardType.deer);
    });

    test('addMarker with null animal type calls onMarkerTapped with null', () {
      const position = LatLng(33.6846, -117.8265);

      HazardType? tappedType = HazardType.bear; // sentinel
      manager.onMarkerTapped = (_, type) => tappedType = type;

      manager.addMarker(position: position, hazardType: null);
      manager.markers.first.onTap!();

      expect(tappedType, isNull);
    });

    test('addMarker delegates to icon loader with correct animal type', () {
      const position = LatLng(33.6846, -117.8265);

      manager.addMarker(position: position, hazardType: HazardType.coyote);
      manager.addMarker(position: position, hazardType: null);

      expect(fakeIconLoader.loadedTypes, [HazardType.coyote, null]);
    });

    test('multiple markers appear in the markers set', () {
      manager.addMarker(
        position: const LatLng(33.68, -117.82),
        hazardType: HazardType.deer,
      );
      manager.addMarker(
        position: const LatLng(33.69, -117.83),
        hazardType: HazardType.bear,
      );
      manager.addMarker(
        position: const LatLng(33.70, -117.84),
        hazardType: null,
      );

      expect(manager.markers.length, 3);
    });

    test('removeMarker removes the specified marker', () {
      final id = manager.addMarker(
        position: const LatLng(33.6846, -117.8265),
        hazardType: HazardType.deer,
      );

      manager.removeMarker(id);

      expect(manager.markers, isEmpty);
    });

    test('removeMarker with unknown ID does nothing', () {
      manager.addMarker(
        position: const LatLng(33.6846, -117.8265),
        hazardType: HazardType.deer,
      );

      manager.removeMarker('nonexistent');

      expect(manager.markers.length, 1);
    });

    test('clear removes all markers', () {
      manager.addMarker(
        position: const LatLng(33.68, -117.82),
        hazardType: HazardType.deer,
      );
      manager.addMarker(
        position: const LatLng(33.69, -117.83),
        hazardType: HazardType.bear,
      );

      manager.clear();

      expect(manager.markers, isEmpty);
    });

    test('updateMarkerSize with 0 hides all markers', () {
      manager.addMarker(
        position: const LatLng(33.68, -117.82),
        hazardType: HazardType.deer,
      );

      manager.updateMarkerSize(0);

      expect(manager.markers, isEmpty);
    });

    test('updateMarkerSize with positive size shows markers after being hidden', () {
      manager.addMarker(
        position: const LatLng(33.68, -117.82),
        hazardType: HazardType.deer,
      );

      manager.updateMarkerSize(0);
      expect(manager.markers, isEmpty);

      manager.updateMarkerSize(48);
      expect(manager.markers.length, 1);
    });

    test('updateMarkerSize rebuilds markers with new icon size', () {
      manager.addMarker(
        position: const LatLng(33.68, -117.82),
        hazardType: HazardType.deer,
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
        hazardType: HazardType.deer,
      );

      expect(fakeIconLoader.loadedSizes.last, 48);
    });

    test('setMarkerScale rebuilds marker at scaled size', () {
      final id = manager.addMarker(
        position: const LatLng(33.68, -117.82),
        hazardType: HazardType.deer,
      );

      manager.setMarkerScale(id, scale: 1.3);

      expect(
        fakeIconLoader.loadedSizes.last,
        closeTo(MapConfig.markerSize * 1.3, 0.01),
      );
    });

    test('setMarkerScale with 1.0 restores normal size', () {
      final id = manager.addMarker(
        position: const LatLng(33.68, -117.82),
        hazardType: HazardType.deer,
      );

      manager.setMarkerScale(id, scale: 1.3);
      manager.setMarkerScale(id, scale: 1.0);

      expect(fakeIconLoader.loadedSizes.last, MapConfig.markerSize);
    });

    test('setMarkerScale with unknown ID does nothing', () {
      final loadCount = fakeIconLoader.loadCallCount;

      manager.setMarkerScale('nonexistent', scale: 1.3);

      expect(fakeIconLoader.loadCallCount, loadCount);
    });
  });
}
