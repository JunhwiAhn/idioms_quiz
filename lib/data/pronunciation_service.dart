import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class PronunciationService {
  PronunciationService._();
  static final PronunciationService instance = PronunciationService._();

  final FlutterTts _tts = FlutterTts();
  bool _configured = false;

  Future<void> speakSpanish(String text) async {
    final phrase = text.trim();
    if (phrase.isEmpty) return;

    try {
      await _configure();
      await _tts.stop();
      await _tts.speak(phrase);
    } catch (e) {
      if (kDebugMode) debugPrint('TTS playback failed: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      if (kDebugMode) debugPrint('TTS stop failed: $e');
    }
  }

  Future<void> _configure() async {
    if (_configured) return;
    _configured = true;

    await _tts.setLanguage('es-ES');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
  }
}
