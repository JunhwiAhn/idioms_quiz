import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ScreenAwakeService {
  ScreenAwakeService._();

  static const _channel = MethodChannel(
    'com.junhwiahn.spanishworddojo/screen_awake',
  );

  static Future<void> setEnabled(bool enabled) async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod<void>('setEnabled', {'enabled': enabled});
    } on MissingPluginException {
      // Non-Android builds do not provide this channel.
    } on PlatformException catch (error) {
      if (kDebugMode) {
        debugPrint('Could not change screen-awake state: $error');
      }
    }
  }
}
