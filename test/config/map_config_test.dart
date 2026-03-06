import 'package:flutter_test/flutter_test.dart';

import 'package:animal_map/config/map_config.dart';

void main() {
  group('MapConfig', () {
    test('defaultCenter is set to Irvine, California', () {
      expect(MapConfig.defaultCenter.latitude, 33.6846);
      expect(MapConfig.defaultCenter.longitude, -117.8265);
    });

    test('defaultZoom is appropriate for city-level navigation', () {
      expect(MapConfig.defaultZoom, 14.0);
    });

    test('minZoom allows zooming out to regional level', () {
      expect(MapConfig.minZoom, 5.0);
    });

    test('maxZoom allows street-level detail', () {
      expect(MapConfig.maxZoom, 20.0);
    });

    test('minZoom is less than maxZoom', () {
      expect(MapConfig.minZoom, lessThan(MapConfig.maxZoom));
    });

    test('defaultZoom is within min/max bounds', () {
      expect(MapConfig.defaultZoom, greaterThanOrEqualTo(MapConfig.minZoom));
      expect(MapConfig.defaultZoom, lessThanOrEqualTo(MapConfig.maxZoom));
    });

    test('initialCameraPosition uses defaultCenter and defaultZoom', () {
      const cameraPosition = MapConfig.initialCameraPosition;

      expect(cameraPosition.target, MapConfig.defaultCenter);
      expect(cameraPosition.zoom, MapConfig.defaultZoom);
    });
  });
}
