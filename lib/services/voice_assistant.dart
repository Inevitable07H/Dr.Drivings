import 'package:flutter_tts/flutter_tts.dart';

class VoiceAssistant {
  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String message) async {
    await _tts.speak(message);
  }
}
