import 'dart:async';
import 'dart:js_interop';

@JS('speechSynthesis')
external _SpeechSynthesis get _speechSynthesis;

@JS()
extension type _SpeechSynthesis._(JSObject _) implements JSObject {
  external JSArray<_SpeechSynthesisVoice> getVoices();
  external void cancel();
  external void speak(_SpeechSynthesisUtterance utterance);
}

@JS('SpeechSynthesisUtterance')
extension type _SpeechSynthesisUtterance._(JSObject _) implements JSObject {
  external _SpeechSynthesisUtterance(String text);
  external set lang(String value);
  external set rate(double value);
  external set pitch(double value);
  external set voice(_SpeechSynthesisVoice? value);
}

@JS()
extension type _SpeechSynthesisVoice._(JSObject _) implements JSObject {
  external String get name;
  external String get lang;
}

const _spanishLocales = ['es-ES', 'es-MX', 'es-US', 'es'];

Future<void> speakSpanishInBrowser(
  String text, {
  required double rate,
  required double pitch,
  String? preferredVoiceName,
  String? preferredVoiceLocale,
}) async {
  final voices = await _waitForVoices();
  final voice = _pickSpanishVoice(
    voices,
    preferredVoiceName: preferredVoiceName,
    preferredVoiceLocale: preferredVoiceLocale,
  );
  final utterance = _SpeechSynthesisUtterance(text)
    ..lang = voice?.lang ?? 'es-ES'
    ..rate = rate
    ..pitch = pitch;
  if (voice != null) utterance.voice = voice;

  // Chrome can discard an utterance queued in the same task as cancel().
  _speechSynthesis.cancel();
  await Future<void>.delayed(const Duration(milliseconds: 50));
  _speechSynthesis.speak(utterance);
}

Future<bool> speakLocalizedInBrowser(
  String text, {
  required List<String> locales,
  required double rate,
  required double pitch,
}) async {
  final voices = await _waitForVoices();
  final voice = _pickVoiceForLocales(voices, locales);
  if (voice == null) return false;
  final utterance = _SpeechSynthesisUtterance(text)
    ..lang = voice.lang
    ..rate = rate
    ..pitch = pitch
    ..voice = voice;
  _speechSynthesis.cancel();
  await Future<void>.delayed(const Duration(milliseconds: 50));
  _speechSynthesis.speak(utterance);
  return true;
}

Future<void> stopBrowserSpeech() async {
  _speechSynthesis.cancel();
}

Future<List<_SpeechSynthesisVoice>> _waitForVoices() async {
  var voices = _speechSynthesis.getVoices().toDart;
  for (final delay in const [100, 250, 500]) {
    if (voices.isNotEmpty) break;
    await Future<void>.delayed(Duration(milliseconds: delay));
    voices = _speechSynthesis.getVoices().toDart;
  }
  return voices;
}

_SpeechSynthesisVoice? _pickSpanishVoice(
  List<_SpeechSynthesisVoice> voices, {
  required String? preferredVoiceName,
  required String? preferredVoiceLocale,
}) {
  if (preferredVoiceName != null && preferredVoiceLocale != null) {
    for (final voice in voices) {
      if (voice.name == preferredVoiceName &&
          voice.lang == preferredVoiceLocale) {
        return voice;
      }
    }
  }

  for (final locale in _spanishLocales) {
    for (final voice in voices) {
      if (voice.lang.toLowerCase() == locale.toLowerCase()) return voice;
    }
  }
  for (final voice in voices) {
    final locale = voice.lang.toLowerCase();
    if (locale == 'es' || locale.startsWith('es-')) return voice;
  }
  return null;
}

_SpeechSynthesisVoice? _pickVoiceForLocales(
  List<_SpeechSynthesisVoice> voices,
  List<String> locales,
) {
  for (final locale in locales) {
    for (final voice in voices) {
      if (voice.lang.toLowerCase() == locale.toLowerCase()) return voice;
    }
  }
  for (final locale in locales) {
    final language = locale.split('-').first.toLowerCase();
    for (final voice in voices) {
      final voiceLocale = voice.lang.toLowerCase();
      if (voiceLocale == language || voiceLocale.startsWith('$language-')) {
        return voice;
      }
    }
  }
  return null;
}
