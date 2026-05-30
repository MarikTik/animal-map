import 'package:flutter_overlay_window/flutter_overlay_window.dart';

/// Controls the floating alert overlay shown on top of Google Maps.
///
/// Thin wrapper around [FlutterOverlayWindow] so the rest of the app does not
/// depend on the plugin directly and the behaviour can be faked in tests.
abstract class OverlayController {
  /// Whether the system "draw over other apps" permission is granted.
  Future<bool> isPermissionGranted();

  /// Prompts the user to grant the overlay permission. Returns the result.
  Future<bool> requestPermission();

  /// Shows the floating bubble overlay. No-op if already visible.
  Future<void> show();

  /// Hides the overlay.
  Future<void> hide();

  /// Pushes [data] to the running overlay (e.g. an incident alert payload).
  Future<void> send(Map<String, dynamic> data);
}

class OverlayControllerImpl implements OverlayController {
  @override
  Future<bool> isPermissionGranted() =>
      FlutterOverlayWindow.isPermissionGranted();

  @override
  Future<bool> requestPermission() async =>
      await FlutterOverlayWindow.requestPermission() ?? false;

  @override
  Future<void> show() async {
    if (await FlutterOverlayWindow.isActive()) return;
    await FlutterOverlayWindow.showOverlay(
      height: 200,
      width: WindowSize.matchParent,
      alignment: OverlayAlignment.topCenter,
      flag: OverlayFlag.defaultFlag,
      enableDrag: true,
      positionGravity: PositionGravity.auto,
      overlayTitle: 'Wild Watch',
      overlayContent: 'Watching for incidents…',
    );
  }

  @override
  Future<void> hide() => FlutterOverlayWindow.closeOverlay().then((_) {});

  @override
  Future<void> send(Map<String, dynamic> data) =>
      FlutterOverlayWindow.shareData(data);
}
