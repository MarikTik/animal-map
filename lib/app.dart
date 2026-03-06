import 'package:flutter/material.dart';

import 'screens/map/map_screen.dart';

/// Root application widget.
///
/// Configures theming and sets [MapScreen] as the home screen.
class AnimalMapApp extends StatelessWidget {
  const AnimalMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animal Map',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
      ),
      home: const MapScreen(),
    );
  }
}
