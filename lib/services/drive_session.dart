import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../filters/proximity_filter.dart';
import '../models/incident.dart';
import 'location_provider.dart';
import 'navigation_launcher.dart';
import 'overlay_controller.dart';

/// Orchestrates a "demo drive": launches external Google Maps navigation,
/// shows the floating alert overlay, and keeps the [ProximityFilter] centred
/// on the live device position so incidents are judged relative to where the
/// car actually is.
///
/// Incident alerts are pushed into the overlay via [pushAlert], which the
/// incident pipeline calls for each incident that passes the filter.
class DriveSession {
  DriveSession({
    required NavigationLauncher navigationLauncher,
    required OverlayController overlayController,
    required LocationProvider locationProvider,
    required ProximityFilter proximityFilter,
  })  : _navigationLauncher = navigationLauncher,
        _overlayController = overlayController,
        _locationProvider = locationProvider,
        _proximityFilter = proximityFilter;

  final NavigationLauncher _navigationLauncher;
  final OverlayController _overlayController;
  final LocationProvider _locationProvider;
  final ProximityFilter _proximityFilter;

  StreamSubscription<LatLng>? _positionSub;

  bool get isActive => _positionSub != null;

  /// Starts a drive to [destination].
  ///
  /// Ensures overlay permission, shows the overlay, launches Google Maps
  /// navigation, and begins tracking the live position into the filter.
  /// Returns `false` if overlay permission was denied.
  Future<bool> start(LatLng destination) async {
    if (!await _overlayController.isPermissionGranted()) {
      final granted = await _overlayController.requestPermission();
      if (!granted) return false;
    }

    await ensureOverlay();

    // Keep the proximity filter centred on the moving car.
    _positionSub?.cancel();
    _positionSub = _locationProvider.positionStream().listen(
      _proximityFilter.updateReferencePoint,
    );

    await _navigationLauncher.navigateTo(destination);
    return true;
  }

  /// Ensures the overlay window is visible and its engine has had a moment to
  /// register its message listener.
  ///
  /// Useful for the debug inject path, where there may be no active drive yet,
  /// and to avoid a race at the start of a drive where an alert is sent before
  /// the overlay engine is ready.
  Future<void> ensureOverlay() async {
    if (!await _overlayController.isPermissionGranted()) {
      final granted = await _overlayController.requestPermission();
      if (!granted) return;
    }
    await _overlayController.show();
    // The overlay runs in a separate engine; give it a beat to spin up and
    // subscribe to the message channel before the first send.
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  /// Pushes an incident alert to the overlay banner.
  Future<void> pushAlert(Incident incident) {
    return _overlayController.send({'phrase': incident.type.alertPhrase});
  }

  /// Ends the drive: stops position tracking and hides the overlay.
  Future<void> stop() async {
    await _positionSub?.cancel();
    _positionSub = null;
    await _overlayController.hide();
  }
}
