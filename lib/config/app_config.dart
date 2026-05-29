/// Compile-time configuration values injected via --dart-define.
///
/// Pass `MAPS_API_KEY=yourkey` at build time:
///   `flutter run --dart-define=MAPS_API_KEY=yourkey`
abstract class AppConfig {
  static const mapsApiKey = String.fromEnvironment('MAPS_API_KEY');
}
