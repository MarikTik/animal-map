import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/animal_type.dart';

/// Abstract interface for loading marker icons.
///
/// Enables dependency inversion so that callers do not depend on
/// the concrete asset-loading mechanism. Fakes can return
/// [BitmapDescriptor.defaultMarker] for all types in tests.
abstract class MarkerIconLoader {
  /// Returns a [BitmapDescriptor] for the given [animalType]
  /// rendered at [size] logical pixels.
  ///
  /// When [animalType] is `null` (unknown animal), returns a
  /// default fallback icon.
  BitmapDescriptor load(AnimalType? animalType, {required double size});
}
