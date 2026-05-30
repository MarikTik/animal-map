import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'app.dart';
import 'config/app_config.dart';
import 'config/map_config.dart';
import 'filters/proximity_filter.dart';
import 'overlay/incident_overlay.dart';
import 'services/debug_incident_factory.dart';
import 'services/drive_session.dart';
import 'services/incident_marker_sink.dart';
import 'services/incident_socket_service_impl.dart';
import 'services/location_provider_impl.dart';
import 'services/marker_icon_loader_impl.dart';
import 'services/marker_manager_impl.dart';
import 'services/navigation_launcher.dart';
import 'services/overlay_controller.dart';
import 'services/places_service.dart';
import 'services/tts_service_impl.dart';

const _terminalGreen = '\x1B[32m';
const _terminalReset = '\x1B[0m';

/// Entry point for the floating overlay window's separate Flutter engine.
///
/// The flutter_overlay_window plugin looks this symbol up by name in the
/// app's root library, so it must live in main.dart. It delegates to the
/// overlay widget defined in lib/overlay/incident_overlay.dart.
@pragma('vm:entry-point')
void overlayMain() => runIncidentOverlay();

/// Application entry point.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _initializeMapRenderer();

  final markerManager = MarkerManagerImpl(iconLoader: MarkerIconLoaderImpl());
  final placesService = PlacesService(apiKey: AppConfig.mapsApiKey);
  final locationProvider = LocationProviderImpl();
  final socketService = IncidentSocketServiceImpl();

  // Shared filter — its reference point is updated live by the DriveSession.
  final filter = ProximityFilter(referencePoint: MapConfig.fallbackCenter);

  final driveSession = DriveSession(
    navigationLauncher: NavigationLauncherImpl(),
    overlayController: OverlayControllerImpl(),
    locationProvider: locationProvider,
    proximityFilter: filter,
  );

  // Debug demo trigger: fabricate an incident near the user's live position
  // and push it through the real socket stream so it is filtered, spoken, and
  // shown in the overlay exactly like a server incident.
  final debugFactory = DebugIncidentFactory();
  Future<void> injectTestIncident() async {
    final here = await locationProvider.getCurrentLocation() ??
        MapConfig.fallbackCenter;
    // Re-centre the filter on the current position so the injected incident
    // passes the proximity check even when no drive is active yet.
    filter.updateReferencePoint(here);
    socketService.inject(debugFactory.near(here));
  }

  runApp(AnimalMapApp(
    markerManager: markerManager,
    placesService: placesService,
    driveSession: driveSession,
    onInjectTestIncident: injectTestIncident,
  ));

  unawaited(_startIncidentPipeline(
    socketService: socketService,
    markerManager: markerManager,
    filter: filter,
    driveSession: driveSession,
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
/// manager (TTS announcement) and the overlay banner (via the drive session).
Future<void> _startIncidentPipeline({
  required IncidentSocketServiceImpl socketService,
  required MarkerManagerImpl markerManager,
  required ProximityFilter filter,
  required DriveSession driveSession,
}) async {
  final tts = TtsServiceImpl();
  final sink = IncidentMarkerSink(
    socketService: socketService,
    filter: filter,
    markerManager: markerManager,
    ttsService: tts,
    onAlert: driveSession.pushAlert,
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
