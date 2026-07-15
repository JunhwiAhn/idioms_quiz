import 'package:flutter/material.dart';
import '../data/app_text.dart';
import '../models/idiom.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.45, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0, 0.45, curve: Curves.easeOut),
          ),
        );
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _goHomeAfter();
  }

  Future<void> _goHomeAfter() async {
    try {
      await _controller.forward().orCancel;
    } on TickerCanceled {
      return;
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, _, _) => const HomeScreen(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = AppText(
      StudyLanguage.fromLocaleCode(
        Localizations.localeOf(context).languageCode,
      ),
    );
    return Scaffold(
      backgroundColor: scheme.surface,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text.appName,
                  style: notoSerifJp(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  text.oneWordADay,
                  style: notoSansJp(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 220,
                  child: AnimatedBuilder(
                    animation: _progress,
                    builder: (context, _) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: _progress.value,
                          minHeight: 6,
                          backgroundColor: scheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            scheme.primary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
