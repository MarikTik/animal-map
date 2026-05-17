import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../config/map_config.dart';
import '../../models/incident_type.dart';
import '../../services/location_permission_service.dart';
import '../../services/location_provider.dart';
import '../../services/location_store.dart';
import '../../services/marker_manager.dart';

/// Duration of one full grow-then-shrink pulse cycle.
const _pulseDuration = Duration(milliseconds: 500);

/// Peak radius of the pulse circle in metres.
const _pulseMaxRadius = 40.0;

/// Main screen that displays the Google Map with hazard markers.
class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    required this.locationPermissionService,
    required this.locationProvider,
    required this.locationStore,
    required this.markerManager,
  });

  final LocationPermissionService locationPermissionService;
  final LocationProvider locationProvider;
  final LocationStore locationStore;
  final MarkerManager markerManager;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  bool _myLocationEnabled = false;
  double _currentZoom = MapConfig.fallbackZoom;

  double _lastMarkerSize = -1;
  final _random = Random();

  CameraPosition? _pendingCamera;

  bool _placementMode = false;
  String? _selectedHazardLabel;

  /// Position of the tapped marker driving the pulse circle.
  LatLng? _pulsePosition;

  /// Animation controller for the pulse circle.
  late final AnimationController _pulseController;
  late final Animation<double> _pulseRadius;

  @override
  void initState() {
    super.initState();
    widget.markerManager.onMarkerTapped = _onMarkerTapped;
    _resolveInitialPosition();

    _pulseController = AnimationController(
      vsync: this,
      duration: _pulseDuration,
    );
    _pulseRadius = Tween<double>(begin: 0, end: _pulseMaxRadius).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    _pulseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _pulsePosition = null);
      }
    });
  }

  Future<void> _resolveInitialPosition() async {
    final granted = await widget.locationPermissionService.request();
    setState(() {
      _myLocationEnabled = granted;
    });

    LatLng? target;

    if (granted) {
      target = await widget.locationProvider.getCurrentLocation();
      if (target != null) await widget.locationStore.save(target);
    }

    target ??= await widget.locationStore.load();
    if (target == null) return;

    _currentZoom = MapConfig.defaultZoom;
    final camera = CameraPosition(target: target, zoom: MapConfig.defaultZoom);
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newCameraPosition(camera));
    } else {
      _pendingCamera = camera;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_pendingCamera != null) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(_pendingCamera!),
      );
      _pendingCamera = null;
    }
  }

  void _onCameraMove(CameraPosition position) {
    _currentZoom = position.zoom;

    final newSize = MapConfig.markerSizeForZoom(_currentZoom).roundToDouble();
    if (newSize != _lastMarkerSize) {
      _lastMarkerSize = newSize;
      // No setState — MarkerManagerImpl notifies ListenableBuilder directly.
      widget.markerManager.updateMarkerSize(newSize);
    }
  }

  void _togglePlacementMode() {
    setState(() {
      _placementMode = !_placementMode;
      if (_placementMode) _selectedHazardLabel = null;
    });
  }

  void _onMapTap(LatLng position) {
    if (!_placementMode) return;

    final types = [...IncidentType.values, null];
    final type = types[_random.nextInt(types.length)];
    // No setState — MarkerManagerImpl notifies ListenableBuilder directly.
    widget.markerManager.addMarker(position: position, incidentType: type);
  }

  void _onMarkerTapped(String markerId, IncidentType? incidentType) {
    // Look up the marker position to anchor the pulse circle.
    final manager = widget.markerManager;
    final marker = manager.markers.where((m) => m.markerId.value == markerId).firstOrNull;

    setState(() {
      _selectedHazardLabel = incidentType?.label ?? 'Unknown hazard';
      _pulsePosition = marker?.position;
    });

    if (_pulsePosition != null) {
      _pulseController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wild Watch'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _pulseRadius,
            builder: (context, _) {
              final circles = _pulsePosition != null
                  ? {
                      Circle(
                        circleId: const CircleId('pulse'),
                        center: _pulsePosition!,
                        radius: _pulseRadius.value,
                        strokeWidth: 2,
                        strokeColor: Theme.of(context).colorScheme.primary,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withAlpha(40),
                      ),
                    }
                  : const <Circle>{};

              return ListenableBuilder(
                listenable: widget.markerManager,
                builder: (context, _) => GoogleMap(
                  onMapCreated: _onMapCreated,
                  onCameraMove: _onCameraMove,
                  onTap: _onMapTap,
                  initialCameraPosition: MapConfig.fallbackCameraPosition,
                  minMaxZoomPreference: const MinMaxZoomPreference(
                    MapConfig.minZoom,
                    MapConfig.maxZoom,
                  ),
                  markers: widget.markerManager.markers,
                  circles: circles,
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
            },
          ),
          if (_selectedHazardLabel != null)
            Positioned(
              left: 80,
              right: 60,
              bottom: 24,
              child: _HazardInfoBar(
                label: _selectedHazardLabel!,
                onDismiss: () => setState(() => _selectedHazardLabel = null),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: _PlacementFab(
        active: _placementMode,
        onPressed: _togglePlacementMode,
      ),
    );
  }
}

/// FAB that glows when placement mode is active.
class _PlacementFab extends StatelessWidget {
  const _PlacementFab({required this.active, required this.onPressed});

  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: active
            ? [
                BoxShadow(
                  color: colorScheme.primary.withAlpha(150),
                  blurRadius: 16,
                  spreadRadius: 4,
                ),
              ]
            : [],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        tooltip: active ? 'Tap map to place marker' : 'Add test marker',
        backgroundColor: active ? colorScheme.primary : null,
        foregroundColor: active ? colorScheme.onPrimary : null,
        child: Icon(active ? Icons.add_location_alt : Icons.add_location),
      ),
    );
  }
}

/// Horizontal info bar shown at the bottom when a marker is tapped.
class _HazardInfoBar extends StatelessWidget {
  const _HazardInfoBar({required this.label, required this.onDismiss});

  final String label;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(24),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.pets, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(Icons.close, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
