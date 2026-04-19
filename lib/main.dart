import 'package:flutter/material.dart';
import 'data/audio_service.dart';
import 'data/idiom_images.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    AudioService.instance.load(),
    IdiomImageRegistry.instance.load(),
  ]);
  runApp(const IdiomsQuizApp());
}

class IdiomsQuizApp extends StatelessWidget {
  const IdiomsQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '四字熟語クイズ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const HomeScreen(),
    );
  }
}
