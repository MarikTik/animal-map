import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'location_store.dart';

/// Stub [LocationStore] that never returns a stored location.
///
/// Placeholder until a real persistence layer (e.g. shared_preferences,
/// SQLite) is implemented.
class LocationStoreStub implements LocationStore {
  @override
  Future<LatLng?> load() async => null;

  @override
  Future<void> save(LatLng location) async {}
}
