import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService() {
    _tts.setSpeechRate(0.46);
    _tts.setVolume(1);
    _tts.setPitch(1);
  }

  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String text, String languageCode) async {
    await _tts.stop();
    await _tts.setLanguage(_ttsLanguage(languageCode));
    await _tts.speak(text);
  }

  Future<void> pause() async {
    await _tts.pause();
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  String _ttsLanguage(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'ar-SA';
      case 'fr':
        return 'fr-FR';
      default:
        return 'en-US';
    }
  }
}
