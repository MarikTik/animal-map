import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../config/map_config.dart';
import '../../models/hazard_type.dart';
import '../../services/location_permission_service.dart';
import '../../services/location_provider.dart';
import '../../services/location_store.dart';
import '../../services/marker_manager.dart';

/// Duration of one full grow-then-shrink pulse cycle.
const _pulseDuration = Duration(milliseconds: 500);

/// How often the pulse scale is updated (≈60 fps).
const _pulseInterval = Duration(milliseconds: 16);

/// Peak scale multiplier at the top of the pulse.
const _pulseMaxScale = 1.3;

/// Main screen that displays the Google Map with animal markers.
///
/// Accepts injected services via constructor to enable dependency
/// inversion and testability. Resolves the initial camera position
/// from (1) the device's current location, (2) a previously stored
/// location, or (3) a hardcoded fallback.
class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    required this.locationPermissionService,
    required this.locationProvider,
    required this.locationStore,
    required this.markerManager,
  });

  /// Injected permission service (interface, not concrete).
  final LocationPermissionService locationPermissionService;

  /// Injected provider for the device's GPS coordinates.
  final LocationProvider locationProvider;

  /// Injected store for persisting the user's last known location.
  final LocationStore locationStore;

  /// Injected marker manager that owns the mutable marker set.
  final MarkerManager markerManager;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  bool _myLocationEnabled = false;
  double _currentZoom = MapConfig.fallbackZoom;
  LatLng _currentTarget = MapConfig.fallbackCenter;

  /// Sentinel value so the first [_onCameraMove] always synchronises
  /// the marker size with the actual camera zoom.
  double _lastMarkerSize = -1;
  final _random = Random();

  /// Stores a resolved camera position when the map controller
  /// isn't ready yet.
  CameraPosition? _pendingCamera;

  /// Whether the FAB is active (waiting for a map tap to place a marker).
  bool _placementMode = false;

  /// The animal name currently shown in the bottom info bar, or `null`.
  String? _selectedAnimalLabel;

  /// Timer driving the smooth marker pulse.
  Timer? _pulseTimer;

  /// ID of the marker currently being pulsed.
  String? _pulsingMarkerId;

  @override
  void initState() {
    super.initState();
    widget.markerManager.onMarkerTapped = _onMarkerTapped;
    _resolveInitialPosition();
  }

  /// Determines the best initial camera position.
  ///
  /// Priority: current GPS location → stored location → fallback.
  Future<void> _resolveInitialPosition() async {
    final granted = await widget.locationPermissionService.request();
    setState(() {
      _myLocationEnabled = granted;
    });

    LatLng? target;

    if (granted) {
      target = await widget.locationProvider.getCurrentLocation();
      if (target != null) {
        await widget.locationStore.save(target);
      }
    }

    target ??= await widget.locationStore.load();

    if (target == null) return;

    _currentTarget = target;
    _currentZoom = MapConfig.defaultZoom;

    final camera = CameraPosition(target: target, zoom: MapConfig.defaultZoom);
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(camera),
      );
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
    _currentTarget = position.target;

    final newSize = MapConfig.markerSizeForZoom(_currentZoom).roundToDouble();
    if (newSize != _lastMarkerSize) {
      _lastMarkerSize = newSize;
      setState(() {
        widget.markerManager.updateMarkerSize(newSize);
      });
    }
  }

  /// Toggles placement mode. When active, the next map tap
  /// places a random animal marker at that location.
  void _togglePlacementMode() {
    setState(() {
      _placementMode = !_placementMode;
      if (_placementMode) _selectedAnimalLabel = null;
    });
  }

  /// Called when the user taps the map while placement mode is active.
  void _onMapTap(LatLng position) {
    if (!_placementMode) return;

    final types = [...HazardType.values, null];
    final type = types[_random.nextInt(types.length)];

    setState(() {
      widget.markerManager.addMarker(
        position: position,
        hazardType: type,
      );
    });
  }

  /// Called when any marker is tapped.
  ///
  /// Starts a smooth grow-then-shrink pulse using a sine curve
  /// over [_pulseDuration], updating at [_pulseInterval].
  void _onMarkerTapped(String markerId, HazardType? hazardType) {
    // Cancel any in-progress pulse and reset that marker.
    _cancelPulse();

    setState(() {
      _selectedAnimalLabel = hazardType?.label ?? 'Unknown animal';
    });

    _pulsingMarkerId = markerId;
    final totalTicks = _pulseDuration.inMilliseconds ~/ _pulseInterval.inMilliseconds;
    var tick = 0;

    _pulseTimer = Timer.periodic(_pulseInterval, (_) {
      tick++;
      if (!mounted || tick >= totalTicks) {
        _cancelPulse();
        return;
      }

      // Sine curve: 0 → 1 → 0 over the duration.
      final t = tick / totalTicks;
      final scale = 1.0 + (_pulseMaxScale - 1.0) * sin(t * pi);

      setState(() {
        widget.markerManager.setMarkerScale(markerId, scale: scale);
      });
    });
  }

  /// Stops the pulse timer and resets the pulsing marker to normal.
  void _cancelPulse() {
    _pulseTimer?.cancel();
    _pulseTimer = null;
    if (_pulsingMarkerId != null && mounted) {
      widget.markerManager.setMarkerScale(_pulsingMarkerId!, scale: 1.0);
      _pulsingMarkerId = null;
    }
  }

  @override
  void dispose() {
    _cancelPulse();
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
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            onCameraMove: _onCameraMove,
            onTap: _onMapTap,
            initialCameraPosition: MapConfig.fallbackCameraPosition,
            minMaxZoomPreference: const MinMaxZoomPreference(
              MapConfig.minZoom,
              MapConfig.maxZoom,
            ),
            markers: widget.markerManager.markers,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            rotateGesturesEnabled: true,
            tiltGesturesEnabled: true,
            mapType: MapType.normal,
            myLocationEnabled: _myLocationEnabled,
            myLocationButtonEnabled: _myLocationEnabled,
          ),
          if (_selectedAnimalLabel != null)
            Positioned(
              left: 80,
              right: 60,
              bottom: 24,
              child: _AnimalInfoBar(
                label: _selectedAnimalLabel!,
                onDismiss: () => setState(() => _selectedAnimalLabel = null),
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
class _AnimalInfoBar extends StatelessWidget {
  const _AnimalInfoBar({required this.label, required this.onDismiss});

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
