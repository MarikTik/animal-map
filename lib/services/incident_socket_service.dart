import '../models/incident.dart';

/// Abstract interface for a service that receives [Incident] events
/// from the backend over a long-lived socket connection.
///
/// Consumers listen to [incidents] to receive decoded events; lifecycle
/// is owned by the service via [connect] and [close].
abstract class IncidentSocketService {
  /// Stream of decoded incidents. Empty until [connect] completes
  /// successfully, then emits each incident as it arrives.
  Stream<Incident> get incidents;

  /// Opens the underlying connection. Safe to call only once per
  /// instance; create a new instance to reconnect.
  Future<void> connect();

  /// Closes the underlying connection and the [incidents] stream.
  Future<void> close();
}
