import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

/// Runs the floating overlay app.
///
/// Invoked from `main.dart`'s `overlayMain` entry point. Runs in a
/// **separate** Flutter engine from the main app, so it shares no state — it
/// only receives messages pushed via [FlutterOverlayWindow.shareData].
void runIncidentOverlay() {
  runApp(const _IncidentOverlayApp());
}

class _IncidentOverlayApp extends StatelessWidget {
  const _IncidentOverlayApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: IncidentOverlay(),
    );
  }
}

/// The bubble + alert banner shown over Google Maps.
///
/// Idle: a small app-icon bubble. When an incident message arrives it expands
/// into a coloured banner with the alert phrase for a few seconds, then
/// collapses back to the bubble.
class IncidentOverlay extends StatefulWidget {
  const IncidentOverlay({super.key});

  @override
  State<IncidentOverlay> createState() => _IncidentOverlayState();
}

class _IncidentOverlayState extends State<IncidentOverlay> {
  /// How long the expanded banner stays on screen.
  static const _bannerDuration = Duration(seconds: 5);

  StreamSubscription<dynamic>? _subscription;
  String? _alertText;
  Timer? _collapseTimer;

  @override
  void initState() {
    super.initState();
    _subscription = FlutterOverlayWindow.overlayListener.listen(_onMessage);
  }

  void _onMessage(dynamic message) {
    // Expect a map shaped like {'phrase': 'Animal on the road ahead'}.
    if (message is! Map) return;
    final phrase = message['phrase'];
    if (phrase is! String) return;

    setState(() => _alertText = phrase);

    _collapseTimer?.cancel();
    _collapseTimer = Timer(_bannerDuration, () {
      if (mounted) setState(() => _alertText = null);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _collapseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: _alertText == null ? _buildBubble() : _buildBanner(_alertText!),
    );
  }

  Widget _buildBubble() {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        margin: const EdgeInsets.all(12),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.cyan.shade700,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 8, spreadRadius: 1),
          ],
        ),
        child: const Icon(Icons.pets, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildBanner(String text) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
