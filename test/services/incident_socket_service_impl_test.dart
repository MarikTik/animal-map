import 'package:flutter_test/flutter_test.dart';

import 'package:animal_map/services/incident_socket_service_impl.dart';

import '../fakes/incident_factory.dart';

void main() {
  group('IncidentSocketServiceImpl', () {
    test('incidents is a broadcast stream (supports multiple listeners)', () {
      final service = IncidentSocketServiceImpl();
      // Two independent listeners must not throw "already listened to".
      final subA = service.incidents.listen((_) {});
      final subB = service.incidents.listen((_) {});

      expect(subA, isNotNull);
      expect(subB, isNotNull);

      subA.cancel();
      subB.cancel();
    });

    test('inject pushes a synthetic incident to all listeners', () async {
      final service = IncidentSocketServiceImpl();
      final received = <String>[];

      service.incidents.listen((i) => received.add(i.incidentId));

      service.inject(makeIncident(incidentId: 'demo-1'));
      await Future<void>.delayed(Duration.zero);

      expect(received, ['demo-1']);
    });

    test('inject reaches every listener', () async {
      final service = IncidentSocketServiceImpl();
      var countA = 0;
      var countB = 0;

      service.incidents.listen((_) => countA++);
      service.incidents.listen((_) => countB++);

      service.inject(makeIncident());
      await Future<void>.delayed(Duration.zero);

      expect(countA, 1);
      expect(countB, 1);
    });
  });
}
