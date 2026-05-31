import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../filters/incident_filter.dart';
import '../models/incident.dart';
import 'incident_socket_service.dart';
import 'marker_manager.dart';
import 'tts_service.dart';

/// Called for each incident that passes the filter, after the marker has been
/// added and TTS fired. Used by overlay mode to push an alert to the bubble.
typedef IncidentAlertCallback = void Function(Incident incident);

/// Pipes filtered incidents from an [IncidentSocketService] into a
/// [MarkerManager], optionally announcing each incident via [TtsService]
/// and notifying [onAlert] for any extra side effect (e.g. overlay banner).
///
/// Call [attach] once to start the subscription and [detach] to stop it.
/// The sink does not own the lifecycle of the socket, the manager, or the
/// TTS engine — it only owns the [StreamSubscription] between them.
class IncidentMarkerSink {
  IncidentMarkerSink({
    required IncidentSocketService socketService,
    required IncidentFilter filter,
    required MarkerManager markerManager,
    TtsService? ttsService,
    IncidentAlertCallback? onAlert,
  }) : _socketService = socketService,
       _filter = filter,
       _markerManager = markerManager,
       _ttsService = ttsService,
       _onAlert = onAlert;

  final IncidentSocketService _socketService;
  final IncidentFilter _filter;
  final MarkerManager _markerManager;
  final TtsService? _ttsService;
  final IncidentAlertCallback? _onAlert;

  StreamSubscription<dynamic>? _subscription;

  bool get isAttached => _subscription != null;

  /// Starts forwarding filtered incidents to the marker manager.
  ///
  /// No-op if already attached.
  void attach() {
    if (_subscription != null) return;

    _subscription = _socketService.incidents.listen(
      (incident) {
        _markerManager.addMarker(
          position: LatLng(
            incident.location.latitude,
            incident.location.longitude,
          ),
          incidentType: incident.type,
        );
        // ignore: avoid_print
        print(
          'Displayed incident marker: ${incident.incidentId} '
          'position=${incident.location.latitude},${incident.location.longitude}',
        );

        // Every incident should be visible on the map. Proximity only gates
        // driver-facing side effects like TTS and overlays.
        if (!_filter.passes(incident)) return;

        _ttsService?.speak(incident.type.alertPhrase);
        _onAlert?.call(incident);
      },
      onError: (Object error, StackTrace stack) {
        // ignore: avoid_print
        print('IncidentMarkerSink error: $error');
      },
    );
  }

  /// Cancels the subscription.
  ///
  /// Safe to call even if not attached.
  void detach() {
    _subscription?.cancel();
    _subscription = null;
  }
}
