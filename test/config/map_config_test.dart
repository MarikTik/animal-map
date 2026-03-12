import 'package:flutter_test/flutter_test.dart';

import 'package:animal_map/config/map_config.dart';

void main() {
  group('MapConfig', () {
    test('fallbackCenter is set to UCSD, La Jolla', () {
      expect(MapConfig.fallbackCenter.latitude, 32.8801);
      expect(MapConfig.fallbackCenter.longitude, -117.2340);
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

    test('fallbackCameraPosition uses fallbackCenter and fallbackZoom', () {
      const cameraPosition = MapConfig.fallbackCameraPosition;

      expect(cameraPosition.target, MapConfig.fallbackCenter);
      expect(cameraPosition.zoom, MapConfig.fallbackZoom);
    });

    test('markerSize is a positive value', () {
      expect(MapConfig.markerSize, greaterThan(0));
    });

    test('markerMinSize is positive and less than markerSize', () {
      expect(MapConfig.markerMinSize, greaterThan(0));
      expect(MapConfig.markerMinSize, lessThan(MapConfig.markerSize));
    });

    test('markerHiddenZoom is within min/max bounds', () {
      expect(
        MapConfig.markerHiddenZoom,
        greaterThanOrEqualTo(MapConfig.minZoom),
      );
      expect(
        MapConfig.markerHiddenZoom,
        lessThanOrEqualTo(MapConfig.maxZoom),
      );
    });

    test('markerFullSizeZoom is above markerHiddenZoom', () {
      expect(
        MapConfig.markerFullSizeZoom,
        greaterThan(MapConfig.markerHiddenZoom),
      );
    });

    test('fallbackZoom is at or below minZoom boundary', () {
      expect(
        MapConfig.fallbackZoom,
        greaterThanOrEqualTo(MapConfig.minZoom),
      );
    });

    test('defaultZoom is at or above markerHiddenZoom so markers show when located', () {
      expect(
        MapConfig.defaultZoom,
        greaterThanOrEqualTo(MapConfig.markerHiddenZoom),
      );
    });

    group('markerSizeForZoom', () {
      test('returns 0 below markerHiddenZoom', () {
        expect(MapConfig.markerSizeForZoom(MapConfig.markerHiddenZoom - 1), 0);
        expect(MapConfig.markerSizeForZoom(MapConfig.minZoom), 0);
      });

      test('returns close to markerMinSize just above markerHiddenZoom', () {
        final justAbove = MapConfig.markerHiddenZoom + 0.01;
        final size = MapConfig.markerSizeForZoom(justAbove);
        expect(size, greaterThan(0));
        expect(size, lessThan(MapConfig.markerMinSize + 1));
      });

      test('returns markerSize at markerFullSizeZoom', () {
        expect(
          MapConfig.markerSizeForZoom(MapConfig.markerFullSizeZoom),
          MapConfig.markerSize,
        );
      });

      test('returns markerSize above markerFullSizeZoom', () {
        expect(
          MapConfig.markerSizeForZoom(MapConfig.maxZoom),
          MapConfig.markerSize,
        );
      });

      test('mid-range zoom returns a size between min and full', () {
        final midZoom = (MapConfig.markerHiddenZoom +
                MapConfig.markerFullSizeZoom) /
            2;
        final size = MapConfig.markerSizeForZoom(midZoom);

        expect(size, greaterThanOrEqualTo(MapConfig.markerMinSize));
        expect(size, lessThanOrEqualTo(MapConfig.markerSize));
      });

      test('interpolates continuously across the transition range', () {
        final sizes = <double>{};
        for (var z = MapConfig.markerHiddenZoom;
            z < MapConfig.markerFullSizeZoom;
            z += 0.1) {
          sizes.add(MapConfig.markerSizeForZoom(z));
        }
        // Continuous interpolation produces many distinct values.
        expect(sizes.length, greaterThan(5));
      });

      test('increases monotonically with zoom', () {
        double previousSize = 0;
        for (var zoom = MapConfig.markerHiddenZoom;
            zoom <= MapConfig.markerFullSizeZoom;
            zoom += 0.5) {
          final size = MapConfig.markerSizeForZoom(zoom);
          expect(size, greaterThanOrEqualTo(previousSize));
          previousSize = size;
        }
      });
    });
  });
}
