import 'package:animal_map/models/incident.dart';

/// Builds a minimal valid [Incident] for use in tests.
///
/// All fields default to sensible values; override only what the test cares
/// about.
Incident makeIncident({
  String incidentId = 'test-id',
  IncidentType type = IncidentType.animalOnRoad,
  double latitude = 32.88,
  double longitude = -117.23,
  IncidentPriority priority = IncidentPriority.low,
}) {
  return Incident(
    incidentId: incidentId,
    type: type,
    occurredAt: DateTime(2024),
    reportedAt: DateTime(2024),
    location: IncidentLocation(
      latitude: latitude,
      longitude: longitude,
      roadName: null,
      direction: null,
      mileMarker: null,
      cameraId: 'cam-1',
    ),
    recommendedAction: RecommendedAction(
      priority: priority,
      message: 'Test message',
    ),
    evidence: const IncidentEvidence(
      snapshotUrl: null,
      videoClipUrl: null,
    ),
  );
}
