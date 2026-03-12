import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Abstract interface for retrieving the device's current location.
///
/// Enables dependency inversion so callers don't depend on a specific
/// geolocation library.
abstract class LocationProvider {
  /// Returns the device's current position, or `null` if unavailable.
  Future<LatLng?> getCurrentLocation();
}
