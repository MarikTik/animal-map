import 'dart:async';

import 'package:animal_map/models/incident.dart';
import 'package:animal_map/services/incident_socket_service.dart';

/// A fake [IncidentSocketService] that lets tests push incidents manually.
class FakeIncidentSocketService implements IncidentSocketService {
  final StreamController<Incident> _controller = StreamController<Incident>();

  bool connectCalled = false;
  bool closeCalled = false;

  @override
  Stream<Incident> get incidents => _controller.stream;

  @override
  Future<void> connect() async => connectCalled = true;

  @override
  Future<void> close() async {
    closeCalled = true;
    await _controller.close();
  }

  /// Pushes an incident into the stream (simulates a server message).
  void emit(Incident incident) => _controller.add(incident);

  /// Pushes an error into the stream.
  void emitError(Object error) => _controller.addError(error);
}
