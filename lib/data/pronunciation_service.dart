import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pronunciation_web_bridge.dart';

class SpanishVoice {
  final String name;
  final String locale;

  const SpanishVoice({required this.name, required this.locale});

  String get label => locale.isEmpty ? name : '$name ($locale)';

  Map<String, String> toTtsVoice() => {'name': name, 'locale': locale};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpanishVoice && other.name == name && other.locale == locale;

  @override
  int get hashCode => Object.hash(name, locale);

  static SpanishVoice? fromTtsVoice(Map<String, String> voice) {
    final name = voice['name'];
    final locale = voice['locale'];
    if (name == null || name.isEmpty || locale == null || locale.isEmpty) {
      return null;
    }
    return SpanishVoice(name: name, locale: locale);
  }
}

class PronunciationService {
  PronunciationService._();
  static final PronunciationService instance = PronunciationService._();

  static const List<String> _spanishLocales = ['es-ES', 'es-MX', 'es-US', 'es'];
  static const _kVoiceName = 'pronunciation_voice_name';
  static const _kVoiceLocale = 'pronunciation_voice_locale';
  static const _kSpeechRate = 'pronunciation_speech_rate';
  static const _kPitch = 'pronunciation_pitch';
  static const minSpeechRate = 0.55;
  static const maxSpeechRate = 1.0;
  static const defaultSpeechRate = 0.65;

  final FlutterTts _tts = FlutterTts();
  bool _speechOptionsConfigured = false;
  Map<String, String>? _spanishVoice;
  double _speechRate = defaultSpeechRate;
  double _pitch = 1.0;

  double get speechRate => _speechRate;
  double get pitch => _pitch;

  Future<void> speakSpanish(String text) async {
    final phrase = text.trim();
    if (phrase.isEmpty) return;

    try {
      if (kIsWeb) {
        await loadSettings();
        final prefs = await SharedPreferences.getInstance();
        await speakSpanishInBrowser(
          phrase,
          rate: _speechRate,
          pitch: _pitch,
          preferredVoiceName: prefs.getString(_kVoiceName),
          preferredVoiceLocale: prefs.getString(_kVoiceLocale),
        );
        return;
      }

      final ready = await _configureForSpanish();
      if (!ready) {
        if (kDebugMode) {
          debugPrint('No Spanish TTS voice is available on this device.');
        }
        return;
      }
      await _tts.stop();
      await _tts.speak(phrase);
    } catch (e) {
      if (kDebugMode) debugPrint('TTS playback failed: $e');
    }
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _speechRate = (prefs.getDouble(_kSpeechRate) ?? defaultSpeechRate).clamp(
      minSpeechRate,
      maxSpeechRate,
    );
    _pitch = (prefs.getDouble(_kPitch) ?? 1.0).clamp(0.7, 1.3);
  }

  Future<void> setSpeechRate(double value) async {
    _speechRate = value.clamp(minSpeechRate, maxSpeechRate);
    _speechOptionsConfigured = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kSpeechRate, _speechRate);
  }

  Future<void> setPitch(double value) async {
    _pitch = value.clamp(0.7, 1.3);
    _speechOptionsConfigured = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kPitch, _pitch);
  }

  Future<void> setVoice(SpanishVoice? voice) async {
    final prefs = await SharedPreferences.getInstance();
    if (voice == null) {
      _spanishVoice = null;
      await prefs.remove(_kVoiceName);
      await prefs.remove(_kVoiceLocale);
      return;
    }

    _spanishVoice = voice.toTtsVoice();
    await prefs.setString(_kVoiceName, voice.name);
    await prefs.setString(_kVoiceLocale, voice.locale);
  }

  Future<SpanishVoice?> selectedVoice() async {
    await loadSettings();
    final voice = await _preferredVoiceFromPrefs();
    if (voice != null) return SpanishVoice.fromTtsVoice(voice);
    final discovered = _spanishVoice ?? await _findSpanishVoice();
    if (discovered == null) return null;
    return SpanishVoice.fromTtsVoice(discovered);
  }

  Future<List<SpanishVoice>> availableSpanishVoices() async {
    final voices = await _spanishVoiceCandidates();
    return voices
        .map(SpanishVoice.fromTtsVoice)
        .whereType<SpanishVoice>()
        .toList();
  }

  Future<void> stop() async {
    try {
      if (kIsWeb) {
        await stopBrowserSpeech();
        return;
      }
      await _tts.stop();
    } catch (e) {
      if (kDebugMode) debugPrint('TTS stop failed: $e');
    }
  }

  Future<bool> _configureForSpanish() async {
    await loadSettings();

    if (!_speechOptionsConfigured) {
      await _tts.setSpeechRate(_speechRate);
      await _tts.setPitch(_pitch);
      await _tts.setVolume(1.0);
      _speechOptionsConfigured = true;
    }

    final voice =
        _spanishVoice ??
        await _preferredVoiceFromPrefs() ??
        await _findSpanishVoice();
    if (voice != null) {
      _spanishVoice = voice;
      final locale = voice['locale'];
      if (locale != null && locale.isNotEmpty) {
        await _tts.setLanguage(locale);
      }
      final applied = await _tts.setVoice(voice);
      return _isSuccess(applied) || applied == null;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      for (final locale in _spanishLocales) {
        final installed = await _tts.isLanguageInstalled(locale);
        if (installed == true || installed == 1) {
          final applied = await _tts.setLanguage(locale);
          return _isSuccess(applied);
        }
      }
      return false;
    }

    for (final locale in _spanishLocales) {
      final available = await _tts.isLanguageAvailable(locale);
      if (_isSuccess(available)) {
        final applied = await _tts.setLanguage(locale);
        return _isSuccess(applied);
      }
    }

    return false;
  }

  Future<Map<String, String>?> _findSpanishVoice() async {
    final candidates = await _spanishVoiceCandidates();
    if (candidates.isEmpty) return null;

    for (final locale in _spanishLocales) {
      final match = candidates.where((voice) {
        final voiceLocale = voice['locale']?.toLowerCase();
        return voiceLocale == locale.toLowerCase();
      }).firstOrNull;
      if (match != null) return match;
    }

    return candidates.first;
  }

  Future<List<Map<String, String>>> _spanishVoiceCandidates() async {
    final voices = await _tts.getVoices;
    if (voices is! List) return const [];

    return voices
        .whereType<Map>()
        .map(
          (voice) => voice.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ),
        )
        .where(_isSpanishVoice)
        .toList();
  }

  Future<Map<String, String>?> _preferredVoiceFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_kVoiceName);
    final locale = prefs.getString(_kVoiceLocale);
    if (name == null || locale == null) return null;

    final candidates = await _spanishVoiceCandidates();
    for (final voice in candidates) {
      if (voice['name'] == name && voice['locale'] == locale) {
        return voice;
      }
    }
    return null;
  }

  bool _isSpanishVoice(Map<String, String> voice) {
    final locale = voice['locale']?.toLowerCase();
    final features = voice['features']?.toLowerCase() ?? '';
    final isNotInstalled =
        features.contains('not_installed') || features.contains('notinstalled');
    if (!isNotInstalled &&
        locale != null &&
        (locale == 'es' || locale.startsWith('es-'))) {
      return true;
    }

    final name = voice['name']?.toLowerCase();
    return !isNotInstalled && name != null && name.contains('spanish');
  }

  bool _isSuccess(dynamic value) => value == true || value == 1;
}
