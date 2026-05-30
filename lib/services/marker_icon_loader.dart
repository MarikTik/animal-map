import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/incident_type.dart';

/// Abstract interface for loading marker icons.
///
/// Enables dependency inversion so that callers do not depend on
/// the concrete asset-loading mechanism. Fakes can return
/// [BitmapDescriptor.defaultMarker] for all types in tests.
abstract class MarkerIconLoader {
  /// Returns a [BitmapDescriptor] for the given [incidentType]
  /// rendered at [size] logical pixels.
  ///
  /// When [incidentType] is `null` (unknown animal), returns a
  /// default fallback icon.
  BitmapDescriptor load(IncidentType? incidentType, {required double size});
}
