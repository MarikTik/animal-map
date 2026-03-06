import 'package:flutter/material.dart';

import 'screens/map/map_screen.dart';
import 'services/location_permission_service.dart';
import 'services/location_permission_service_impl.dart';

/// Root application widget.
///
/// Configures theming and provides production dependencies
/// to child screens.
class AnimalMapApp extends StatelessWidget {
  /// Creates the app with an optional [LocationPermissionService] override.
  ///
  /// Defaults to [LocationPermissionServiceImpl] for production.
  /// Pass a fake/mock for testing.
  const AnimalMapApp({super.key, LocationPermissionService? locationPermissionService})
      : _locationPermissionService = locationPermissionService;

  final LocationPermissionService? _locationPermissionService;

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
      ),
    );
  }
}
