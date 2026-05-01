import 'package:flutter_test/flutter_test.dart';

import 'package:animal_map/models/hazard_type.dart';

void main() {
  group('HazardType', () {
    test('every value has an asset path matching assets/markers/<name>.png', () {
      for (final type in HazardType.values) {
        expect(type.assetPath, 'assets/markers/${type.name}.png');
      }
    });

    test('every value has a capitalized label', () {
      for (final type in HazardType.values) {
        final expected = type.name[0].toUpperCase() + type.name.substring(1);
        expect(type.label, expected);
      }
    });

    test('contains at least three animal types', () {
      expect(HazardType.values.length, greaterThanOrEqualTo(3));
    });

    group('fromName', () {
      test('returns the correct type for each known name', () {
        for (final type in HazardType.values) {
          expect(HazardType.fromName(type.name), type);
        }
      });

      test('is case-insensitive', () {
        expect(HazardType.fromName('DEER'), HazardType.deer);
        expect(HazardType.fromName('Coyote'), HazardType.coyote);
        expect(HazardType.fromName('bEaR'), HazardType.bear);
      });

      test('returns null for unknown animal name', () {
        expect(HazardType.fromName('unicorn'), isNull);
        expect(HazardType.fromName(''), isNull);
        expect(HazardType.fromName('dragon'), isNull);
      });
    });
  });
}
