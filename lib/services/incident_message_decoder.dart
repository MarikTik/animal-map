import 'dart:convert';

import '../models/incident.dart';

/// Decodes a raw WebSocket text frame into an [Incident].
///
/// Pure: no I/O, no streams, no async. Holds no state. Exists as a
/// class (rather than a top-level function) so it can be substituted
/// in tests of [IncidentSocketService] implementations and so future
/// schema variants can be expressed as alternative implementations.
class IncidentMessageDecoder {
  const IncidentMessageDecoder();

  /// Parses [raw] as JSON and constructs an [Incident].
  ///
  /// Throws [FormatException] if [raw] is not valid JSON, is not a
  /// JSON object, or does not conform to the [Incident] schema.
  Incident decode(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('Expected a JSON object at the root.');
    }
    return Incident.fromJson(Map<String, dynamic>.from(decoded));
  }
}
