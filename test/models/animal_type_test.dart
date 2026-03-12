import 'package:flutter_test/flutter_test.dart';

import 'package:animal_map/models/animal_type.dart';

void main() {
  group('AnimalType', () {
    test('every value has an asset path matching assets/markers/<name>.png', () {
      for (final type in AnimalType.values) {
        expect(type.assetPath, 'assets/markers/${type.name}.png');
      }
    });

    test('every value has a capitalized label', () {
      for (final type in AnimalType.values) {
        final expected = type.name[0].toUpperCase() + type.name.substring(1);
        expect(type.label, expected);
      }
    });

    test('contains at least three animal types', () {
      expect(AnimalType.values.length, greaterThanOrEqualTo(3));
    });

    group('fromName', () {
      test('returns the correct type for each known name', () {
        for (final type in AnimalType.values) {
          expect(AnimalType.fromName(type.name), type);
        }
      });

      test('is case-insensitive', () {
        expect(AnimalType.fromName('DEER'), AnimalType.deer);
        expect(AnimalType.fromName('Coyote'), AnimalType.coyote);
        expect(AnimalType.fromName('bEaR'), AnimalType.bear);
      });

      test('returns null for unknown animal name', () {
        expect(AnimalType.fromName('unicorn'), isNull);
        expect(AnimalType.fromName(''), isNull);
        expect(AnimalType.fromName('dragon'), isNull);
      });
    });
  });
}
