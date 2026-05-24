import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/incident.dart';
import 'incident_filter.dart';

/// Default per-type radius thresholds in metres.
const Map<IncidentType, double> defaultProximityThresholds = {
  // Animals can wander; alert from further away.
  IncidentType.animalOnRoad: 5000,
  IncidentType.personOnRoad: 2000,
  IncidentType.stoppedVehicle: 2000,
  IncidentType.roadObstruction: 2000,
  IncidentType.unknown: 1000,
};

/// Filters incidents by their straight-line distance from a reference point.
///
/// Each [IncidentType] has its own radius threshold (metres). An incident
/// passes when the haversine distance from [referencePoint] to the incident's
/// location is less than or equal to the threshold for its type. If no
/// threshold is registered for a type the incident is **rejected** — this
/// makes the filter safe by default when new types are introduced.
///
/// The [referencePoint] can be updated at any time (e.g. as the user moves).
class ProximityFilter implements IncidentFilter {
  ProximityFilter({
    required LatLng referencePoint,
    Map<IncidentType, double> thresholds = defaultProximityThresholds,
  })  : _referencePoint = referencePoint,
        _thresholds = Map.unmodifiable(thresholds);

  LatLng _referencePoint;
  final Map<IncidentType, double> _thresholds;

  /// Updates the centre point used for distance calculations.
  void updateReferencePoint(LatLng point) => _referencePoint = point;

  @override
  bool passes(Incident incident) {
    final threshold = _thresholds[incident.type];
    // Reject unknown types.
    if (threshold == null) return false;

    final distance = Geolocator.distanceBetween(
      _referencePoint.latitude,
      _referencePoint.longitude,
      incident.location.latitude,
      incident.location.longitude,
    );

    return distance <= threshold;
  }
}
