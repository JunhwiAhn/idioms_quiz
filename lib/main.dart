import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'data/audio_service.dart';
import 'data/idiom_images.dart';
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
      await Future.wait([
        AudioService.instance.load(),
        IdiomImageRegistry.instance.load(),
      ]);
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
      title: '四字熟語道場',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const SplashScreen(),
    );
  }
}
