Future<void> speakSpanishInBrowser(
  String text, {
  required double rate,
  required double pitch,
  String? preferredVoiceName,
  String? preferredVoiceLocale,
}) async {}

Future<bool> speakLocalizedInBrowser(
  String text, {
  required List<String> locales,
  required double rate,
  required double pitch,
}) async => false;

Future<void> stopBrowserSpeech() async {}
