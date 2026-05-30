import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:animal_map/services/navigation_launcher.dart';

class FakeNavigationLauncher implements NavigationLauncher {
  final List<LatLng> navigatedTo = [];

  @override
  Future<bool> navigateTo(LatLng destination) async {
    navigatedTo.add(destination);
    return true;
  }
}
