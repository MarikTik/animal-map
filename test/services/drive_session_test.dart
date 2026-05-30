import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:animal_map/filters/proximity_filter.dart';
import 'package:animal_map/models/incident.dart';
import 'package:animal_map/services/drive_session.dart';

import '../fakes/fake_location_provider.dart';
import '../fakes/fake_navigation_launcher.dart';
import '../fakes/fake_overlay_controller.dart';
import '../fakes/incident_factory.dart';

void main() {
  group('DriveSession', () {
    late FakeNavigationLauncher nav;
    late FakeOverlayController overlay;
    late FakeLocationProvider location;
    late ProximityFilter filter;

    const destination = LatLng(40.0, -74.0);

    setUp(() {
      nav = FakeNavigationLauncher();
      overlay = FakeOverlayController();
      location = FakeLocationProvider();
      filter = ProximityFilter(referencePoint: const LatLng(0, 0));
    });

    DriveSession buildSession() => DriveSession(
          navigationLauncher: nav,
          overlayController: overlay,
          locationProvider: location,
          proximityFilter: filter,
        );

    test('start shows overlay and launches navigation when permitted', () async {
      final session = buildSession();

      final ok = await session.start(destination);

      expect(ok, isTrue);
      expect(overlay.shown, isTrue);
      expect(nav.navigatedTo, [destination]);
      expect(session.isActive, isTrue);
      await session.stop();
    });

    test('start requests permission when not granted', () async {
      overlay.permissionGranted = false;
      overlay.requestReturns = true;
      final session = buildSession();

      final ok = await session.start(destination);

      expect(overlay.requestCount, 1);
      expect(ok, isTrue);
      expect(overlay.shown, isTrue);
      await session.stop();
    });

    test('start aborts when permission is denied', () async {
      overlay.permissionGranted = false;
      overlay.requestReturns = false;
      final session = buildSession();

      final ok = await session.start(destination);

      expect(ok, isFalse);
      expect(overlay.shown, isFalse);
      expect(nav.navigatedTo, isEmpty);
      expect(session.isActive, isFalse);
    });

    test('position updates re-centre the proximity filter', () async {
      // Filter starts at (0,0). Drive to near the destination so an incident
      // there only passes once the reference point has moved.
      location.streamPositions = [destination];
      final session = buildSession();

      final incident = makeIncident(
        latitude: destination.latitude,
        longitude: destination.longitude,
      );

      // Before the stream is consumed, the incident is far from (0,0).
      expect(filter.passes(incident), isFalse);

      await session.start(destination);
      // Let the position stream propagate.
      await Future<void>.delayed(Duration.zero);

      expect(filter.passes(incident), isTrue);
      await session.stop();
    });

    test('pushAlert sends the alert phrase to the overlay', () async {
      final session = buildSession();
      final incident = makeIncident(type: IncidentType.stoppedVehicle);

      await session.pushAlert(incident);

      expect(overlay.sent, [
        {'phrase': 'Stopped vehicle ahead'},
      ]);
    });

    test('stop hides the overlay and ends the session', () async {
      final session = buildSession();
      await session.start(destination);

      await session.stop();

      expect(overlay.hidden, isTrue);
      expect(session.isActive, isFalse);
    });
  });
}
