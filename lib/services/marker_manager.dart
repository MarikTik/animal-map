import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/hazard_type.dart';

/// Signature for callbacks when a marker is tapped.
typedef MarkerTapCallback = void Function(String markerId, HazardType? hazardType);

/// Abstract interface for managing map markers.
///
/// Mixes in [ChangeNotifier] so listeners (e.g. [ListenableBuilder]) are
/// notified whenever the marker set changes, without requiring a full-screen
/// setState.
abstract class MarkerManager with ChangeNotifier {
  /// The current set of markers to display on the map.
  Set<Marker> get markers;

  /// Callback invoked when a marker is tapped.
  MarkerTapCallback? onMarkerTapped;

  /// Creates a marker at [position] with an icon for [hazardType].
  ///
  /// Pass `null` for [hazardType] to use the fallback icon.
  /// Returns the unique marker ID assigned to the new marker.
  String addMarker({
    required LatLng position,
    required HazardType? hazardType,
  });

  /// Removes the marker with the given [markerId].
  void removeMarker(String markerId);

  /// Removes all markers.
  void clear();

  /// Updates the display size of all marker icons.
  ///
  /// When [size] is 0 or negative, [markers] returns an empty set.
  /// When positive, all existing markers are rebuilt with icons
  /// at the given [size].
  void updateMarkerSize(double size);

  /// Temporarily scales a single marker for visual feedback.
  ///
  /// [scale] is a multiplier on the current marker size (1.0 = normal).
  /// Values above 1.0 enlarge the marker; the caller drives the
  /// animation by calling this repeatedly.
  void setMarkerScale(String markerId, {required double scale});
}
