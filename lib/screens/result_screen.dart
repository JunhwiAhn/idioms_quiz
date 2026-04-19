import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../data/audio_service.dart';
import '../data/score_service.dart';

class ResultScreen extends StatefulWidget {
  final int correct;
  final int total;
  final int longestStreak;
  final RunOutcome outcome;

  const ResultScreen({
    super.key,
    required this.correct,
    required this.total,
    required this.longestStreak,
    required this.outcome,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audio = AudioService.instance;
      final perfect = widget.total > 0 && widget.correct == widget.total;
      if (perfect) {
        audio.playSfx(Sfx.perfect);
      } else {
        audio.playSfx(Sfx.clear);
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          audio.playSfx(Sfx.clearVoice);
        });
      }
    });
  }

  String get _title {
    final rate = widget.total == 0 ? 0.0 : widget.correct / widget.total;
    if (rate == 1.0) return '完璧です!';
    if (rate >= 0.8) return 'すばらしい!';
    if (rate >= 0.5) return 'その調子!';
    return 'つぎ、がんばろう。';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final correct = widget.correct;
    final total = widget.total;
    final longestStreak = widget.longestStreak;
    final outcome = widget.outcome;

    return Scaffold(
      appBar: AppBar(title: const Text('結果')),
      body: SafeArea(
        child: SingleChildScrollView(
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
                style: notoSerifJp(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              _ScoreCircle(correct: correct, total: total),
              const SizedBox(height: 28),
              if (outcome.leveledUp)
                _LevelUpCard(outcome: outcome)
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms)
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1, 1),
                      duration: 400.ms,
                      curve: Curves.easeOut,
                    ),
              if (outcome.leveledUp) const SizedBox(height: 16),
              if (outcome.totalDropped > 0)
                _DropsCard(outcome: outcome)
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms),
              if (outcome.totalDropped > 0) const SizedBox(height: 16),
              _StatRow(label: '正解数', value: '$correct / $total'),
              _StatRow(label: '最長連続正解', value: '$longestStreak'),
              _StatRow(
                label: '今回の獲得ポイント',
                value: '+${outcome.earned} pt',
                highlight: true,
              ),
              _StatRow(
                label: '累計業績ポイント',
                value: '${outcome.newTotalPoints} pt',
                highlight: true,
              ),
              _StatRow(label: '現在の段位', value: outcome.newRank.name),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () {
                  AudioService.instance.playBgm(Bgm.home);
                  Navigator.of(context).pop(true);
                },
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

class _DropsCard extends StatelessWidget {
  final RunOutcome outcome;
  const _DropsCard({required this.outcome});

  String _labelFor(HintKind k) => switch (k) {
        HintKind.fiftyFifty => '50:50',
        HintKind.reading => 'ふりがな',
        HintKind.kanji => '漢字一字',
      };

  IconData _iconFor(HintKind k) => switch (k) {
        HintKind.fiftyFifty => Icons.filter_alt_rounded,
        HintKind.reading => Icons.record_voice_over_rounded,
        HintKind.kanji => Icons.visibility_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final entries = outcome.hintDrops.entries
        .where((e) => e.value > 0)
        .toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_giftcard_rounded,
                  color: scheme.onTertiaryContainer, size: 20),
              const SizedBox(width: 6),
              Text(
                'ヒント獲得 ×${outcome.totalDropped}',
                style: notoSerifJp(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: scheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final e in entries)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: scheme.onTertiaryContainer.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_iconFor(e.key),
                          size: 14, color: scheme.onTertiaryContainer),
                      const SizedBox(width: 4),
                      Text(
                        '${_labelFor(e.key)} ×${e.value}',
                        style: notoSansJp(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: scheme.onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelUpCard extends StatelessWidget {
  final RunOutcome outcome;
  const _LevelUpCard({required this.outcome});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  color: scheme.onPrimary, size: 20),
              const SizedBox(width: 6),
              Text(
                '昇段しました!',
                style: notoSansJp(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: scheme.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                outcome.previousRank.name,
                style: notoSerifJp(
                  fontSize: 20,
                  color: scheme.onPrimary.withValues(alpha: 0.7),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.arrow_forward_rounded,
                    color: scheme.onPrimary, size: 20),
              ),
              Text(
                outcome.newRank.name,
                style: notoSerifJp(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: scheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
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
      width: 160,
      height: 160,
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
                style: notoSerifJp(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '%',
                style: notoSansJp(
                  fontSize: 13,
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
            style: notoSansJp(
              fontSize: 14,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: notoSerifJp(
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
