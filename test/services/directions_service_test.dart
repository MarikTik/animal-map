import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:animal_map/services/directions_service.dart';

void main() {
  group('DirectionsService.decodePolyline', () {
    test('decodes the canonical Google example', () {
      // From Google's polyline algorithm documentation.
      // "_p~iF~ps|U_ulLnnqC_mqNvxq`@" encodes three points.
      const encoded = '_p~iF~ps|U_ulLnnqC_mqNvxq`@';

      final points = DirectionsService.decodePolyline(encoded);

      expect(points, hasLength(3));
      expect(points[0].latitude, closeTo(38.5, 0.0001));
      expect(points[0].longitude, closeTo(-120.2, 0.0001));
      expect(points[1].latitude, closeTo(40.7, 0.0001));
      expect(points[1].longitude, closeTo(-120.95, 0.0001));
      expect(points[2].latitude, closeTo(43.252, 0.0001));
      expect(points[2].longitude, closeTo(-126.453, 0.0001));
    });

    test('returns an empty list for an empty string', () {
      expect(DirectionsService.decodePolyline(''), isEmpty);
    });

    test('decodes a single point', () {
      // Encode of (38.5, -120.2).
      const encoded = '_p~iF~ps|U';

      final points = DirectionsService.decodePolyline(encoded);

      expect(points, hasLength(1));
      expect(points.first.latitude, closeTo(38.5, 0.0001));
      expect(points.first.longitude, closeTo(-120.2, 0.0001));
    });

    test('produces LatLng instances', () {
      final points = DirectionsService.decodePolyline('_p~iF~ps|U');
      expect(points.first, isA<LatLng>());
    });
  });
}
