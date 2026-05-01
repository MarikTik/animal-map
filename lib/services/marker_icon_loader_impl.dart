import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/hazard_type.dart';
import 'marker_icon_loader.dart';

/// Loads marker icons from asset PNGs at a specified size.
///
/// Uses [AssetMapBitmap] to let the platform scale large source PNGs
/// to the requested logical pixel size. Returns
/// [BitmapDescriptor.defaultMarker] for unknown hazard types.
class MarkerIconLoaderImpl implements MarkerIconLoader {

  final Map<(HazardType?, double), BitmapDescriptor> _cache = {};


  @override
  BitmapDescriptor load(HazardType? hazardType, {required double size}) {
    if (hazardType == null) return BitmapDescriptor.defaultMarker;
    
    return _cache.putIfAbsent(
      (hazardType, size),
      () => AssetMapBitmap(hazardType.assetPath, width: size, height: size),
    );
  }
}
