import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/idiom.dart';
import 'pronunciation_web_bridge.dart';

class ShadowingSpeechResult {
  final bool spanishSpoken;
  final bool studyLanguageSpoken;
  final bool cancelled;

  const ShadowingSpeechResult({
    required this.spanishSpoken,
    required this.studyLanguageSpoken,
    this.cancelled = false,
  });
}

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
  static const Map<StudyLanguage, List<String>> _studyLanguageLocales = {
    StudyLanguage.ko: ['ko-KR', 'ko'],
    StudyLanguage.en: ['en-US', 'en-GB', 'en'],
    StudyLanguage.ja: ['ja-JP', 'ja'],
    StudyLanguage.pt: ['pt-BR', 'pt-PT', 'pt'],
  };
  static const _kVoiceName = 'pronunciation_voice_name';
  static const _kVoiceLocale = 'pronunciation_voice_locale';
  static const _kSpeechRate = 'pronunciation_speech_rate';
  static const _kPitch = 'pronunciation_pitch';
  static const _kShadowingAutoDelay = 'shadowing_auto_delay_seconds';
  // Learners need the word slower than a native-speed 1.0, and 0.65 still ran
  // ahead of what a beginner can follow.
  static const minSpeechRate = 0.3;
  static const maxSpeechRate = 1.0;
  static const defaultSpeechRate = 0.7;
  static const minShadowingAutoDelay = 3.0;
  static const maxShadowingAutoDelay = 12.0;
  static const defaultShadowingAutoDelay = 3.0;

  final FlutterTts _tts = FlutterTts();
  static const _setupChannel = MethodChannel(
    'com.junhwiahn.spanishworddojo/tts_setup',
  );
  Map<String, String>? _spanishVoice;
  double _speechRate = defaultSpeechRate;
  double _pitch = 1.0;
  double _shadowingAutoDelay = defaultShadowingAutoDelay;
  int _shadowingPlaybackGeneration = 0;

  /// Whether this device can speak Spanish. Starts optimistic so buttons do
  /// not flash a download icon before the first check resolves; playback and
  /// [refreshAvailability] keep it honest afterwards.
  final ValueNotifier<bool> spanishVoiceAvailable = ValueNotifier<bool>(true);

  double get speechRate => _speechRate;
  double get pitch => _pitch;
  double get shadowingAutoDelay => _shadowingAutoDelay;

  /// Re-runs voice discovery, e.g. after returning from the system installer.
  Future<void> refreshAvailability() async {
    if (kIsWeb) return;
    _spanishVoice = null;
    _triedGoogleEngine = false;
    try {
      spanishVoiceAvailable.value = await _configureForSpanish();
    } catch (e) {
      if (kDebugMode) debugPrint('TTS availability check failed: $e');
    }
  }

  /// Returns false when the device has no Spanish voice, so callers that were
  /// triggered by an explicit tap can explain the silence instead of looking
  /// broken.
  Future<bool> speakSpanish(String text) async {
    final phrase = text.trim();
    if (phrase.isEmpty) return true;

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
        return true;
      }

      final ready = await _configureForSpanish();
      spanishVoiceAvailable.value = ready;
      if (!ready) {
        if (kDebugMode) {
          debugPrint('No Spanish TTS voice is available on this device.');
        }
        return false;
      }
      await _tts.stop();
      await _tts.speak(phrase);
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('TTS playback failed: $e');
      return false;
    }
  }

  Future<bool> speakStudyLanguage(String text, StudyLanguage language) async {
    final phrase = text.trim();
    if (phrase.isEmpty) return true;
    final locales = _studyLanguageLocales[language]!;

    try {
      await loadSettings();
      if (kIsWeb) {
        return speakLocalizedInBrowser(
          phrase,
          locales: locales,
          rate: _speechRate,
          pitch: _pitch,
        );
      }

      final ready = await _configureForLocales(locales);
      if (!ready) return false;
      await _tts.stop();
      await _tts.speak(phrase);
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Study-language TTS playback failed: $e');
      return false;
    }
  }

  Future<ShadowingSpeechResult> speakShadowingPair({
    required String spanish,
    required String meaning,
    required StudyLanguage language,
  }) async {
    final generation = ++_shadowingPlaybackGeneration;
    if (kIsWeb) {
      final spanishSpoken = await speakSpanish(spanish);
      if (!spanishSpoken) {
        return const ShadowingSpeechResult(
          spanishSpoken: false,
          studyLanguageSpoken: false,
        );
      }
      final pauseMs = (700 + spanish.trim().length * 120).clamp(900, 3000);
      await Future<void>.delayed(Duration(milliseconds: pauseMs));
      if (generation != _shadowingPlaybackGeneration) {
        return const ShadowingSpeechResult(
          spanishSpoken: true,
          studyLanguageSpoken: false,
          cancelled: true,
        );
      }
      final studyLanguageSpoken = await speakStudyLanguage(meaning, language);
      return ShadowingSpeechResult(
        spanishSpoken: true,
        studyLanguageSpoken: studyLanguageSpoken,
      );
    }

    await _tts.awaitSpeakCompletion(true);
    final spanishSpoken = await speakSpanish(spanish);
    if (!spanishSpoken) {
      return const ShadowingSpeechResult(
        spanishSpoken: false,
        studyLanguageSpoken: false,
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (generation != _shadowingPlaybackGeneration) {
      return const ShadowingSpeechResult(
        spanishSpoken: true,
        studyLanguageSpoken: false,
        cancelled: true,
      );
    }
    final studyLanguageSpoken = await speakStudyLanguage(meaning, language);
    return ShadowingSpeechResult(
      spanishSpoken: true,
      studyLanguageSpoken: studyLanguageSpoken,
    );
  }

  /// Opens the system screen where the user can add the missing Spanish voice.
  /// Returns false when no such screen exists on this device.
  Future<bool> openVoiceInstall() async {
    if (kIsWeb) return false;
    for (final method in const ['installVoiceData', 'openTtsSettings']) {
      try {
        final ok = await _setupChannel.invokeMethod<bool>(method);
        if (ok == true) return true;
      } catch (e) {
        if (kDebugMode) debugPrint('TTS setup intent "$method" failed: $e');
      }
    }
    return false;
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _speechRate = (prefs.getDouble(_kSpeechRate) ?? defaultSpeechRate).clamp(
      minSpeechRate,
      maxSpeechRate,
    );
    _pitch = (prefs.getDouble(_kPitch) ?? 1.0).clamp(0.7, 1.3);
    _shadowingAutoDelay =
        (prefs.getDouble(_kShadowingAutoDelay) ?? defaultShadowingAutoDelay)
            .clamp(minShadowingAutoDelay, maxShadowingAutoDelay);
  }

  Future<void> setSpeechRate(double value) async {
    _speechRate = value.clamp(minSpeechRate, maxSpeechRate);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kSpeechRate, _speechRate);
  }

  Future<void> setShadowingAutoDelay(double value) async {
    _shadowingAutoDelay = value.clamp(
      minShadowingAutoDelay,
      maxShadowingAutoDelay,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kShadowingAutoDelay, _shadowingAutoDelay);
  }

  Future<void> setPitch(double value) async {
    _pitch = value.clamp(0.7, 1.3);
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
    _shadowingPlaybackGeneration++;
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

  static const _googleTtsEngine = 'com.google.android.tts';
  bool _triedGoogleEngine = false;

  /// Samsung and other OEM engines are often the default but ship no Spanish
  /// voice, while Google's engine does. Switch to Google's once if the current
  /// engine turns out to have nothing Spanish to offer.
  Future<bool> _switchToGoogleEngine() async {
    if (_triedGoogleEngine || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    _triedGoogleEngine = true;
    try {
      final engines = await _tts.getEngines;
      if (engines is! List || !engines.contains(_googleTtsEngine)) return false;
      await _tts.setEngine(_googleTtsEngine);
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Switching to Google TTS engine failed: $e');
      return false;
    }
  }

  Future<bool> _configureForSpanish() async {
    await loadSettings();
    final ready = await _resolveSpanishVoice();
    if (ready) return true;

    // Retry once on Google's engine before giving up.
    if (await _switchToGoogleEngine()) {
      _spanishVoice = null;
      return _resolveSpanishVoice();
    }
    return false;
  }

  Future<bool> _resolveSpanishVoice() async {
    var ready = false;

    final voice =
        _spanishVoice ??
        await _preferredVoiceFromPrefs() ??
        await _findSpanishVoice();
    if (voice != null) {
      _spanishVoice = voice;
      final locale = voice['locale'];
      if (locale != null && locale.isNotEmpty) {
        // A successful setLanguage is enough to speak. Android engines often
        // reject setVoice when the stored voice name no longer matches an
        // installed voice, so failing that must not silence playback.
        ready = _isSuccess(await _tts.setLanguage(locale));
      }
      final applied = await _tts.setVoice(voice);
      ready = ready || _isSuccess(applied) || applied == null;
    }

    if (!ready && defaultTargetPlatform == TargetPlatform.android) {
      for (final locale in _spanishLocales) {
        final installed = await _tts.isLanguageInstalled(locale);
        if (installed == true || installed == 1) {
          ready = _isSuccess(await _tts.setLanguage(locale));
          if (ready) break;
        }
      }
    } else if (!ready) {
      for (final locale in _spanishLocales) {
        final available = await _tts.isLanguageAvailable(locale);
        if (_isSuccess(available)) {
          ready = _isSuccess(await _tts.setLanguage(locale));
          if (ready) break;
        }
      }
    }

    // Rate/pitch/volume are applied last: setLanguage and setVoice reset them
    // on some Android engines, which would leave speech at the engine default.
    if (ready) {
      await _tts.setSpeechRate(_speechRate);
      await _tts.setPitch(_pitch);
      await _tts.setVolume(1.0);
    }

    return ready;
  }

  Future<bool> _configureForLocales(List<String> locales) async {
    var ready = false;
    final voices = await _voiceCandidates();
    Map<String, String>? matchedVoice;
    for (final locale in locales) {
      matchedVoice = voices.where((voice) {
        final voiceLocale = voice['locale']?.toLowerCase();
        return voiceLocale == locale.toLowerCase();
      }).firstOrNull;
      if (matchedVoice != null) break;
    }

    if (matchedVoice != null) {
      final locale = matchedVoice['locale'];
      if (locale != null && locale.isNotEmpty) {
        ready = _isSuccess(await _tts.setLanguage(locale));
      }
      final applied = await _tts.setVoice(matchedVoice);
      ready = ready || _isSuccess(applied) || applied == null;
    }

    if (!ready) {
      for (final locale in locales) {
        final available = defaultTargetPlatform == TargetPlatform.android
            ? await _tts.isLanguageInstalled(locale)
            : await _tts.isLanguageAvailable(locale);
        if (_isSuccess(available)) {
          ready = _isSuccess(await _tts.setLanguage(locale));
          if (ready) break;
        }
      }
    }

    if (ready) {
      await _tts.setSpeechRate(_speechRate);
      await _tts.setPitch(_pitch);
      await _tts.setVolume(1.0);
    }
    return ready;
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
    return (await _voiceCandidates()).where(_isSpanishVoice).toList();
  }

  Future<List<Map<String, String>>> _voiceCandidates() async {
    final voices = await _tts.getVoices;
    if (voices is! List) return const [];

    return voices
        .whereType<Map>()
        .map(
          (voice) => voice.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ),
        )
        .where((voice) {
          final features = voice['features']?.toLowerCase() ?? '';
          return !features.contains('not_installed') &&
              !features.contains('notinstalled');
        })
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
