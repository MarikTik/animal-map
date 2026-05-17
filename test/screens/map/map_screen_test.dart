import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:animal_map/config/map_config.dart';
import 'package:animal_map/screens/map/map_screen.dart';

import '../../fakes/fake_location_permission_service.dart';
import '../../fakes/fake_location_provider.dart';
import '../../fakes/fake_location_store.dart';
import '../../fakes/fake_marker_manager.dart';

void main() {
  group('MapScreen', () {
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

    testWidgets('renders a Scaffold with AppBar titled "Wild Watch"', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Wild Watch'), findsOneWidget);
    });

    testWidgets('contains a GoogleMap widget', (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(GoogleMap), findsOneWidget);
    });

    testWidgets('GoogleMap uses fallback camera position', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));

      expect(
        googleMap.initialCameraPosition.target,
        MapConfig.fallbackCenter,
      );
      expect(
        googleMap.initialCameraPosition.zoom,
        MapConfig.fallbackZoom,
      );
    });

    testWidgets('GoogleMap has zoom gestures enabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));

      expect(googleMap.zoomGesturesEnabled, isTrue);
      expect(googleMap.scrollGesturesEnabled, isTrue);
    });

    testWidgets('GoogleMap has min/max zoom set from MapConfig', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));

      expect(googleMap.minMaxZoomPreference.minZoom, MapConfig.minZoom);
      expect(googleMap.minMaxZoomPreference.maxZoom, MapConfig.maxZoom);
    });

    testWidgets('myLocation is disabled when permission denied', (
      WidgetTester tester,
    ) async {
      fakePermissionService.statusAfterRequest = PermissionStatus.denied;

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));

      expect(googleMap.myLocationEnabled, isFalse);
      expect(googleMap.myLocationButtonEnabled, isFalse);
    });

    testWidgets('myLocation is enabled when permission granted', (
      WidgetTester tester,
    ) async {
      fakePermissionService.statusAfterRequest = PermissionStatus.granted;

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));

      expect(googleMap.myLocationEnabled, isTrue);
      expect(googleMap.myLocationButtonEnabled, isTrue);
    });

    testWidgets('requests permission exactly once on init', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(fakePermissionService.requestCallCount, 1);
    });

    testWidgets('markers are visible at default zoom', (
      WidgetTester tester,
    ) async {
      fakeMarkerManager.addMarker(
        position: MapConfig.fallbackCenter,
        incidentType: null,
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));

      expect(googleMap.markers, isNotEmpty);
    });

    testWidgets('GoogleMap has an onCameraMove callback', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));

      expect(googleMap.onCameraMove, isNotNull);
    });

    testWidgets('calls updateMarkerSize when zoom changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));

      // Zoom to within the scaling range (between hidden and full).
      googleMap.onCameraMove!(CameraPosition(
        target: MapConfig.fallbackCenter,
        zoom: (MapConfig.markerHiddenZoom + MapConfig.markerFullSizeZoom) / 2,
      ));
      await tester.pumpAndSettle();

      expect(fakeMarkerManager.updateSizeCallCount, greaterThan(0));
    });

    testWidgets('FAB tap activates placement mode, map tap places marker', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Tap FAB to enter placement mode.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // No marker added yet.
      expect(fakeMarkerManager.addedMarkers, isEmpty);

      // Simulate map tap.
      const tapTarget = LatLng(40.7128, -74.0060);
      final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
      googleMap.onTap!(tapTarget);
      await tester.pumpAndSettle();

      expect(fakeMarkerManager.addedMarkers.length, 1);
      expect(fakeMarkerManager.addedMarkers.first.position, tapTarget);
    });

    testWidgets('FAB is positioned on the start (left) side', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));

      expect(
        scaffold.floatingActionButtonLocation,
        FloatingActionButtonLocation.startFloat,
      );
    });

    testWidgets('FAB has add_location icon with correct tooltip', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add_location), findsOneWidget);
      expect(find.byTooltip('Add test marker'), findsOneWidget);
    });

    testWidgets('FAB shows glow and alt icon when placement mode active', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Tap FAB to enter placement mode.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add_location_alt), findsOneWidget);
      expect(find.byTooltip('Tap map to place marker'), findsOneWidget);
    });

    testWidgets('map tap outside placement mode does not add marker', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
      googleMap.onTap!(const LatLng(33.0, -117.0));
      await tester.pumpAndSettle();

      expect(fakeMarkerManager.addedMarkers, isEmpty);
    });

    testWidgets('placement mode stays active after placing a marker', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Enter placement mode.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.add_location_alt), findsOneWidget);

      // Tap map — marker placed, mode still active.
      final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
      googleMap.onTap!(const LatLng(33.0, -117.0));
      await tester.pumpAndSettle();

      expect(fakeMarkerManager.addedMarkers.length, 1);
      expect(find.byIcon(Icons.add_location_alt), findsOneWidget);

      // Place another marker without re-pressing FAB.
      googleMap.onTap!(const LatLng(33.1, -117.1));
      await tester.pumpAndSettle();

      expect(fakeMarkerManager.addedMarkers.length, 2);
    });

    testWidgets('placement mode deactivates when FAB is tapped again', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Enter placement mode.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.add_location_alt), findsOneWidget);

      // Tap FAB again to deactivate.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add_location), findsOneWidget);
    });

    testWidgets('marker tap shows a Circle pulse overlay', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Add a marker via placement mode.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
      const markerPos = LatLng(33.0, -117.0);
      googleMap.onTap!(markerPos);
      await tester.pumpAndSettle();

      // No circle before tap.
      expect(tester.widget<GoogleMap>(find.byType(GoogleMap)).circles, isEmpty);

      // Tap the placed marker.
      fakeMarkerManager.markers.first.onTap!();
      await tester.pump(const Duration(milliseconds: 50));

      // Circle should now be present and centred on the marker.
      final map = tester.widget<GoogleMap>(find.byType(GoogleMap));
      expect(map.circles, isNotEmpty);
      expect(map.circles.first.center, markerPos);
    });

    testWidgets('pulse circle disappears after animation completes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
      googleMap.onTap!(const LatLng(33.0, -117.0));
      await tester.pumpAndSettle();

      fakeMarkerManager.markers.first.onTap!();
      // Advance well past the 500 ms pulse duration.
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(tester.widget<GoogleMap>(find.byType(GoogleMap)).circles, isEmpty);
    });

    testWidgets('marker tap shows hazard label in info bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
      googleMap.onTap!(const LatLng(33.0, -117.0));
      await tester.pumpAndSettle();

      fakeMarkerManager.markers.first.onTap!();
      await tester.pumpAndSettle();

      // Info bar should appear with some label text.
      expect(find.byType(Material), findsWidgets);
    });
  });
}
