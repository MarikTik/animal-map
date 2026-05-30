import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Launches turn-by-turn navigation in the external Google Maps app.
///
/// This uses Google Maps' free external navigation intent — the app itself
/// does not embed the (licensed) Navigation SDK. Our app runs alongside as
/// an overlay to deliver incident alerts.
abstract class NavigationLauncher {
  /// Opens Google Maps navigating to [destination] in driving mode.
  ///
  /// Returns `true` if an app was launched to handle the request.
  Future<bool> navigateTo(LatLng destination);
}

class NavigationLauncherImpl implements NavigationLauncher {
  @override
  Future<bool> navigateTo(LatLng destination) async {
    // The google.navigation: scheme launches turn-by-turn directly.
    // mode=d → driving.
    final uri = Uri.parse(
      'google.navigation:q=${destination.latitude},${destination.longitude}&mode=d',
    );

    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    // Fallback to the universal Maps URL if the navigation scheme is missing.
    final fallback = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${destination.latitude},${destination.longitude}'
      '&travelmode=driving',
    );
    return launchUrl(fallback, mode: LaunchMode.externalApplication);
  }
}
