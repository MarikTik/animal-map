import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../config/map_config.dart';

/// Main screen that displays the Google Map.
///
/// Responsible only for rendering the map widget and managing the
/// [GoogleMapController]. All configuration is delegated to [MapConfig].
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

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
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
      ),
    );
  }
}
