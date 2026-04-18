import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/idiom_repository.dart';
import '../data/quiz_session.dart';
import '../data/score_service.dart';
import '../models/idiom.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = IdiomRepository();
  final _scoreService = ScoreService();

  List<Idiom>? _idioms;
  int _points = 0;
  int _totalAnswered = 0;
  int _bestStreak = 0;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final results = await Future.wait([
      _repo.loadAll(),
      _scoreService.achievementPoints(),
      _scoreService.totalAnswered(),
      _scoreService.bestStreak(),
    ]);
    if (!mounted) return;
    setState(() {
      _idioms = results[0] as List<Idiom>;
      _points = results[1] as int;
      _totalAnswered = results[2] as int;
      _bestStreak = results[3] as int;
    });
  }

  Future<void> _startQuiz(int questionCount) async {
    final idioms = _idioms;
    if (idioms == null) return;
    final session = QuizSession.build(idioms, count: questionCount);
    final _ = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => QuizScreen(session: session),
      ),
    );
    await _bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final idioms = _idioms;

    return Scaffold(
      appBar: AppBar(title: const Text('四字熟語クイズ')),
      body: SafeArea(
        child: idioms == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AchievementCard(
                      points: _points,
                      totalAnswered: _totalAnswered,
                      bestStreak: _bestStreak,
                    ).animate().fadeIn(duration: 400.ms).slideY(
                          begin: -0.1,
                          end: 0,
                          duration: 400.ms,
                          curve: Curves.easeOut,
                        ),
                    const SizedBox(height: 28),
                    Text(
                      'クイズを始める',
                      style: GoogleFonts.notoSerifJp(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ModeTile(
                      title: '10問チャレンジ',
                      subtitle: 'さくっと腕試し。1回で最大120点。',
                      icon: Icons.bolt_rounded,
                      onTap: () => _startQuiz(10),
                    ),
                    const SizedBox(height: 10),
                    _ModeTile(
                      title: '20問じっくり',
                      subtitle: 'じっくり挑戦して業績ポイントを稼ごう。',
                      icon: Icons.menu_book_rounded,
                      onTap: () => _startQuiz(20),
                    ),
                    const SizedBox(height: 10),
                    _ModeTile(
                      title: '全100問マラソン',
                      subtitle: '収録している四字熟語をすべて出題。',
                      icon: Icons.emoji_events_rounded,
                      onTap: () => _startQuiz(idioms.length),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'ライブラリ',
                      style: GoogleFonts.notoSerifJp(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '収録 ${idioms.length} 個の四字熟語',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final int points;
  final int totalAnswered;
  final int bestStreak;

  const _AchievementCard({
    required this.points,
    required this.totalAnswered,
    required this.bestStreak,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium_rounded,
                  color: scheme.onPrimary, size: 22),
              const SizedBox(width: 8),
              Text(
                '業績ポイント',
                style: GoogleFonts.notoSansJp(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: scheme.onPrimary.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$points',
                style: GoogleFonts.notoSerifJp(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: scheme.onPrimary,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'pt',
                  style: GoogleFonts.notoSansJp(
                    fontSize: 16,
                    color: scheme.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatPill(
                label: '累計回答',
                value: '$totalAnswered',
                color: scheme.onPrimary,
              ),
              const SizedBox(width: 10),
              _StatPill(
                label: '最高連続正解',
                value: '$bestStreak',
                color: scheme.onPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatPill(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.notoSansJp(
              fontSize: 11,
              color: color.withValues(alpha: 0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.notoSerifJp(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ModeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.notoSerifJp(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.notoSansJp(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
