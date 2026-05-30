import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/incident_type.dart';
import 'marker_icon_loader.dart';

/// Loads marker icons from asset PNGs at a specified size.
///
/// Uses [AssetMapBitmap] to let the platform scale large source PNGs
/// to the requested logical pixel size. Returns
/// [BitmapDescriptor.defaultMarker] when the incident type is null or
/// has no asset mapped.
class MarkerIconLoaderImpl implements MarkerIconLoader {
  final Map<(IncidentType?, double), BitmapDescriptor> _cache = {};

  @override
  BitmapDescriptor load(IncidentType? incidentType, {required double size}) {
    final assetPath = incidentType?.assetPath;
    if (assetPath == null) return BitmapDescriptor.defaultMarker;

    return _cache.putIfAbsent(
      (incidentType, size),
      () => AssetMapBitmap(assetPath, width: size, height: size),
    );
  }
}
