import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../config/map_config.dart';
import '../models/hazard_type.dart';
import 'marker_icon_loader.dart';
import 'marker_manager.dart';

/// Concrete [MarkerManager] that delegates icon loading to a
/// [MarkerIconLoader] and maintains an ID-keyed marker map.
///
/// Marker IDs are monotonically increasing to guarantee uniqueness
/// within a single session. Supports dynamic resizing of marker
/// icons via [updateMarkerSize] for zoom-dependent scaling.
class MarkerManagerImpl implements MarkerManager {
  MarkerManagerImpl({required MarkerIconLoader iconLoader})
      : _iconLoader = iconLoader;

  final MarkerIconLoader _iconLoader;
  final Map<String, _MarkerEntry> _entries = {};
  final Map<String, Marker> _markers = {};
  int _nextId = 0;
  double _currentSize = MapConfig.markerSize;

  @override
  MarkerTapCallback? onMarkerTapped;

  @override
  Set<Marker> get markers => _currentSize > 0 ? _markers.values.toSet() : {};

  @override
  String addMarker({
    required LatLng position,
    required HazardType? hazardType,
  }) {
    final id = 'marker_${_nextId++}';
    _entries[id] = _MarkerEntry(position: position, hazardType: hazardType);
    _markers[id] = _buildMarker(id, position, hazardType);
    return id;
  }

  @override
  void removeMarker(String markerId) {
    _entries.remove(markerId);
    _markers.remove(markerId);
  }

  @override
  void clear() {
    _entries.clear();
    _markers.clear();
  }

  @override
  void updateMarkerSize(double size) {
    _currentSize = size;
    if (size <= 0) return;
    _rebuildMarkers();
  }

  @override
  void setMarkerScale(String markerId, {required double scale}) {
    final entry = _entries[markerId];
    if (entry == null) return;
    _markers[markerId] = _buildMarker(
      markerId,
      entry.position,
      entry.hazardType,
      sizeOverride: _currentSize * scale,
    );
  }

  void _rebuildMarkers() {
    _markers.clear();
    for (final entry in _entries.entries) {
      _markers[entry.key] = _buildMarker(
        entry.key,
        entry.value.position,
        entry.value.hazardType,
      );
    }
  }

  Marker _buildMarker(
    String id,
    LatLng position,
    HazardType? hazardType, {
    double? sizeOverride,
  }) {
    return Marker(
      markerId: MarkerId(id),
      position: position,
      icon: _iconLoader.load(hazardType, size: sizeOverride ?? _currentSize),
      onTap: () => onMarkerTapped?.call(id, hazardType),
    );
  }
}

class _MarkerEntry {
  const _MarkerEntry({required this.position, required this.hazardType});
  final LatLng position;
  final HazardType? hazardType;
}
