import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:animal_map/models/animal_type.dart';
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
      final icon = loader.load(AnimalType.deer, size: 96);

      expect(icon, isA<AssetMapBitmap>());
    });

    test('AssetMapBitmap references the correct asset path', () {
      final icon = loader.load(AnimalType.deer, size: 96) as AssetMapBitmap;

      expect(icon.assetName, AnimalType.deer.assetPath);
    });

    test('AssetMapBitmap uses the specified size for width and height', () {
      final icon = loader.load(AnimalType.deer, size: 48) as AssetMapBitmap;

      expect(icon.width, 48);
      expect(icon.height, 48);
    });

    test('different sizes produce different dimensions', () {
      final small = loader.load(AnimalType.deer, size: 24) as AssetMapBitmap;
      final large = loader.load(AnimalType.deer, size: 96) as AssetMapBitmap;

      expect(small.width, isNot(large.width));
    });

    test('returns different instances for different animal types', () {
      final deer = loader.load(AnimalType.deer, size: 96);
      final coyote = loader.load(AnimalType.coyote, size: 96);

      expect(identical(deer, coyote), isFalse);
    });
  });
}
