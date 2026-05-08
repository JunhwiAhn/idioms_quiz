import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'data/audio_service.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('[FlutterError] ${details.exceptionAsString()}');
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('[PlatformDispatcher] $error\n$stack');
      return true;
    };

    try {
      await AudioService.instance.load();
    } catch (e, st) {
      debugPrint('[bootstrap] asset load failed: $e\n$st');
    }

    runApp(const IdiomsQuizApp());
  }, (error, stack) {
    debugPrint('[runZonedGuarded] $error\n$stack');
  });
}

class IdiomsQuizApp extends StatelessWidget {
  const IdiomsQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Español Dojo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
