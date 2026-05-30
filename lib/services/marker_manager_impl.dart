import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../config/map_config.dart';
import '../models/incident_type.dart';
import 'marker_icon_loader.dart';
import 'marker_manager.dart';

/// Concrete [MarkerManager] that delegates icon loading to a
/// [MarkerIconLoader] and maintains an ID-keyed marker map.
///
/// Marker IDs are monotonically increasing to guarantee uniqueness
/// within a single session. Supports dynamic resizing of marker
/// icons via [updateMarkerSize] for zoom-dependent scaling.
class MarkerManagerImpl extends MarkerManager {
  MarkerManagerImpl({required MarkerIconLoader iconLoader})
      : _iconLoader = iconLoader;

  final MarkerIconLoader _iconLoader;
  final Map<String, _MarkerEntry> _entries = {};
  final Map<String, Marker> _markers = {};
  Set<Marker>? _markersCache;
  int _nextId = 0;
  double _currentSize = MapConfig.markerSize;

  @override
  Set<Marker> get markers {
    if (_currentSize <= 0) return const {};
    return _markersCache ??= _markers.values.toSet();
  }

  void _invalidateCache() {
    _markersCache = null;
    notifyListeners();
  }

  @override
  String addMarker({
    required LatLng position,
    required IncidentType? incidentType,
  }) {
    final id = 'marker_${_nextId++}';
    final entry = _MarkerEntry(position: position, incidentType: incidentType)
      ..builtAtSize = _bucket(_currentSize);
    _entries[id] = entry;
    _markers[id] = _buildMarker(id, position, incidentType);
    _invalidateCache();
    return id;
  }

  @override
  void removeMarker(String markerId) {
    _entries.remove(markerId);
    _markers.remove(markerId);
    _invalidateCache();
  }

  @override
  void clear() {
    _entries.clear();
    _markers.clear();
    _invalidateCache();
  }

  @override
  void updateMarkerSize(double size) {
    _currentSize = size;
    if (size <= 0) {
      _invalidateCache();
      return;
    }
    _rebuildMarkers();
  }

  @override
  void setMarkerScale(String markerId, {required double scale}) {
    final entry = _entries[markerId];
    if (entry == null) return;
    _markers[markerId] = _buildMarker(
      markerId,
      entry.position,
      entry.incidentType,
      sizeOverride: _currentSize * scale,
    );
    _invalidateCache();
  }

  void _rebuildMarkers() {
    final bucketedSize = _bucket(_currentSize);
    var anyRebuilt = false;
    for (final entry in _entries.entries) {
      if (entry.value.builtAtSize == bucketedSize) continue;
      _markers[entry.key] = _buildMarker(
        entry.key,
        entry.value.position,
        entry.value.incidentType,
      );
      entry.value.builtAtSize = bucketedSize;
      anyRebuilt = true;
    }
    if (anyRebuilt) _invalidateCache();
  }

  static double _bucket(double size) => (size / 8).round() * 8.0;

  Marker _buildMarker(
    String id,
    LatLng position,
    IncidentType? incidentType, {
    double? sizeOverride,
  }) {
    return Marker(
      markerId: MarkerId(id),
      position: position,
      icon: _iconLoader.load(incidentType, size: _bucket(sizeOverride ?? _currentSize)),
      onTap: () => onMarkerTapped?.call(id, incidentType),
    );
  }
}

class _MarkerEntry {
  _MarkerEntry({required this.position, required this.incidentType});
  final LatLng position;
  final IncidentType? incidentType;
  double builtAtSize = -1;
}
