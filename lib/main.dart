import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/ad_service.dart';
import 'data/audio_service.dart';
import 'data/pronunciation_service.dart';
import 'route_observer.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Android 15 (SDK 35+) draws apps edge-to-edge by default. Declare the
      // mode explicitly so older versions match, and keep the system bars
      // transparent so the app's own background shows through behind them.
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
          systemNavigationBarContrastEnforced: false,
        ),
      );

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
        debugPrint('[bootstrap] startup services failed: $e\n$st');
      }

      runApp(const IdiomsQuizApp());

      // Resolve Spanish voice availability up front so pronunciation controls
      // render as download prompts from the first frame on devices without it.
      unawaited(PronunciationService.instance.refreshAvailability());

      // Ads init after first frame: the UMP consent form (GDPR regions)
      // must overlay the running app, so this must not block runApp.
      unawaited(
        AdService.instance.ensureInitialized().catchError((Object e) {
          debugPrint('[bootstrap] ad init failed: $e');
        }),
      );
    },
    (error, stack) {
      debugPrint('[runZonedGuarded] $error\n$stack');
    },
  );
}

class IdiomsQuizApp extends StatelessWidget {
  const IdiomsQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DELE Voca Dojo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      navigatorObservers: [appRouteObserver],
      home: const SplashScreen(),
    );
  }
}
