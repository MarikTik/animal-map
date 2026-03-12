import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:animal_map/services/location_provider.dart';

/// A fake [LocationProvider] for testing.
///
/// Returns [locationToReturn] when [getCurrentLocation] is called.
/// Defaults to `null` (no location available).
class FakeLocationProvider implements LocationProvider {
  /// The location that [getCurrentLocation] will return.
  LatLng? locationToReturn;

  /// How many times [getCurrentLocation] has been called.
  int callCount = 0;

  @override
  Future<LatLng?> getCurrentLocation() async {
    callCount++;
    return locationToReturn;
  }
}
