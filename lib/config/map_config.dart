import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Centralized configuration for the Google Map.
///
/// Provides default camera positioning and zoom constraints.
/// All values are static constants to allow easy overriding
/// via configuration or dependency injection in the future.
class MapConfig {
  MapConfig._();

  /// Default map center when location permission is not granted.
  /// Coordinates: Irvine, California.
  static const LatLng defaultCenter = LatLng(33.6846, -117.8265);

  /// Initial zoom level for city-level navigation.
  static const double defaultZoom = 14.0;

  /// Minimum zoom the user can pinch out to.
  static const double minZoom = 5.0;

  /// Maximum zoom the user can pinch in to.
  static const double maxZoom = 20.0;

  /// The initial camera position used when the map first loads.
  static const CameraPosition initialCameraPosition = CameraPosition(
    target: defaultCenter,
    zoom: defaultZoom,
  );
}
