import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:animal_map/models/hazard_type.dart';
import 'package:animal_map/services/marker_manager.dart';

/// A fake [MarkerManager] for testing.
///
/// Records all operations so tests can verify call counts,
/// arguments, and marker state without depending on a real
/// [MarkerIconLoader].
class FakeMarkerManager extends MarkerManager {
  /// All markers added via [addMarker], in order.
  final List<({LatLng position, HazardType? hazardType})> addedMarkers = [];

  /// How many times [removeMarker] has been called.
  int removeCallCount = 0;

  /// How many times [clear] has been called.
  int clearCallCount = 0;

  /// How many times [updateMarkerSize] has been called.
  int updateSizeCallCount = 0;

  /// The last size passed to [updateMarkerSize].
  double lastSize = 96.0;

  /// The last marker ID passed to [setMarkerScale].
  String? lastScaledId;

  /// How many times [setMarkerScale] has been called.
  int scaleCallCount = 0;

  /// The last scale passed to [setMarkerScale].
  double lastScale = 1.0;

  final Map<String, Marker> _markers = {};
  final Map<String, HazardType?> _hazardTypes = {};
  int _nextId = 0;

  @override
  Set<Marker> get markers => lastSize > 0 ? _markers.values.toSet() : {};

  @override
  String addMarker({
    required LatLng position,
    required HazardType? hazardType,
  }) {
    final id = 'fake_marker_${_nextId++}';
    addedMarkers.add((position: position, hazardType: hazardType));
    _hazardTypes[id] = hazardType;
    _markers[id] = Marker(
      markerId: MarkerId(id),
      position: position,
      onTap: () => onMarkerTapped?.call(id, hazardType),
    );
    notifyListeners();
    return id;
  }

  @override
  void removeMarker(String markerId) {
    removeCallCount++;
    _markers.remove(markerId);
    notifyListeners();
  }

  @override
  void clear() {
    clearCallCount++;
    _markers.clear();
    notifyListeners();
  }

  @override
  void updateMarkerSize(double size) {
    updateSizeCallCount++;
    lastSize = size;
    notifyListeners();
  }

  @override
  void setMarkerScale(String markerId, {required double scale}) {
    scaleCallCount++;
    lastScaledId = markerId;
    lastScale = scale;
    notifyListeners();
  }
}
