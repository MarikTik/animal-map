import 'package:flutter_tts/flutter_tts.dart';

import 'tts_service.dart';

class TtsServiceImpl implements TtsService {
  TtsServiceImpl() {
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.5); // slightly slower — easier to understand while driving
    _tts.setVolume(1.0);
  }

  final FlutterTts _tts = FlutterTts();

  @override
  Future<void> speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  @override
  Future<void> dispose() => _tts.stop();
}
