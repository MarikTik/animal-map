/// Speaks text aloud using the device's text-to-speech engine.
abstract class TtsService {
  /// Speaks [text]. Interrupts any currently playing speech.
  Future<void> speak(String text);

  /// Releases any underlying engine resources.
  Future<void> dispose();
}
