import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:animal_map/app.dart';
import 'package:animal_map/config/map_config.dart';

import '../../fakes/fake_location_permission_service.dart';
import '../../fakes/fake_location_provider.dart';
import '../../fakes/fake_location_store.dart';
import '../../fakes/fake_marker_manager.dart';

/// BDD scenarios for Story 1: Map renders in the app
void main() {
  group('Story 1 — Map renders in the app', () {
    late FakeLocationPermissionService fakePermissionService;
    late FakeLocationProvider fakeLocationProvider;
    late FakeLocationStore fakeLocationStore;
    late FakeMarkerManager fakeMarkerManager;

    setUp(() {
      fakePermissionService = FakeLocationPermissionService();
      fakeLocationProvider = FakeLocationProvider();
      fakeLocationStore = FakeLocationStore();
      fakeMarkerManager = FakeMarkerManager();
    });

    // Scenario: App launches and map renders
    // Given the app is installed and a valid Google Maps API key is configured
    // When I open the app
    // Then a Google Map is displayed
    // And the map supports pan and zoom
    testWidgets(
      'Scenario: App launches and map renders with pan and zoom',
      (WidgetTester tester) async {
        await tester.pumpWidget(AnimalMapApp(
          locationPermissionService: fakePermissionService,
          locationProvider: fakeLocationProvider,
          locationStore: fakeLocationStore,
          markerManager: fakeMarkerManager,
        ));
        await tester.pumpAndSettle();

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
      'Scenario: Fallback camera position when location not granted',
      (WidgetTester tester) async {
        fakePermissionService.statusAfterRequest = PermissionStatus.denied;

        await tester.pumpWidget(AnimalMapApp(
          locationPermissionService: fakePermissionService,
          locationProvider: fakeLocationProvider,
          locationStore: fakeLocationStore,
          markerManager: fakeMarkerManager,
        ));
        await tester.pumpAndSettle();

        final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));

        // Then the map starts at the fallback location
        expect(
          googleMap.initialCameraPosition.target,
          MapConfig.fallbackCenter,
        );

        // And the zoom level is set to country overview
        expect(
          googleMap.initialCameraPosition.zoom,
          MapConfig.fallbackZoom,
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
        fakePermissionService.statusAfterRequest = PermissionStatus.denied;

        await tester.pumpWidget(AnimalMapApp(
          locationPermissionService: fakePermissionService,
          locationProvider: fakeLocationProvider,
          locationStore: fakeLocationStore,
          markerManager: fakeMarkerManager,
        ));
        await tester.pumpAndSettle();
      },
    );

    // Scenario: Location layer enabled
    // Given location permission is granted
    // When the app loads the map
    // Then the "my location" indicator is shown
    testWidgets(
      'Scenario: Location layer enabled when permission granted',
      (WidgetTester tester) async {
        fakePermissionService.statusAfterRequest = PermissionStatus.granted;

        await tester.pumpWidget(AnimalMapApp(
          locationPermissionService: fakePermissionService,
          locationProvider: fakeLocationProvider,
          locationStore: fakeLocationStore,
          markerManager: fakeMarkerManager,
        ));
        await tester.pumpAndSettle();

        final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));

        expect(googleMap.myLocationEnabled, isTrue);
        expect(googleMap.myLocationButtonEnabled, isTrue);
      },
    );
  });
}
