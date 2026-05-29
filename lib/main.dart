import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'app.dart';
import 'config/app_config.dart';
import 'config/map_config.dart';
import 'filters/proximity_filter.dart';
import 'services/incident_marker_sink.dart';
import 'services/incident_socket_service_impl.dart';
import 'services/marker_icon_loader_impl.dart';
import 'services/marker_manager_impl.dart';
import 'services/places_service.dart';

const _terminalGreen = '\x1B[32m';
const _terminalReset = '\x1B[0m';

/// Application entry point.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _initializeMapRenderer();

  // Build shared services that need to be wired together before the UI starts.
  final markerManager = MarkerManagerImpl(iconLoader: MarkerIconLoaderImpl());
  final placesService = PlacesService(apiKey: AppConfig.mapsApiKey);

  runApp(AnimalMapApp(markerManager: markerManager, placesService: placesService));

  unawaited(_startIncidentPipeline(markerManager));
}

/// Ensures the Android map renderer is explicitly set.
///
/// Uses the latest (Vulkan/cloud) renderer for better tile loading support.
void _initializeMapRenderer() {
  final platform = GoogleMapsFlutterPlatform.instance;
  if (platform is GoogleMapsFlutterAndroid) {
    platform.initializeWithRenderer(AndroidMapRenderer.latest);
  }
}

/// Connects the incident socket and pipes filtered events into [markerManager].
///
/// The proximity filter starts centred on [MapConfig.fallbackCenter]; it can
/// be updated later (e.g. once the user's location is known) via
/// [ProximityFilter.updateReferencePoint].
Future<void> _startIncidentPipeline(MarkerManagerImpl markerManager) async {
  final socketService = IncidentSocketServiceImpl();
  final filter = ProximityFilter(referencePoint: MapConfig.fallbackCenter);
  final sink = IncidentMarkerSink(
    socketService: socketService,
    filter: filter,
    markerManager: markerManager,
  );

  await socketService.connect();

  // Debug logging — remove once the UI surfaces incidents visually.
  socketService.incidents.listen(
    (incident) => debugPrint(
      '${_terminalGreen}Received incident: $incident$_terminalReset',
    ),
    onError: (Object error, StackTrace _) =>
        debugPrint('Incident socket error: $error'),
    onDone: () => debugPrint('Incident socket closed'),
  );

  sink.attach();
}
