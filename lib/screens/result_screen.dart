import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../data/ad_service.dart';
import '../data/app_text.dart';
import '../data/audio_service.dart';
import '../data/kanken_tier.dart';
import '../data/pronunciation_service.dart';
import '../data/review_service.dart';
import '../data/score_service.dart';
import '../data/stage_plan.dart' show roundFailed;
import '../models/idiom.dart';
import '../widgets/app_ui.dart';

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
      final perfect = widget.total > 0 && widget.correct == widget.total;
      final failed =
          widget.outcome.isRoundRun && roundFailed(correct: widget.correct);
      if (failed) {
        audio.playSfx(Sfx.wrong);
      } else if (perfect) {
        PronunciationService.instance.speakSpanish('Muy bueno. Perfecto.');
      } else {
        audio.playSfx(Sfx.clear);
      }
    });
  }

  Future<void> _loadMastered() async {
    final snap = await ScoreService().snapshot();
    if (!mounted) return;
    setState(() => _masteredCount = snap.mastered.length);

    // A 5-star round is the friendliest moment to ask for a store rating; the
    // service decides whether this particular one qualifies.
    if (widget.outcome.isRoundRun) {
      await ReviewService.instance.maybeAskAfterRound(
        stars: widget.outcome.roundStars,
        clearedRounds: snap.roundStars.length,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final correct = widget.correct;
    final total = widget.total;
    final longestStreak = widget.longestStreak;
    final outcome = widget.outcome;
    final text = AppText(widget.language);
    final failed = outcome.isRoundRun && roundFailed(correct: correct);
    final allCombo = total > 0 && correct == total;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          primary: false,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                children: [
                  _ResultCelebrationHero(
                        correct: correct,
                        total: total,
                        longestStreak: longestStreak,
                        earned: outcome.earned,
                        language: widget.language,
                        isMarathon: widget.isMarathon,
                        failed: failed,
                        roundStars: outcome.roundStars,
                      )
                      .animate()
                      .fadeIn(duration: 240.ms)
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1, 1),
                        duration: allCombo ? 620.ms : 420.ms,
                        curve: Curves.easeOutBack,
                      )
                      .shimmer(
                        delay: allCombo ? 500.ms : 5.seconds,
                        duration: allCombo ? 1100.ms : 1.ms,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                  const SizedBox(height: 16),
                  _ResultActions(
                        language: widget.language,
                        failed: failed,
                        text: text,
                      )
                      .animate()
                      .fadeIn(delay: 180.ms, duration: 300.ms)
                      .slideY(begin: 0.12, end: 0, duration: 360.ms),
                  const SizedBox(height: 20),
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
                  _MasteryProgressCard(
                        outcome: outcome,
                        language: widget.language,
                      )
                      .animate()
                      .fadeIn(delay: 280.ms, duration: 400.ms)
                      .slideY(begin: 0.08, end: 0, duration: 420.ms),
                  const SizedBox(height: 16),
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
                  _StatRow(
                    label: text.totalPoints,
                    value: '${outcome.newTotalPoints} pt',
                    highlight: true,
                  ),
                  _StatRow(
                    label: text.currentRank,
                    value: text.rankLabel(outcome.newRank.name),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultCelebrationHero extends StatelessWidget {
  final int correct;
  final int total;
  final int longestStreak;
  final int earned;
  final StudyLanguage language;
  final bool isMarathon;
  final bool failed;
  final int? roundStars;

  const _ResultCelebrationHero({
    required this.correct,
    required this.total,
    required this.longestStreak,
    required this.earned,
    required this.language,
    required this.isMarathon,
    required this.failed,
    required this.roundStars,
  });

  bool get _allCombo => total > 0 && correct == total;

  String get _eyebrow => switch (language) {
    StudyLanguage.ko => isMarathon ? '마라톤 완료' : '퀴즈 완료',
    StudyLanguage.en => isMarathon ? 'MARATHON COMPLETE' : 'QUIZ COMPLETE',
    StudyLanguage.ja => isMarathon ? 'マラソン完走' : 'クイズ完了',
    StudyLanguage.pt => isMarathon ? 'MARATONA CONCLUÍDA' : 'QUIZ CONCLUÍDO',
  };

  String get _title {
    if (_allCombo) return 'ALL COMBO!';
    if (failed) {
      return switch (language) {
        StudyLanguage.ko => '아깝다, 한 번 더!',
        StudyLanguage.en => 'So close—one more go!',
        StudyLanguage.ja => '惜しい、もう一度！',
        StudyLanguage.pt => 'Quase lá — mais uma vez!',
      };
    }
    return switch (language) {
      StudyLanguage.ko => '멋지게 끝냈어요!',
      StudyLanguage.en => 'Great finish!',
      StudyLanguage.ja => 'ナイスフィニッシュ！',
      StudyLanguage.pt => 'Belo resultado!',
    };
  }

  String get _subtitle {
    if (_allCombo) {
      return switch (language) {
        StudyLanguage.ko => '한 문제도 놓치지 않은 완벽한 플레이예요',
        StudyLanguage.en => 'A flawless run without a single miss',
        StudyLanguage.ja => '一問も逃さないパーフェクトプレイ！',
        StudyLanguage.pt => 'Uma rodada perfeita, sem nenhum erro',
      };
    }
    return switch (language) {
      StudyLanguage.ko => '오늘의 기록을 멋지게 쌓았어요',
      StudyLanguage.en => 'Another strong result in the books',
      StudyLanguage.ja => '今日も素敵な記録を残しました',
      StudyLanguage.pt => 'Mais um bom resultado registrado',
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rate = total == 0 ? 0 : ((correct / total) * 100).round();
    final colors = _allCombo
        ? const [Color(0xFFFFB300), Color(0xFFF06423)]
        : failed
        ? [scheme.secondary, const Color(0xFF4959A8)]
        : [scheme.primary, const Color(0xFFE86A28)];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.32),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _allCombo ? Icons.auto_awesome_rounded : Icons.flag_rounded,
                size: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 6),
              Text(
                _eyebrow,
                style: notoSansJp(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.6,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_allCombo)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 5; i++)
                  Icon(
                        Icons.star_rounded,
                        color: Colors.white,
                        size: i == 2 ? 34 : 25,
                      )
                      .animate(delay: (80 * i).ms)
                      .scale(
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                        duration: 420.ms,
                        curve: Curves.elasticOut,
                      ),
              ],
            )
          else
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isMarathon ? Icons.emoji_events_rounded : Icons.check_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            _title,
            textAlign: TextAlign.center,
            style: notoSerifJp(
              fontSize: _allCombo ? 30 : 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _subtitle,
            textAlign: TextAlign.center,
            style: notoSansJp(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
          if (roundStars != null && !_allCombo) ...[
            const SizedBox(height: 12),
            AppStarRating(
              value: roundStars!,
              size: 29,
              filledColor: Colors.white,
              emptyColor: Colors.white.withValues(alpha: 0.3),
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ],
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                _ResultMetric(
                  icon: Icons.check_circle_rounded,
                  value: '$correct/$total',
                  label: switch (language) {
                    StudyLanguage.ko => '정답',
                    StudyLanguage.en => 'CORRECT',
                    StudyLanguage.ja => '正解',
                    StudyLanguage.pt => 'ACERTOS',
                  },
                ),
                _ResultMetricDivider(),
                _ResultMetric(
                  icon: Icons.local_fire_department_rounded,
                  value: '$longestStreak',
                  label: switch (language) {
                    StudyLanguage.ko => '최고 콤보',
                    StudyLanguage.en => 'BEST COMBO',
                    StudyLanguage.ja => '最高コンボ',
                    StudyLanguage.pt => 'MELHOR SEQUÊNCIA',
                  },
                ),
                _ResultMetricDivider(),
                _ResultMetric(
                  icon: Icons.bolt_rounded,
                  value: '+$earned',
                  label: switch (language) {
                    StudyLanguage.ko => '획득 점수',
                    StudyLanguage.en => 'POINTS',
                    StudyLanguage.ja => '獲得点数',
                    StudyLanguage.pt => 'PONTOS',
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : correct / total,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$rate%',
              style: notoSansJp(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ResultMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 19, color: Colors.white),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: notoSerifJp(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            style: notoSansJp(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultMetricDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 54,
      color: Colors.white.withValues(alpha: 0.22),
    );
  }
}

class _ResultActions extends StatelessWidget {
  final StudyLanguage language;
  final bool failed;
  final AppText text;

  const _ResultActions({
    required this.language,
    required this.failed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                icon: const Icon(Icons.home_rounded),
                label: Text(text.backHome),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  elevation: 5,
                ),
                icon: Icon(
                  failed
                      ? Icons.view_module_rounded
                      : Icons.arrow_forward_rounded,
                ),
                label: Text(_primaryAction(language, failed)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Spacer(),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: _RewardedAdButton(text: text)),
          ],
        ),
      ],
    );
  }
}

String _primaryAction(StudyLanguage language, bool failed) {
  if (failed) {
    return switch (language) {
      StudyLanguage.ko => '라운드로 돌아가기',
      StudyLanguage.en => 'Back to rounds',
      StudyLanguage.ja => 'ラウンドへ戻る',
      StudyLanguage.pt => 'Voltar às rodadas',
    };
  }
  return switch (language) {
    StudyLanguage.ko => '계속하기',
    StudyLanguage.en => 'Continue',
    StudyLanguage.ja => '続ける',
    StudyLanguage.pt => 'Continuar',
  };
}

class _MasteryProgressCard extends StatelessWidget {
  final RunOutcome outcome;
  final StudyLanguage language;
  const _MasteryProgressCard({required this.outcome, required this.language});

  int get _target {
    const milestones = [10, 30, 50, 100, 300, 500, 1000, 1500];
    return milestones.firstWhere(
      (value) => outcome.newMasteredCount < value,
      orElse: () => milestones.last,
    );
  }

  String _title(StudyLanguage language) => switch (language) {
    StudyLanguage.ko => '학습한 단어',
    StudyLanguage.ja => '覚えた単語',
    _ => 'Words learned',
  };

  String _gained(StudyLanguage language, int count) {
    if (count <= 0) {
      return switch (language) {
        StudyLanguage.ko => '이번 학습이 단어장에 반영됐어요',
        StudyLanguage.ja => '今回の学習が単語帳に反映されました',
        _ => 'This run updated your wordbook',
      };
    }
    return switch (language) {
      StudyLanguage.ko => '+$count개 새로 익힘',
      StudyLanguage.ja => '+$count語を新しく習得',
      _ => '+$count newly learned',
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final target = _target;
    final previous = outcome.previousMasteredCount.clamp(0, target);
    final current = outcome.newMasteredCount.clamp(0, target);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppUi.cardRadius),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.collections_bookmark_rounded, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _title(language),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: notoSerifJp(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _gained(language, outcome.masteredGained),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: notoSansJp(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: previous / target, end: current / target),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 9,
                  backgroundColor: scheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<int>(
            tween: IntTween(
              begin: outcome.previousMasteredCount,
              end: outcome.newMasteredCount,
            ),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return Row(
                children: [
                  Text(
                    '$value',
                    style: notoSerifJp(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      '/ $target',
                      style: notoSansJp(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
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
    HintKind.reading => '50:50',
    HintKind.time => 'Time+',
  };

  IconData _iconFor(HintKind k) => switch (k) {
    HintKind.fiftyFifty => Icons.filter_alt_rounded,
    HintKind.reading => Icons.filter_alt_rounded,
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
        borderRadius: BorderRadius.circular(AppUi.cardRadius),
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
        borderRadius: BorderRadius.circular(AppUi.cardRadius),
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
          Expanded(
            child: Text(
              text.levelUp,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: notoSerifJp(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: scheme.onTertiaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 8),
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
        borderRadius: BorderRadius.circular(AppUi.cardRadius),
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
              Flexible(
                child: Text(
                  text.rankLabel(outcome.previousRank.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: notoSerifJp(
                    fontSize: 20,
                    color: scheme.onPrimary.withValues(alpha: 0.7),
                  ),
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
              Flexible(
                child: Text(
                  text.rankLabel(outcome.newRank.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: notoSerifJp(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: scheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
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
        borderRadius: BorderRadius.circular(AppUi.cardRadius),
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
            ],
          ),
          if (prevHasRecord && !updated) ...[
            const SizedBox(height: 6),
            Text(
              text.bestScore(
                outcome.newBestMarathon,
                outcome.newBestMarathonTotal,
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
        borderRadius: BorderRadius.circular(AppUi.cardRadius),
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
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: notoSansJp(fontSize: 14, color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: notoSerifJp(
                fontSize: highlight ? 20 : 16,
                fontWeight: FontWeight.w700,
                color: highlight ? scheme.primary : scheme.onSurface,
              ),
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
      HintKind.reading => '50:50',
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
    return ValueListenableBuilder<bool>(
      valueListenable: AdService.instance.rewardedReadyListenable,
      builder: (context, ready, _) {
        if (!ready && !_busy) return const SizedBox.shrink();
        return OutlinedButton.icon(
          onPressed: ready && !_busy ? _onTap : null,
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
              : const Icon(Icons.card_giftcard_rounded),
          label: Text(
            _busy ? widget.text.loadingAd : widget.text.watchVideoForItem,
            style: notoSerifJp(fontSize: 14, fontWeight: FontWeight.w800),
          ),
        );
      },
    );
  }
}
