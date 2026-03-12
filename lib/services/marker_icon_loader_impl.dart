import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/animal_type.dart';
import 'marker_icon_loader.dart';

/// Loads marker icons from asset PNGs at a specified size.
///
/// Uses [AssetMapBitmap] to let the platform scale large source PNGs
/// to the requested logical pixel size. Returns
/// [BitmapDescriptor.defaultMarker] for unknown animal types.
class MarkerIconLoaderImpl implements MarkerIconLoader {
  @override
  BitmapDescriptor load(AnimalType? animalType, {required double size}) {
    if (animalType == null) return BitmapDescriptor.defaultMarker;

    return AssetMapBitmap(
      animalType.assetPath,
      width: size,
      height: size,
    );
  }
}
