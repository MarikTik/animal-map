import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'app.dart';
import 'config/app_config.dart';
import 'config/map_config.dart';
import 'filters/proximity_filter.dart';
import 'services/debug_incident_factory.dart';
import 'services/directions_service.dart';
import 'services/incident_marker_sink.dart';
import 'services/incident_socket_service_impl.dart';
import 'services/location_provider_impl.dart';
import 'services/marker_icon_loader_impl.dart';
import 'services/marker_manager_impl.dart';
import 'services/places_service.dart';
import 'services/tts_service_impl.dart';

const _terminalGreen = '\x1B[32m';
const _terminalReset = '\x1B[0m';

/// Application entry point.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _initializeMapRenderer();

  final markerManager = MarkerManagerImpl(iconLoader: MarkerIconLoaderImpl());
  final placesService = PlacesService(apiKey: AppConfig.mapsApiKey);
  final directionsService = DirectionsService(apiKey: AppConfig.mapsApiKey);
  final locationProvider = LocationProviderImpl();
  final socketService = IncidentSocketServiceImpl();

  // Filter centred on the user; updated when a route is drawn / location known.
  final filter = ProximityFilter(referencePoint: MapConfig.fallbackCenter);

  // Debug demo trigger: fabricate an incident near the user's live position
  // and push it through the real socket stream so it is filtered, drawn as a
  // marker on the in-app map, and announced via TTS — exactly like a real one.
  final debugFactory = DebugIncidentFactory();
  Future<void> injectTestIncident() async {
    final here = await locationProvider.getCurrentLocation() ??
        MapConfig.fallbackCenter;
    // Re-centre the filter on the current position so the injected incident
    // passes the proximity check.
    filter.updateReferencePoint(here);
    socketService.inject(debugFactory.near(here));
  }

  runApp(AnimalMapApp(
    markerManager: markerManager,
    placesService: placesService,
    directionsService: directionsService,
    onInjectTestIncident: injectTestIncident,
  ));

  unawaited(_startIncidentPipeline(
    socketService: socketService,
    markerManager: markerManager,
    filter: filter,
  ));
}

/// Ensures the Android map renderer is explicitly set.
void _initializeMapRenderer() {
  final platform = GoogleMapsFlutterPlatform.instance;
  if (platform is GoogleMapsFlutterAndroid) {
    platform.initializeWithRenderer(AndroidMapRenderer.latest);
  }
}

/// Connects the incident socket and pipes filtered events into the marker
/// manager — drawing each incident as a map marker and announcing it via TTS.
Future<void> _startIncidentPipeline({
  required IncidentSocketServiceImpl socketService,
  required MarkerManagerImpl markerManager,
  required ProximityFilter filter,
}) async {
  final tts = TtsServiceImpl();
  final sink = IncidentMarkerSink(
    socketService: socketService,
    filter: filter,
    markerManager: markerManager,
    ttsService: tts,
  );

  await socketService.connect();

  // Debug logging — remove once the demo is finalised.
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
