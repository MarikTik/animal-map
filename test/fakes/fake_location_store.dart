import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:animal_map/services/location_store.dart';

/// A fake [LocationStore] for testing.
///
/// Returns [storedLocation] from [load] and records [save] calls.
class FakeLocationStore implements LocationStore {
  /// The location that [load] will return.
  LatLng? storedLocation;

  /// The last location passed to [save].
  LatLng? lastSaved;

  /// How many times [save] has been called.
  int saveCallCount = 0;

  @override
  Future<LatLng?> load() async => storedLocation;

  @override
  Future<void> save(LatLng location) async {
    saveCallCount++;
    lastSaved = location;
  }
}
