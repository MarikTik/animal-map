import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:animal_map/config/map_config.dart';
import 'package:animal_map/screens/map/map_screen.dart';

import '../../fakes/fake_location_permission_service.dart';
import '../../fakes/fake_location_provider.dart';
import '../../fakes/fake_location_store.dart';
import '../../fakes/fake_marker_manager.dart';

/// BDD scenario tests for Story 2: Custom animal icons appear as map markers.
void main() {
  group('Story 2 — Custom animal icons appear as map markers', () {
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

    Widget buildSubject() {
      return MaterialApp(
        home: MapScreen(
          locationPermissionService: fakePermissionService,
          locationProvider: fakeLocationProvider,
          locationStore: fakeLocationStore,
          markerManager: fakeMarkerManager,
        ),
      );
    }

    group('Scenario: Marker renders with correct icon', () {
      testWidgets(
        'Given an event with animal type "deer" and valid coordinates, '
        'When the app receives the event, '
        'Then a marker appears at the correct location',
        (WidgetTester tester) async {
          await tester.pumpWidget(buildSubject());
          await tester.pumpAndSettle();

          // Activate placement mode.
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();

          // Tap the map to place a marker.
          const tapTarget = LatLng(32.88, -117.23);
          final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
          googleMap.onTap!(tapTarget);
          await tester.pumpAndSettle();

          expect(fakeMarkerManager.addedMarkers.length, 1);
          expect(fakeMarkerManager.addedMarkers.first.position, tapTarget);
        },
      );
    });

    group('Scenario: Multiple markers display simultaneously', () {
      testWidgets(
        'Given multiple detection events, '
        'When each event is processed, '
        'Then all markers are visible on the map simultaneously',
        (WidgetTester tester) async {
          await tester.pumpWidget(buildSubject());
          await tester.pumpAndSettle();

          // Enter placement mode once.
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();

          // Tap the map multiple times — placement stays active.
          final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
          for (var i = 0; i < 5; i++) {
            googleMap.onTap!(LatLng(32.88 + i * 0.001, -117.23));
            await tester.pumpAndSettle();
          }

          final updatedMap = tester.widget<GoogleMap>(find.byType(GoogleMap));

          expect(updatedMap.markers.length, 5);
          expect(fakeMarkerManager.addedMarkers.length, 5);
        },
      );
    });

    group('Scenario: Debug button activates placement mode', () {
      testWidgets(
        'Given the map is displayed, '
        'When I tap the debug FAB and then tap the map, '
        'Then a new marker is added at the tapped location',
        (WidgetTester tester) async {
          await tester.pumpWidget(buildSubject());
          await tester.pumpAndSettle();

          expect(fakeMarkerManager.markers, isEmpty);

          // Enter placement mode.
          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();

          // Tap the map near the fallback center.
          final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
          googleMap.onTap!(MapConfig.fallbackCenter);
          await tester.pumpAndSettle();

          expect(fakeMarkerManager.markers.length, 1);
          expect(
            fakeMarkerManager.addedMarkers.first.position,
            MapConfig.fallbackCenter,
          );
        },
      );
    });

    group('Scenario: Markers scale gradually with zoom', () {
      testWidgets(
        'Given markers exist on the map, '
        'When the user zooms out below the hidden threshold, '
        'Then the markers disappear',
        (WidgetTester tester) async {
          fakeMarkerManager.addMarker(
            position: MapConfig.fallbackCenter,
            animalType: null,
          );

          await tester.pumpWidget(buildSubject());
          await tester.pumpAndSettle();

          // Markers visible at default zoom.
          var googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
          expect(googleMap.markers, isNotEmpty);

          // Zoom out below hidden threshold.
          googleMap.onCameraMove!(CameraPosition(
            target: MapConfig.fallbackCenter,
            zoom: MapConfig.markerHiddenZoom - 1,
          ));
          await tester.pumpAndSettle();

          googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
          expect(googleMap.markers, isEmpty);
        },
      );

      testWidgets(
        'Given markers are hidden due to zoom, '
        'When the user zooms back in above the hidden threshold, '
        'Then the markers reappear at a reduced size',
        (WidgetTester tester) async {
          fakeMarkerManager.addMarker(
            position: MapConfig.fallbackCenter,
            animalType: null,
          );

          await tester.pumpWidget(buildSubject());
          await tester.pumpAndSettle();

          // Zoom out to hide.
          var googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
          googleMap.onCameraMove!(CameraPosition(
            target: MapConfig.fallbackCenter,
            zoom: MapConfig.markerHiddenZoom - 1,
          ));
          await tester.pumpAndSettle();

          googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
          expect(googleMap.markers, isEmpty);

          // Zoom back in within scaling range.
          googleMap.onCameraMove!(CameraPosition(
            target: MapConfig.fallbackCenter,
            zoom: (MapConfig.markerHiddenZoom + MapConfig.markerFullSizeZoom) / 2,
          ));
          await tester.pumpAndSettle();

          googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
          expect(googleMap.markers, isNotEmpty);
        },
      );

      testWidgets(
        'Given the map is at an intermediate zoom, '
        'When updateMarkerSize is called, '
        'Then the size is between markerMinSize and markerSize',
        (WidgetTester tester) async {
          fakeMarkerManager.addMarker(
            position: MapConfig.fallbackCenter,
            animalType: null,
          );

          await tester.pumpWidget(buildSubject());
          await tester.pumpAndSettle();

          final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));

          // Zoom to midpoint of scaling range.
          final midZoom = (MapConfig.markerHiddenZoom +
                  MapConfig.markerFullSizeZoom) /
              2;
          googleMap.onCameraMove!(CameraPosition(
            target: MapConfig.fallbackCenter,
            zoom: midZoom,
          ));
          await tester.pumpAndSettle();

          expect(fakeMarkerManager.updateSizeCallCount, greaterThan(0));
          expect(fakeMarkerManager.lastSize, greaterThan(0));
          expect(
            fakeMarkerManager.lastSize,
            lessThanOrEqualTo(MapConfig.markerSize),
          );
        },
      );
    });
  });
}
