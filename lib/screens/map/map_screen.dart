import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../config/map_config.dart';
import '../../services/location_permission_service.dart';

/// Main screen that displays the Google Map.
///
/// Accepts a [LocationPermissionService] via constructor injection
/// to enable dependency inversion and testability.
/// Requests location permission on initialization and enables
/// the "my location" layer when granted.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.locationPermissionService});

  /// Injected permission service (interface, not concrete).
  final LocationPermissionService locationPermissionService;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  bool _myLocationEnabled = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final granted = await widget.locationPermissionService.request();
    setState(() {
      _myLocationEnabled = granted;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Map'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: MapConfig.initialCameraPosition,
        minMaxZoomPreference: const MinMaxZoomPreference(
          MapConfig.minZoom,
          MapConfig.maxZoom,
        ),
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        scrollGesturesEnabled: true,
        rotateGesturesEnabled: true,
        tiltGesturesEnabled: true,
        mapType: MapType.normal,
        myLocationEnabled: _myLocationEnabled,
        myLocationButtonEnabled: _myLocationEnabled,
      ),
    );
  }
}
