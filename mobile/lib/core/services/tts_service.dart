import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  TtsService() {
    _tts.setSpeechRate(0.46).catchError((_) {});
    _tts.setVolume(1).catchError((_) {});
    _tts.setPitch(1).catchError((_) {});
  }

  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String text, String languageCode) async {
    try {
      await _tts.stop();
      await _tts.awaitSpeakCompletion(true);
      await _tts.setLanguage(_ttsLanguage(languageCode));
      await _tts.speak(text);
    } catch (_) {
      // Tests and some devices may not have a TTS engine available.
    }
  }

  Future<void> pause() async {
    try {
      await _tts.pause();
    } catch (_) {
      // Best-effort control for device-dependent TTS engines.
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Best-effort control for device-dependent TTS engines.
    }
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
