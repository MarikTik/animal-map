import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'app.dart';
import 'models/incident.dart';

const _terminalGreen = '\x1B[32m';
const _terminalReset = '\x1B[0m';

/// Application entry point.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _initializeMapRenderer();
  runApp(const AnimalMapApp());

  unawaited(backendHandshakeWebSocket());
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

Future<void> backendHandshakeWebSocket() async {
  final uri = Uri.parse('wss://smart-wild.onrender.com/handshake');

  final channel = WebSocketChannel.connect(uri);
  await channel.ready;

  debugPrint('Connected to $uri');
  listenForIncidents(
    channel.stream,
    onIncident: (incident) => debugPrint(
      '${_terminalGreen}Received incident: $incident$_terminalReset',
    ),
    onError: (error, _) => debugPrint('WebSocket error: $error'),
    onDone: () => debugPrint('WebSocket closed'),
  );
}

/// Decodes incoming WebSocket messages as [Incident]s and forwards them
/// to [onIncident]. Extracted from [backendHandshakeWebSocket] so the
/// parsing path is testable with a synthetic stream.
StreamSubscription<dynamic> listenForIncidents(
  Stream<dynamic> stream, {
  required void Function(Incident) onIncident,
  void Function(Object error, StackTrace stackTrace)? onError,
  void Function()? onDone,
}) {
  return stream.listen(
    (message) {
      final jsonObject = jsonDecode(message as String);
      final incident = Incident.fromJson(
        Map<String, dynamic>.from(jsonObject as Map),
      );
      onIncident(incident);
    },
    onError: onError,
    onDone: onDone,
  );
}
