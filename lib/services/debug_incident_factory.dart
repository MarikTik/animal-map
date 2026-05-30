import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/incident.dart';

/// Builds synthetic [Incident]s for demos — placed a short distance from a
/// reference point so they pass a proximity filter centred on the user.
class DebugIncidentFactory {
  DebugIncidentFactory({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Approximate metres-per-degree of latitude (constant enough for a demo).
  static const double _metersPerDegLat = 111000;

  /// Creates an incident roughly [offsetMeters] north-ish of [near], with a
  /// random [IncidentType].
  Incident near(LatLng near, {double offsetMeters = 250}) {
    final type = IncidentType
        .values[_random.nextInt(IncidentType.values.length)];

    // Small offset so it lands near the user but not exactly on them.
    final dLat = offsetMeters / _metersPerDegLat;
    final now = DateTime.now();

    return Incident(
      incidentId: 'debug-${now.microsecondsSinceEpoch}',
      type: type,
      occurredAt: now,
      reportedAt: now,
      location: IncidentLocation(
        latitude: near.latitude + dLat,
        longitude: near.longitude,
        roadName: 'Demo Road',
        direction: null,
        mileMarker: null,
        cameraId: 'demo-cam',
      ),
      recommendedAction: const RecommendedAction(
        priority: IncidentPriority.medium,
        message: 'Demo incident',
      ),
      evidence: const IncidentEvidence(snapshotUrl: null, videoClipUrl: null),
    );
  }
}
