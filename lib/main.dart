import 'package:flutter/material.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'app.dart';

/// Application entry point.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _initializeMapRenderer();
  runApp(const AnimalMapApp());
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
