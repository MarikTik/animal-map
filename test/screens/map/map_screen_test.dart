import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:animal_map/config/map_config.dart';
import 'package:animal_map/screens/map/map_screen.dart';

void main() {
  group('MapScreen', () {
    testWidgets('renders a Scaffold with AppBar titled "Animal Map"', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MapScreen()));

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Animal Map'), findsOneWidget);
    });

    testWidgets('contains a GoogleMap widget', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MapScreen()));

      expect(find.byType(GoogleMap), findsOneWidget);
    });

    testWidgets('GoogleMap uses MapConfig initial camera position', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MapScreen()));

      final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));

      expect(
        googleMap.initialCameraPosition.target,
        MapConfig.defaultCenter,
      );
      expect(
        googleMap.initialCameraPosition.zoom,
        MapConfig.defaultZoom,
      );
    });

    testWidgets('GoogleMap has zoom gestures enabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MapScreen()));

      final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));

      expect(googleMap.zoomGesturesEnabled, isTrue);
      expect(googleMap.scrollGesturesEnabled, isTrue);
    });

    testWidgets('GoogleMap has min/max zoom set from MapConfig', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MapScreen()));

      final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));

      expect(googleMap.minMaxZoomPreference.minZoom, MapConfig.minZoom);
      expect(googleMap.minMaxZoomPreference.maxZoom, MapConfig.maxZoom);
    });

    testWidgets('myLocation is disabled by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MapScreen()));

      final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));

      expect(googleMap.myLocationEnabled, isFalse);
      expect(googleMap.myLocationButtonEnabled, isFalse);
    });
  });
}
