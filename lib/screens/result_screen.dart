import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../data/ad_service.dart';
import '../data/app_text.dart';
import '../data/audio_service.dart';
import '../data/kanken_tier.dart';
import '../data/score_service.dart';
import '../data/stage_plan.dart' show kMinCorrectToClear, roundFailed;
import '../models/idiom.dart';

class ResultScreen extends StatefulWidget {
  final int correct;
  final int total;
  final int longestStreak;
  final RunOutcome outcome;
  final bool isMarathon;
  final StudyLanguage language;

  const ResultScreen({
    super.key,
    required this.correct,
    required this.total,
    required this.longestStreak,
    required this.outcome,
    required this.language,
    this.isMarathon = false,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int? _masteredCount;

  @override
  void initState() {
    super.initState();
    _loadMastered();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audio = AudioService.instance;
      // Stage rounds treat 8+ / 10 as "great" → perfect SFX. Marathon and
      // other runs need 100% correct.
      final perfect = widget.outcome.isRoundRun
          ? widget.correct >= 8
          : widget.total > 0 && widget.correct == widget.total;
      final failed =
          widget.outcome.isRoundRun && roundFailed(correct: widget.correct);
      if (failed) {
        audio.playSfx(Sfx.wrong);
      } else if (perfect) {
        audio.playSfx(Sfx.perfect);
      } else {
        audio.playSfx(Sfx.clear);
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          audio.playSfx(Sfx.clearVoice);
        });
      }
      if (widget.outcome.leveledUp && mounted) {
        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          _showLevelUpDialog();
        });
      }
    });
  }

  Future<void> _showLevelUpDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _LevelUpDialog(
        outcome: widget.outcome,
        text: AppText(widget.language),
      ),
    );
  }

  Future<void> _loadMastered() async {
    final snap = await ScoreService().snapshot();
    if (!mounted) return;
    setState(() => _masteredCount = snap.mastered.length);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final correct = widget.correct;
    final total = widget.total;
    final longestStreak = widget.longestStreak;
    final outcome = widget.outcome;
    final text = AppText(widget.language);
    final rate = widget.total == 0 ? 0.0 : widget.correct / widget.total;

    return Scaffold(
      appBar: AppBar(title: Text(text.result)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Icon(
                Icons.emoji_events_rounded,
                size: 80,
                color: scheme.primary,
              ).animate().scale(
                begin: const Offset(0.6, 0.6),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.easeOutBack,
              ),
              const SizedBox(height: 8),
              Text(
                text.resultTitle(rate),
                style: notoSerifJp(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              if (outcome.isRoundRun)
                _RoundStarsCard(
                      outcome: outcome,
                      correct: correct,
                      total: total,
                      text: text,
                    )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    )
              else
                _ScoreCircle(correct: correct, total: total),
              const SizedBox(height: 28),
              if (outcome.leveledUp)
                _LevelUpCard(outcome: outcome, text: text)
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 400.ms)
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1, 1),
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    ),
              if (outcome.leveledUp) const SizedBox(height: 12),
              if (outcome.rankUp)
                _RankUpCard(outcome: outcome, text: text)
                    .animate()
                    .fadeIn(delay: 250.ms, duration: 400.ms)
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1, 1),
                      duration: 400.ms,
                      curve: Curves.easeOut,
                    ),
              if (outcome.rankUp) const SizedBox(height: 16),
              if (widget.isMarathon) ...[
                _MarathonScoreCard(
                      correct: correct,
                      total: total,
                      outcome: outcome,
                      text: text,
                    )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 400.ms)
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1, 1),
                      duration: 400.ms,
                      curve: Curves.easeOut,
                    ),
                const SizedBox(height: 12),
              ],
              if (widget.isMarathon && _masteredCount != null) ...[
                _MarathonTierCard(
                  masteredCount: _masteredCount!,
                  text: text,
                ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
                const SizedBox(height: 16),
              ],
              if (outcome.totalDropped > 0)
                _DropsCard(
                  outcome: outcome,
                  text: text,
                ).animate().fadeIn(delay: 450.ms, duration: 400.ms),
              if (outcome.totalDropped > 0) const SizedBox(height: 16),
              _StatRow(label: text.level, value: '${outcome.newLevel}'),
              _StatRow(label: text.correctCount, value: '$correct / $total'),
              _StatRow(label: text.bestStreak, value: '$longestStreak'),
              _StatRow(
                label: text.runPoints,
                value: '+${outcome.earned} pt',
                highlight: true,
              ),
              _StatRow(
                label: text.totalPoints,
                value: '${outcome.newTotalPoints} pt',
                highlight: true,
              ),
              _StatRow(label: text.currentRank, value: outcome.newRank.name),
              const SizedBox(height: 24),
              _RewardedAdButton(text: text),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {
                  AudioService.instance.stopBgm();
                  Navigator.of(context).pop(true);
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: Text(text.backHome),
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
  final AppText text;
  const _DropsCard({required this.outcome, required this.text});

  String _labelFor(HintKind k) => switch (k) {
    HintKind.fiftyFifty => '50:50',
    HintKind.reading => 'Pron.',
    HintKind.time => 'Time+',
  };

  IconData _iconFor(HintKind k) => switch (k) {
    HintKind.fiftyFifty => Icons.filter_alt_rounded,
    HintKind.reading => Icons.record_voice_over_rounded,
    HintKind.time => Icons.more_time_rounded,
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
              Icon(
                Icons.card_giftcard_rounded,
                color: scheme.onTertiaryContainer,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                text.itemsGained(outcome.totalDropped),
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
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.onTertiaryContainer.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _iconFor(e.key),
                        size: 14,
                        color: scheme.onTertiaryContainer,
                      ),
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
  final AppText text;
  const _LevelUpCard({required this.outcome, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: scheme.tertiaryContainer,
        border: Border.all(color: scheme.tertiary, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(
            Icons.trending_up_rounded,
            color: scheme.onTertiaryContainer,
            size: 22,
          ),
          const SizedBox(width: 10),
          Text(
            text.levelUp,
            style: notoSerifJp(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: scheme.onTertiaryContainer,
            ),
          ),
          const Spacer(),
          Text(
            '${outcome.previousLevel}',
            style: notoSerifJp(
              fontSize: 18,
              color: scheme.onTertiaryContainer.withValues(alpha: 0.6),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.arrow_forward_rounded,
              color: scheme.onTertiaryContainer,
              size: 18,
            ),
          ),
          Text(
            '${outcome.newLevel}',
            style: notoSerifJp(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: scheme.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _RankUpCard extends StatelessWidget {
  final RunOutcome outcome;
  final AppText text;
  const _RankUpCard({required this.outcome, required this.text});

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
              Icon(
                Icons.auto_awesome_rounded,
                color: scheme.onPrimary,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                text.rankUp,
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
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: scheme.onPrimary,
                  size: 20,
                ),
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

class _RoundStarsCard extends StatelessWidget {
  final RunOutcome outcome;
  final int correct;
  final int total;
  final AppText text;
  const _RoundStarsCard({
    required this.outcome,
    required this.correct,
    required this.total,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stars = outcome.roundStars ?? 0;
    final prev = outcome.previousRoundStars ?? 0;
    final improved = outcome.roundStarsImproved;
    final failed = roundFailed(correct: correct);
    final gradient = failed
        ? [scheme.error, scheme.errorContainer]
        : [scheme.primary, scheme.tertiary];
    final onGrad = failed ? scheme.onError : scheme.onPrimary;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          if (failed) ...[
            Icon(Icons.error_outline_rounded, color: onGrad, size: 46),
            const SizedBox(height: 8),
            Text(
              text.roundFailed,
              style: notoSerifJp(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: onGrad,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              text.roundFailedBody(kMinCorrectToClear, correct, total),
              textAlign: TextAlign.center,
              style: notoSansJp(
                fontSize: 12,
                color: onGrad.withValues(alpha: 0.85),
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 5; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Icon(
                      i < stars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 46,
                      color: i < stars
                          ? Colors.amber
                          : onGrad.withValues(alpha: 0.4),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              improved
                  ? (prev == 0 ? text.cleared : text.bestUpdated)
                  : text.thisRunStars(stars),
              style: notoSerifJp(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: onGrad,
              ),
            ),
            if (prev > 0) ...[
              const SizedBox(height: 4),
              Text(
                text.bestStars(stars > prev ? stars : prev),
                style: notoSansJp(
                  fontSize: 12,
                  color: onGrad.withValues(alpha: 0.85),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _MarathonScoreCard extends StatelessWidget {
  final int correct;
  final int total;
  final RunOutcome outcome;
  final AppText text;
  const _MarathonScoreCard({
    required this.correct,
    required this.total,
    required this.outcome,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final updated = outcome.marathonBestUpdated;
    final prevHasRecord =
        outcome.previousBestMarathon > 0 ||
        (outcome.marathonBestUpdated && outcome.previousBestMarathon == 0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: updated
            ? LinearGradient(
                colors: [scheme.primary, scheme.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: updated ? null : scheme.surface,
        border: updated ? null : Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                updated
                    ? Icons.emoji_events_rounded
                    : Icons.emoji_events_outlined,
                color: updated ? scheme.onPrimary : scheme.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                updated ? text.marathonBestUpdated : text.marathonRecord,
                style: notoSerifJp(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: updated ? scheme.onPrimary : scheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$correct',
                style: notoSerifJp(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  color: updated ? scheme.onPrimary : scheme.onSurface,
                ),
              ),
              Text(
                ' / $total',
                style: notoSansJp(
                  fontSize: 16,
                  color: updated
                      ? scheme.onPrimary.withValues(alpha: 0.8)
                      : scheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: updated
                      ? scheme.onPrimary.withValues(alpha: 0.18)
                      : scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  text.percentileLabel(marathonPercentile(correct, total)),
                  style: notoSansJp(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: updated
                        ? scheme.onPrimary
                        : scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          if (prevHasRecord && !updated) ...[
            const SizedBox(height: 6),
            Text(
              text.bestScore(
                outcome.newBestMarathon,
                outcome.newBestMarathonTotal,
                text.percentileLabel(
                  marathonPercentile(
                    outcome.newBestMarathon,
                    outcome.newBestMarathonTotal,
                  ),
                ),
              ),
              style: notoSansJp(fontSize: 11, color: scheme.onSurfaceVariant),
            ),
          ],
          if (updated && outcome.previousBestMarathon > 0) ...[
            const SizedBox(height: 6),
            Text(
              text.previousBest(
                outcome.previousBestMarathon,
                outcome.newBestMarathonTotal,
              ),
              style: notoSansJp(
                fontSize: 11,
                color: scheme.onPrimary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MarathonTierCard extends StatelessWidget {
  final int masteredCount;
  final AppText text;
  const _MarathonTierCard({required this.masteredCount, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tier = kankenTierFor(masteredCount);
    final next = nextKankenTierFor(masteredCount);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  text.vocabularyTier,
                  style: notoSansJp(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                text.percentileLabel(tier.percentile),
                style: notoSansJp(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                text.tierLabel(tier.label),
                style: notoSerifJp(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  text.tierSubtitle(tier.subtitle),
                  style: notoSansJp(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            next == null
                ? text.masteredTopTier(masteredCount)
                : text.masteredToNext(
                    masteredCount,
                    next.min - masteredCount,
                    text.tierLabel(next.label),
                  ),
            style: notoSansJp(fontSize: 11, color: scheme.onSurfaceVariant),
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
                style: notoSansJp(fontSize: 13, color: scheme.onSurfaceVariant),
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
            style: notoSansJp(fontSize: 14, color: scheme.onSurfaceVariant),
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

class _LevelUpDialog extends StatefulWidget {
  final RunOutcome outcome;
  final AppText text;
  const _LevelUpDialog({required this.outcome, required this.text});

  @override
  State<_LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<_LevelUpDialog> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confetti.play();
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final o = widget.outcome;
    final text = widget.text;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [scheme.primary, scheme.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                      Icons.workspace_premium_rounded,
                      size: 72,
                      color: scheme.onPrimary,
                    )
                    .animate()
                    .scale(
                      begin: const Offset(0.3, 0.3),
                      end: const Offset(1, 1),
                      duration: 450.ms,
                      curve: Curves.easeOutBack,
                    )
                    .shimmer(
                      delay: 350.ms,
                      duration: 900.ms,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                const SizedBox(height: 12),
                Text(
                      text.levelUp,
                      style: notoSerifJp(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: scheme.onPrimary,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 300.ms)
                    .slideY(begin: 0.2, end: 0, duration: 400.ms),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${o.previousLevel}',
                      style: notoSerifJp(
                        fontSize: 22,
                        color: scheme.onPrimary.withValues(alpha: 0.6),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: scheme.onPrimary,
                        size: 24,
                      ),
                    ),
                    Text(
                      '${o.newLevel}',
                      style: notoSerifJp(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        height: 1,
                        color: scheme.onPrimary,
                      ),
                    ).animate().scale(
                      begin: const Offset(0.6, 0.6),
                      end: const Offset(1, 1),
                      delay: 300.ms,
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  text.newLevelReached,
                  style: notoSerifJp(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: scheme.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.onPrimary,
                      foregroundColor: scheme.primary,
                    ),
                    child: Text(text.continueLabel),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -8,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: pi / 2,
              maxBlastForce: 22,
              minBlastForce: 12,
              emissionFrequency: 0.08,
              numberOfParticles: 30,
              gravity: 0.25,
              shouldLoop: false,
              colors: const [
                Color(0xFFFFD54F),
                Color(0xFFE6A817),
                Color(0xFFB03A2E),
                Color(0xFF8CB369),
                Color(0xFF4A6FA5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardedAdButton extends StatefulWidget {
  final AppText text;
  const _RewardedAdButton({required this.text});

  @override
  State<_RewardedAdButton> createState() => _RewardedAdButtonState();
}

class _RewardedAdButtonState extends State<_RewardedAdButton> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    AdService.instance.preloadRewarded();
  }

  Future<void> _onTap() async {
    if (_busy) return;
    setState(() => _busy = true);
    final granted = await AdService.instance.showRewarded();
    if (!mounted) return;
    setState(() => _busy = false);
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.text.adLoadFailed,
            style: notoSansJp(fontSize: 12),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final kind = await ScoreService().grantRandomHint();
    if (!mounted) return;
    final label = switch (kind) {
      HintKind.fiftyFifty => '50:50',
      HintKind.reading => 'Pron.',
      HintKind.time => 'Time+',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.card_giftcard_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              widget.text.itemGainedWithLabel(label),
              style: notoSansJp(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!AdService.instance.isSupported) {
      return const SizedBox.shrink();
    }
    final scheme = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: _busy ? null : _onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        side: BorderSide(color: scheme.primary, width: 1.4),
        foregroundColor: scheme.primary,
      ),
      icon: _busy
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
              ),
            )
          : const Icon(Icons.play_circle_fill_rounded),
      label: Text(
        _busy ? widget.text.loadingAd : widget.text.watchVideoForItem,
        style: notoSerifJp(fontSize: 14, fontWeight: FontWeight.w800),
      ),
    );
  }
}
