import 'package:animal_map/services/tts_service.dart';

class FakeTtsService implements TtsService {
  final List<String> spoken = [];

  @override
  Future<void> speak(String text) async => spoken.add(text);

  @override
  Future<void> dispose() async {}
}
