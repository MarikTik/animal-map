/// Represents the types of animals that can be detected and displayed
/// as markers on the map.
///
/// Each type maps to a PNG icon asset in `assets/markers/`.
/// The asset path and display label are derived from the enum name.
enum AnimalType {
  bear,
  coyote,
  deer,
  duck,
  fox,
  rabbit,
  squirrel,
  turtle;

  /// Path to the marker icon asset for this animal type.
  String get assetPath => 'assets/markers/$name.png';

  /// Human-readable label for display in info windows.
  String get label => name[0].toUpperCase() + name.substring(1);

  /// Resolves an animal type from a plain string name.
  ///
  /// Returns `null` if the name does not match any known type,
  /// enabling fallback handling by the caller.
  static AnimalType? fromName(String name) {
    final lower = name.toLowerCase();
    for (final type in values) {
      if (type.name == lower) return type;
    }
    return null;
  }
}
