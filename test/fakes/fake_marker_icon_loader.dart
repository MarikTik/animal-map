import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:animal_map/models/hazard_type.dart';
import 'package:animal_map/services/marker_icon_loader.dart';

/// A fake [MarkerIconLoader] for testing.
///
/// Returns [BitmapDescriptor.defaultMarker] for all types.
/// Tracks the number of [load] calls and records which types
/// were requested.
class FakeMarkerIconLoader implements MarkerIconLoader {
  /// How many times [load] has been called.
  int loadCallCount = 0;

  /// The animal types that were passed to [load], in order.
  final List<HazardType?> loadedTypes = [];

  /// The sizes that were passed to [load], in order.
  final List<double> loadedSizes = [];

  @override
  BitmapDescriptor load(HazardType? hazardType, {required double size}) {
    loadCallCount++;
    loadedTypes.add(hazardType);
    loadedSizes.add(size);
    return BitmapDescriptor.defaultMarker;
  }
}
