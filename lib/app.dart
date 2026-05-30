import 'package:flutter/material.dart';

import 'screens/map/map_screen.dart';
import 'services/drive_session.dart';
import 'services/location_permission_service.dart';
import 'services/location_permission_service_impl.dart';
import 'services/location_provider.dart';
import 'services/location_provider_impl.dart';
import 'services/location_store.dart';
import 'services/location_store_stub.dart';
import 'services/marker_icon_loader_impl.dart';
import 'services/marker_manager.dart';
import 'services/marker_manager_impl.dart';
import 'services/places_service.dart';

/// Root application widget.
///
/// Configures theming and provides production dependencies
/// to child screens.
class AnimalMapApp extends StatelessWidget {
  /// Creates the app with optional service overrides.
  ///
  /// Defaults to production implementations when not specified.
  /// Pass fakes for testing.
  const AnimalMapApp({
    super.key,
    LocationPermissionService? locationPermissionService,
    LocationProvider? locationProvider,
    LocationStore? locationStore,
    MarkerManager? markerManager,
    PlacesService? placesService,
    DriveSession? driveSession,
    Future<void> Function()? onInjectTestIncident,
  })  : _locationPermissionService = locationPermissionService,
        _locationProvider = locationProvider,
        _locationStore = locationStore,
        _markerManager = markerManager,
        _placesService = placesService,
        _driveSession = driveSession,
        _onInjectTestIncident = onInjectTestIncident;

  final LocationPermissionService? _locationPermissionService;
  final LocationProvider? _locationProvider;
  final LocationStore? _locationStore;
  final MarkerManager? _markerManager;
  final PlacesService? _placesService;
  final DriveSession? _driveSession;
  final Future<void> Function()? _onInjectTestIncident;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animal Map',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
      ),
      home: MapScreen(
        locationPermissionService:
            _locationPermissionService ?? LocationPermissionServiceImpl(),
        locationProvider: _locationProvider ?? LocationProviderImpl(),
        locationStore: _locationStore ?? LocationStoreStub(),
        markerManager: _markerManager ??
            MarkerManagerImpl(iconLoader: MarkerIconLoaderImpl()),
        placesService: _placesService,
        driveSession: _driveSession,
        onInjectTestIncident: _onInjectTestIncident,
      ),
    );
  }
}
