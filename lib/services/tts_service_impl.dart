import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'tts_service.dart';

class TtsServiceImpl implements TtsService {
  TtsServiceImpl() {
    _ready = _init();
  }

  final FlutterTts _tts = FlutterTts();
  late final Future<void> _ready;

  Future<void> _init() async {
    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.setLanguage('en-US');
      // Slightly slower — easier to understand while driving.
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (e) {
      debugPrint('TTS init failed: $e');
    }
  }

  @override
  Future<void> speak(String text) async {
    // Ensure the engine finished configuring before the first utterance,
    // otherwise early calls can be silently dropped.
    await _ready;
    try {
      await _tts.stop();
      final result = await _tts.speak(text);
      debugPrint('TTS speak("$text") -> $result');
    } catch (e) {
      debugPrint('TTS speak failed: $e');
    }
  }

  @override
  Future<void> dispose() => _tts.stop();
}
