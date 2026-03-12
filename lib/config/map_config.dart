import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Centralized configuration for the Google Map.
///
/// Provides default camera positioning and zoom constraints.
/// All values are static constants to allow easy overriding
/// via configuration or dependency injection in the future.
class MapConfig {
  MapConfig._();

  /// Fallback map center when no user location is available.
  /// Coordinates: UCSD, La Jolla, California.
  static const LatLng fallbackCenter = LatLng(32.8801, -117.2340);

  /// Zoom level used when the user's location is known.
  static const double defaultZoom = 14.0;

  /// Zoom level used when falling back to [fallbackCenter] (country overview).
  static const double fallbackZoom = 5.0;

  /// Minimum zoom the user can pinch out to.
  static const double minZoom = 5.0;

  /// Maximum zoom the user can pinch in to.
  static const double maxZoom = 20.0;

  /// Size of marker icons in logical pixels at full zoom.
  static const double markerSize = 84.0;

  /// Smallest marker size before markers disappear.
  static const double markerMinSize = 24.0;

  /// Zoom level below which markers are fully hidden.
  /// Below this the user is too far to care about individual animals.
  static const double markerHiddenZoom = 14.0;

  /// Zoom level at or above which markers are full size.
  /// At street level the driver needs maximum icon clarity.
  static const double markerFullSizeZoom = 16.0;

  /// Camera position used when no user location is available.
  static const CameraPosition fallbackCameraPosition = CameraPosition(
    target: fallbackCenter,
    zoom: fallbackZoom,
  );

  /// Calculates the marker icon size for a given [zoom] level.
  ///
  /// Smoothly interpolates between [markerMinSize] and [markerSize]
  /// over the range ([markerHiddenZoom], [markerFullSizeZoom]).
  /// Returns 0 below [markerHiddenZoom], and [markerSize] at or
  /// above [markerFullSizeZoom].
  static double markerSizeForZoom(double zoom) {
    final t = ((zoom - markerHiddenZoom) /
            (markerFullSizeZoom - markerHiddenZoom))
        .clamp(0.0, 1.0);
    return t > 0 ? markerMinSize + t * (markerSize - markerMinSize) : 0;
  }
}
