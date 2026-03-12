import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Abstract interface for persisting the user's last known location.
///
/// A real implementation would back this with a database or
/// shared preferences. The current stub always returns `null`.
abstract class LocationStore {
  /// Loads the most recently saved location, or `null` if none exists.
  Future<LatLng?> load();

  /// Saves [location] for later retrieval.
  Future<void> save(LatLng location);
}
