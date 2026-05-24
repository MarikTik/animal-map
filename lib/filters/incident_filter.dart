import '../models/incident.dart';

/// Decides whether an [Incident] should be shown on the map.
///
/// Implementations can apply any logic — proximity, type allow-list,
/// priority threshold, etc. — as long as [passes] is pure and
/// synchronous.
abstract class IncidentFilter {
  /// Returns `true` if [incident] should be forwarded to the marker layer.
  bool passes(Incident incident);
}
