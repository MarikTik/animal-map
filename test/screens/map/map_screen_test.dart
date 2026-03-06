import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:animal_map/config/map_config.dart';
import 'package:animal_map/screens/map/map_screen.dart';

import '../../fakes/fake_location_permission_service.dart';

void main() {
  group('MapScreen', () {
    late FakeLocationPermissionService fakePermissionService;

    setUp(() {
      fakePermissionService = FakeLocationPermissionService();
    });

    Widget buildSubject() {
      return MaterialApp(
        home: MapScreen(
          locationPermissionService: fakePermissionService,
        ),
      );
    }

    testWidgets('renders a Scaffold with AppBar titled "Animal Map"', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Animal Map'), findsOneWidget);
    });

    testWidgets('contains a GoogleMap widget', (WidgetTester tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(GoogleMap), findsOneWidget);
    });

    testWidgets('GoogleMap uses MapConfig initial camera position', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

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
  });
}
