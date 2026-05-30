import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:animal_map/models/incident_type.dart';
import 'package:animal_map/services/marker_icon_loader_impl.dart';

void main() {
  group('MarkerIconLoaderImpl', () {
    late MarkerIconLoaderImpl loader;

    setUp(() {
      loader = MarkerIconLoaderImpl();
    });

    test('returns BitmapDescriptor.defaultMarker for null animal type', () {
      final icon = loader.load(null, size: 96);

      expect(icon, BitmapDescriptor.defaultMarker);
    });

    test('returns an AssetMapBitmap for a known animal type', () {
      final icon = loader.load(IncidentType.animalOnRoad, size: 96);

      expect(icon, isA<AssetMapBitmap>());
    });

    test('AssetMapBitmap references the correct asset path', () {
      final icon = loader.load(IncidentType.animalOnRoad, size: 96) as AssetMapBitmap;

      expect(icon.assetName, IncidentType.animalOnRoad.assetPath);
    });

    test('AssetMapBitmap uses the specified size for width and height', () {
      final icon = loader.load(IncidentType.animalOnRoad, size: 48) as AssetMapBitmap;

      expect(icon.width, 48);
      expect(icon.height, 48);
    });

    test('different sizes produce different dimensions', () {
      final small = loader.load(IncidentType.animalOnRoad, size: 24) as AssetMapBitmap;
      final large = loader.load(IncidentType.animalOnRoad, size: 96) as AssetMapBitmap;

      expect(small.width, isNot(large.width));
    });

    test('returns defaultMarker for incident types without an asset path', () {
      // personOnRoad, stoppedVehicle, roadObstruction, unknown all have
      // assetPath == null until proper icons are added.
      expect(
        loader.load(IncidentType.personOnRoad, size: 96),
        BitmapDescriptor.defaultMarker,
      );
      expect(
        loader.load(IncidentType.stoppedVehicle, size: 96),
        BitmapDescriptor.defaultMarker,
      );
      expect(
        loader.load(IncidentType.roadObstruction, size: 96),
        BitmapDescriptor.defaultMarker,
      );
      expect(
        loader.load(IncidentType.unknown, size: 96),
        BitmapDescriptor.defaultMarker,
      );
    });

    test('returns identical instance on repeated call with same args (cache hit)', () {
      final first = loader.load(IncidentType.animalOnRoad, size: 96);
      final second = loader.load(IncidentType.animalOnRoad, size: 96);

      expect(identical(first, second), isTrue);
    });

    test('returns different instance for different size (cache miss)', () {
      final a = loader.load(IncidentType.animalOnRoad, size: 48);
      final b = loader.load(IncidentType.animalOnRoad, size: 96);

      expect(identical(a, b), isFalse);
    });

    test('null hazard type always returns defaultMarker regardless of size', () {
      final a = loader.load(null, size: 48);
      final b = loader.load(null, size: 96);

      expect(a, BitmapDescriptor.defaultMarker);
      expect(b, BitmapDescriptor.defaultMarker);
    });
  });
}
