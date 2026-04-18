import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultScreen extends StatelessWidget {
  final int correct;
  final int total;
  final int longestStreak;
  final int newTotalPoints;

  const ResultScreen({
    super.key,
    required this.correct,
    required this.total,
    required this.longestStreak,
    required this.newTotalPoints,
  });

  int get _earned =>
      correct * 10 + (longestStreak >= 3 ? longestStreak * 2 : 0);

  String get _title {
    final rate = correct / total;
    if (rate == 1.0) return '完璧です!';
    if (rate >= 0.8) return 'すばらしい!';
    if (rate >= 0.5) return 'その調子!';
    return 'つぎ、がんばろう。';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('結果')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Icon(Icons.emoji_events_rounded,
                      size: 80, color: scheme.primary)
                  .animate()
                  .scale(
                    begin: const Offset(0.6, 0.6),
                    end: const Offset(1, 1),
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: 8),
              Text(
                _title,
                style: GoogleFonts.notoSerifJp(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              _ScoreCircle(correct: correct, total: total),
              const SizedBox(height: 28),
              _StatRow(label: '正解数', value: '$correct / $total'),
              _StatRow(label: '最長連続正解', value: '$longestStreak'),
              _StatRow(
                label: '今回の獲得ポイント',
                value: '+$_earned pt',
                highlight: true,
              ),
              _StatRow(
                label: '累計業績ポイント',
                value: '$newTotalPoints pt',
                highlight: true,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: const Text('ホームへ戻る'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreCircle extends StatelessWidget {
  final int correct;
  final int total;
  const _ScoreCircle({required this.correct, required this.total});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rate = total == 0 ? 0.0 : correct / total;
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: rate,
              strokeWidth: 12,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(rate * 100).round()}',
                style: GoogleFonts.notoSerifJp(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '%',
                style: GoogleFonts.notoSansJp(
                  fontSize: 14,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _StatRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.notoSansJp(
              fontSize: 14,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.notoSerifJp(
              fontSize: highlight ? 20 : 16,
              fontWeight: FontWeight.w700,
              color: highlight ? scheme.primary : scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
