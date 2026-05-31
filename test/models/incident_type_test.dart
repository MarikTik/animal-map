import 'package:flutter_test/flutter_test.dart';

import 'package:animal_map/models/incident_type.dart';

void main() {
  group('IncidentType', () {
    test('animalOnRoad has a deer asset path', () {
      expect(IncidentType.animalOnRoad.assetPath, 'assets/markers/deer.png');
    });

    test('roadway detection types have a PNG marker asset path', () {
      expect(IncidentType.personOnRoad.assetPath, 'assets/markers/deer.png');
    });

    test('unmapped incident types fall back to default marker', () {
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

    group('alertPhrase', () {
      test('every type has a non-empty alert phrase', () {
        for (final type in IncidentType.values) {
          expect(type.alertPhrase, isNotEmpty, reason: 'failed for $type');
        }
      });

      test('each type carries its expected spoken phrase', () {
        expect(
          IncidentType.animalOnRoad.alertPhrase,
          'Animal on the road ahead',
        );
        expect(
          IncidentType.personOnRoad.alertPhrase,
          'Person on the road ahead',
        );
        expect(
          IncidentType.stoppedVehicle.alertPhrase,
          'Stopped vehicle ahead',
        );
        expect(
          IncidentType.roadObstruction.alertPhrase,
          'Road obstruction ahead',
        );
        expect(IncidentType.unknown.alertPhrase, 'Hazard ahead');
      });
    });
  });
}
