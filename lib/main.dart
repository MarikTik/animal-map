import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'app.dart';
import 'services/incident_socket_service.dart';
import 'services/incident_socket_service_impl.dart';

const _terminalGreen = '\x1B[32m';
const _terminalReset = '\x1B[0m';

/// Application entry point.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _initializeMapRenderer();
  runApp(const AnimalMapApp());
  unawaited(_startIncidentSocket(IncidentSocketServiceImpl()));
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

/// Connects [service] and logs every received incident.
///
/// Logging is the only consumer for now; future work will route the
/// stream into MarkerManager.
Future<void> _startIncidentSocket(IncidentSocketService service) async {
  await service.connect();
  service.incidents.listen(
    (incident) => debugPrint(
      '${_terminalGreen}Received incident: $incident$_terminalReset',
    ),
    onError: (Object error, StackTrace _) =>
        debugPrint('Incident socket error: $error'),
    onDone: () => debugPrint('Incident socket closed'),
  );
}
