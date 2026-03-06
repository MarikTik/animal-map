import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:animal_map/app.dart';
import 'package:animal_map/config/map_config.dart';

/// BDD scenarios for Story 1: Map renders in the app
void main() {
  group('Story 1 — Map renders in the app', () {
    // Scenario: App launches and map renders
    // Given the app is installed and a valid Google Maps API key is configured
    // When I open the app
    // Then a Google Map is displayed
    // And the map supports pan and zoom
    testWidgets(
      'Scenario: App launches and map renders with pan and zoom',
      (WidgetTester tester) async {
        await tester.pumpWidget(const AnimalMapApp());

        // Then a Google Map is displayed
        expect(find.byType(GoogleMap), findsOneWidget);

        // And the map supports pan and zoom
        final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
        expect(googleMap.zoomGesturesEnabled, isTrue);
        expect(googleMap.scrollGesturesEnabled, isTrue);
        expect(googleMap.rotateGesturesEnabled, isTrue);
        expect(googleMap.tiltGesturesEnabled, isTrue);
      },
    );

    // Scenario: Default camera position
    // Given location permission has not been granted
    // When I open the app
    // Then the map starts at a predefined default location
    // And the zoom level is set appropriately for city-level navigation
    testWidgets(
      'Scenario: Default camera position when location not granted',
      (WidgetTester tester) async {
        await tester.pumpWidget(const AnimalMapApp());

        final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));

        // Then the map starts at a predefined default location
        expect(
          googleMap.initialCameraPosition.target,
          MapConfig.defaultCenter,
        );

        // And the zoom level is set appropriately for city-level navigation
        expect(
          googleMap.initialCameraPosition.zoom,
          MapConfig.defaultZoom,
        );
      },
    );

    // Scenario: Location layer disabled by default
    // Given location permission has not been granted
    // When I open the app
    // Then the "my location" indicator is NOT shown
    testWidgets(
      'Scenario: Location layer disabled when permission not granted',
      (WidgetTester tester) async {
        await tester.pumpWidget(const AnimalMapApp());

        final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));

        expect(googleMap.myLocationEnabled, isFalse);
        expect(googleMap.myLocationButtonEnabled, isFalse);
      },
    );
  });
}
