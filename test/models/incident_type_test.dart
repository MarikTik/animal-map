import 'package:flutter_test/flutter_test.dart';

import 'package:animal_map/models/incident_type.dart';

void main() {
  group('IncidentType', () {
    test('animalOnRoad has a deer asset path', () {
      expect(IncidentType.animalOnRoad.assetPath, 'assets/markers/deer.png');
    });

    test('non-animal types have no asset path (fall back to default marker)', () {
      expect(IncidentType.personOnRoad.assetPath, isNull);
      expect(IncidentType.stoppedVehicle.assetPath, isNull);
      expect(IncidentType.roadObstruction.assetPath, isNull);
      expect(IncidentType.unknown.assetPath, isNull);
    });

    group('jsonValue', () {
      test('each type carries its snake_case wire identifier', () {
        expect(IncidentType.animalOnRoad.jsonValue, 'animal_on_road');
        expect(IncidentType.personOnRoad.jsonValue, 'person_on_road');
        expect(IncidentType.stoppedVehicle.jsonValue, 'stopped_vehicle');
        expect(IncidentType.roadObstruction.jsonValue, 'road_obstruction');
        expect(IncidentType.unknown.jsonValue, 'unknown');
      });
    });

    group('fromJson', () {
      test('round-trips every variant', () {
        for (final type in IncidentType.values) {
          expect(IncidentType.fromJson(type.jsonValue), type);
        }
      });

      test('throws FormatException on unknown value', () {
        expect(
          () => IncidentType.fromJson('not_a_type'),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('label', () {
      test('capitalizes the first word and humanises the rest', () {
        expect(IncidentType.animalOnRoad.label, 'Animal on road');
        expect(IncidentType.personOnRoad.label, 'Person on road');
        expect(IncidentType.stoppedVehicle.label, 'Stopped vehicle');
        expect(IncidentType.roadObstruction.label, 'Road obstruction');
        expect(IncidentType.unknown.label, 'Unknown');
      });
    });
  });
}
