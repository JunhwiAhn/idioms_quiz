import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/app_text.dart';
import '../data/audio_service.dart';
import '../data/quiz_session.dart';
import '../data/score_service.dart';
import '../data/stage_plan.dart' show starsForRound;
import '../theme/app_theme.dart';
import 'result_screen.dart';

const int kQuestionSeconds = 20;
const int kTimeHintBonus = 10;

class QuizScreen extends StatefulWidget {
  final QuizSession session;
  final Map<HintKind, int> initialHints;
  final bool isMarathon;
  final int? roundStageIndex;
  final int? roundRoundIndex;
  const QuizScreen({
    super.key,
    required this.session,
    required this.initialHints,
    this.isMarathon = false,
    this.roundStageIndex,
    this.roundRoundIndex,
  });

  bool get isStageRound =>
      roundStageIndex != null && roundRoundIndex != null;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _scoreService = ScoreService();
  late Map<HintKind, int> _hints;
  late final ConfettiController _confetti;

  int? _picked;
  bool _revealed = false;
  HintKind? _lastDrop;

  // Per-question hint state
  bool _readingRevealed = false;
  Set<int> _eliminated = {};

  // Per-question countdown
  Timer? _ticker;
  int _secondsLeft = kQuestionSeconds;

  @override
  void initState() {
    super.initState();
    _hints = {...widget.initialHints};
    _confetti = ConfettiController(duration: const Duration(milliseconds: 900));
    _startTimer();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _confetti.dispose();
    super.dispose();
  }

  void _startTimer() {
    _ticker?.cancel();
    _secondsLeft = kQuestionSeconds;
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        t.cancel();
        _timeOut();
      }
    });
  }

  bool _shouldShowChoice(int i) {
    if (!_revealed) return true;
    // Answer was correct → show all for completeness.
    if (_picked == _q.correctIndex) return true;
    // Answer was wrong (or timed out) → show only the picked wrong tile
    // and the correct answer; hide everything else.
    return i == _picked || i == _q.correctIndex;
  }

  void _timeOut() {
    if (_revealed) return;
    // Treat as wrong — submit a pick that cannot match correct.
    final result = widget.session.submit(-1);
    AudioService.instance.playSfx(Sfx.wrong);
    setState(() {
      _picked = null;
      _revealed = true;
      _lastDrop = result.droppedHint;
    });
  }

  QuizQuestion get _q => widget.session.current;
  int get _index => widget.session.currentIndex;
  int get _total => widget.session.questions.length;

  void _pick(int i) {
    if (_revealed || _eliminated.contains(i)) return;
    _ticker?.cancel();
    final result = widget.session.submit(i);
    if (result.correct) {
      _confetti.play();
      AudioService.instance.playSfx(Sfx.correct);
    } else {
      AudioService.instance.playSfx(Sfx.wrong);
    }
    setState(() {
      _picked = i;
      _revealed = true;
      _lastDrop = result.droppedHint;
      if (result.droppedHint != null) {
        _hints[result.droppedHint!] = (_hints[result.droppedHint!] ?? 0) + 1;
      }
    });
  }

  Future<void> _next() async {
    widget.session.advance();
    if (widget.session.isFinished) {
      int? stars;
      if (widget.isStageRound) {
        stars = starsForRound(
          correct: widget.session.correctCount,
          total: widget.session.questions.length,
        );
      }
      final outcome = await _scoreService.commitRun(
        correct: widget.session.correctCount,
        total: widget.session.questions.length,
        longestStreak: widget.session.longestStreak,
        correctIdioms: widget.session.correctIdioms,
        droppedHints: widget.session.droppedHints,
        isMarathon: widget.isMarathon,
        roundStageIndex: widget.roundStageIndex,
        roundRoundIndex: widget.roundRoundIndex,
        roundStars: stars,
      );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            correct: widget.session.correctCount,
            total: widget.session.questions.length,
            longestStreak: widget.session.longestStreak,
            outcome: outcome,
            language: widget.session.questions.first.language,
            isMarathon: widget.isMarathon,
          ),
        ),
      );
    } else {
      setState(() {
        _picked = null;
        _revealed = false;
        _lastDrop = null;
        _readingRevealed = false;
        _eliminated = {};
      });
      _startTimer();
    }
  }

  bool _hintUsable(HintKind kind) {
    if ((_hints[kind] ?? 0) <= 0) return false;
    if (_revealed) return false;
    switch (kind) {
      case HintKind.fiftyFifty:
        return _eliminated.length < 2;
      case HintKind.reading:
        if (_readingRevealed) return false;
        return _q.mode != QuizMode.wordLookup;
      case HintKind.time:
        return _secondsLeft < kQuestionSeconds;
    }
  }

  Future<void> _useHint(HintKind kind) async {
    if (!_hintUsable(kind)) return;
    final ok = await _scoreService.consumeHint(kind);
    if (!ok) return;
    setState(() {
      _hints[kind] = (_hints[kind] ?? 0) - 1;
      switch (kind) {
        case HintKind.fiftyFifty:
          final wrongs = <int>[];
          for (var i = 0; i < _q.choices.length; i++) {
            if (i != _q.correctIndex && !_eliminated.contains(i)) wrongs.add(i);
          }
          wrongs.shuffle();
          _eliminated.addAll(wrongs.take(2));
          break;
        case HintKind.reading:
          _readingRevealed = true;
          break;
        case HintKind.time:
          _secondsLeft = (_secondsLeft + kTimeHintBonus)
              .clamp(0, kQuestionSeconds);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final progress = _index / _total;
    final text = AppText(_q.language);

    return Scaffold(
      appBar: AppBar(
        title: Text(text.questionCounter(_index + 1, _total)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            AudioService.instance.stopBgm();
            Navigator.of(context).maybePop();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _q.mode.label,
                  style: notoSansJp(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              LinearProgressIndicator(
                value: progress,
            minHeight: 4,
            backgroundColor: scheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TimerBar(
                    secondsLeft: _secondsLeft,
                    totalSeconds: kQuestionSeconds,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    switch (_q.mode) {
                      QuizMode.wordLookup => text.meaningToWord,
                      QuizMode.sentenceBlank => text.blankQuestion,
                      QuizMode.translationLookup => text.wordToMeaning,
                    },
                    textAlign: TextAlign.center,
                    style: notoSansJp(
                      fontSize: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _PromptDisplay(
                    question: _q,
                    readingRevealed: _readingRevealed,
                    fullReveal: _revealed,
                  ),
                  if (_revealed) ...[
                    const SizedBox(height: 14),
                    _MeaningRevealCard(question: _q)
                        .animate()
                        .fadeIn(duration: 300.ms),
                  ],
                  const SizedBox(height: 24),
                  _HintBar(
                    hints: _hints,
                    usable: {
                      for (final k in HintKind.values) k: _hintUsable(k),
                    },
                    onUse: _useHint,
                  ),
                  if (_lastDrop != null) ...[
                    const SizedBox(height: 10),
                    _DropBanner(kind: _lastDrop!)
                        .animate(key: ValueKey(_index))
                        .fadeIn(duration: 250.ms)
                        .slideY(begin: -0.2, end: 0, duration: 300.ms),
                  ],
                  const SizedBox(height: 20),
                  for (int i = 0; i < _q.choices.length; i++)
                    if (_shouldShowChoice(i))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ChoiceTile(
                          index: i,
                          text: _q.choices[i],
                          subText: _q.mode == QuizMode.wordLookup
                              ? _q.readingOf[_q.choices[i]]
                              : null,
                          picked: _picked,
                          correct: _q.correctIndex,
                          revealed: _revealed,
                          eliminated: _eliminated.contains(i),
                          onTap: () => _pick(i),
                        ),
                      ),
                ],
              ),
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _revealed ? 1 : 0,
              child: FilledButton(
                onPressed: _revealed ? _next : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: Text(
                  widget.session.currentIndex == _total - 1
                      ? 'See result'
                      : 'Next question',
                ),
              ),
            ),
          ),
        ],
      ),
          // Top center burst
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: pi / 2,
              maxBlastForce: 28,
              minBlastForce: 12,
              emissionFrequency: 0.08,
              numberOfParticles: 28,
              gravity: 0.25,
              shouldLoop: false,
              colors: [
                scheme.primary,
                scheme.tertiary,
                scheme.secondary,
                scheme.primaryContainer,
                const Color(0xFFFFD166),
                const Color(0xFFEF476F),
              ],
            ),
          ),
          // Left side cross-fire
          Align(
            alignment: Alignment.centerLeft,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: -pi / 5,
              maxBlastForce: 24,
              minBlastForce: 10,
              emissionFrequency: 0.08,
              numberOfParticles: 16,
              gravity: 0.25,
              shouldLoop: false,
              colors: [
                scheme.primary,
                scheme.tertiary,
                const Color(0xFFFFD166),
              ],
            ),
          ),
          // Right side cross-fire
          Align(
            alignment: Alignment.centerRight,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: pi + pi / 5,
              maxBlastForce: 24,
              minBlastForce: 10,
              emissionFrequency: 0.08,
              numberOfParticles: 16,
              gravity: 0.25,
              shouldLoop: false,
              colors: [
                scheme.secondary,
                scheme.primaryContainer,
                const Color(0xFFEF476F),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptDisplay extends StatelessWidget {
  final QuizQuestion question;
  final bool readingRevealed;
  final bool fullReveal;

  const _PromptDisplay({
    required this.question,
    required this.readingRevealed,
    required this.fullReveal,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final idiom = question.idiom;

    if (question.mode == QuizMode.wordLookup) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          children: [
            Text(
              idiom.meaningFor(question.language),
              textAlign: TextAlign.center,
              style: notoSerifJp(
                fontSize: 17,
                height: 1.6,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            _LevelChip(level: idiom.level),
          ],
        ),
      );
    }

    if (question.mode == QuizMode.sentenceBlank) {
      final showPronunciation = readingRevealed || fullReveal;
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          children: [
            Text(
              idiom.blankedExample,
              textAlign: TextAlign.center,
              style: notoSerifJp(
                fontSize: 19,
                height: 1.6,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: showPronunciation ? 1 : 0,
              child: Text(
                showPronunciation ? idiom.answer : '•••••',
                style: notoSansJp(
                  fontSize: 13,
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _LevelChip(level: idiom.level),
          ],
        ),
      );
    }

    return Column(
      children: [
        Text(
          idiom.idiom,
          textAlign: TextAlign.center,
          style: AppTheme.idiomDisplay(context),
        ).animate(key: ValueKey(idiom.idiom)).fadeIn(duration: 350.ms),
        const SizedBox(height: 12),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: 1,
          child: Text(
            idiom.reading,
            style: notoSansJp(
              fontSize: 14,
              color: scheme.onSurfaceVariant,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'DELE ${idiom.level}',
            style: notoSansJp(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: scheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}

class _LevelChip extends StatelessWidget {
  final String level;
  const _LevelChip({required this.level});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'DELE $level',
        style: notoSansJp(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _DropBanner extends StatelessWidget {
  final HintKind kind;
  const _DropBanner({required this.kind});

  String get _label => switch (kind) {
        HintKind.fiftyFifty => '50:50',
        HintKind.reading => 'Pron.',
        HintKind.time => 'Time+',
      };

  IconData get _icon => switch (kind) {
        HintKind.fiftyFifty => Icons.filter_alt_rounded,
        HintKind.reading => Icons.record_voice_over_rounded,
        HintKind.time => Icons.more_time_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.card_giftcard_rounded,
              color: scheme.onTertiaryContainer, size: 20),
          const SizedBox(width: 8),
          Text(
            'Item gained!',
            style: notoSerifJp(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: scheme.onTertiaryContainer,
            ),
          ),
          const Spacer(),
          Icon(_icon, color: scheme.onTertiaryContainer, size: 16),
          const SizedBox(width: 4),
          Text(
            '$_label ×1',
            style: notoSansJp(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: scheme.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _HintBar extends StatelessWidget {
  final Map<HintKind, int> hints;
  final Map<HintKind, bool> usable;
  final Future<void> Function(HintKind) onUse;

  const _HintBar({
    required this.hints,
    required this.usable,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _HintButton(
            icon: Icons.filter_alt_rounded,
            label: '50:50',
            count: hints[HintKind.fiftyFifty] ?? 0,
            enabled: usable[HintKind.fiftyFifty] ?? false,
            onTap: () => onUse(HintKind.fiftyFifty),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _HintButton(
            icon: Icons.record_voice_over_rounded,
            label: 'Pron.',
            count: hints[HintKind.reading] ?? 0,
            enabled: usable[HintKind.reading] ?? false,
            onTap: () => onUse(HintKind.reading),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _HintButton(
            icon: Icons.more_time_rounded,
            label: 'Time+',
            count: hints[HintKind.time] ?? 0,
            enabled: usable[HintKind.time] ?? false,
            onTap: () => onUse(HintKind.time),
          ),
        ),
      ],
    );
  }
}

class _HintButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool enabled;
  final VoidCallback onTap;

  const _HintButton({
    required this.icon,
    required this.label,
    required this.count,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = enabled && count > 0;
    return Material(
      color: active ? scheme.secondaryContainer : scheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: active ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: active
                        ? scheme.onSecondaryContainer
                        : scheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: notoSansJp(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: active
                          ? scheme.onSecondaryContainer
                          : scheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '×$count',
                style: notoSerifJp(
                  fontSize: 12,
                  color: active
                      ? scheme.onSecondaryContainer
                      : scheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final int index;
  final String text;
  final String? subText;
  final int? picked;
  final int correct;
  final bool revealed;
  final bool eliminated;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.index,
    required this.text,
    required this.subText,
    required this.picked,
    required this.correct,
    required this.revealed,
    required this.eliminated,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Color bg = scheme.surface;
    Color border = scheme.outlineVariant;
    Color textColor = scheme.onSurface;
    Color subTextColor = scheme.onSurfaceVariant;
    IconData? trailing;
    Color? trailingColor;
    double opacity = 1;

    if (eliminated) {
      opacity = 0.35;
    }

    final isCorrectReveal = revealed && index == correct;
    List<BoxShadow>? shadows;

    if (revealed) {
      if (index == correct) {
        bg = AppTheme.correctBg;
        border = AppTheme.correctBorder;
        textColor = AppTheme.correctFg;
        subTextColor = AppTheme.correctFg.withValues(alpha: 0.75);
        trailing = Icons.check_circle_rounded;
        trailingColor = AppTheme.correctFg;
        shadows = [
          BoxShadow(
            color: AppTheme.correctBorder.withValues(alpha: 0.45),
            blurRadius: 22,
            spreadRadius: 1,
          ),
        ];
      } else if (index == picked) {
        bg = scheme.errorContainer;
        border = scheme.error;
        textColor = scheme.onErrorContainer;
        subTextColor = scheme.onErrorContainer.withValues(alpha: 0.75);
        trailing = Icons.cancel_rounded;
        trailingColor = scheme.error;
      }
    } else if (picked == index) {
      border = scheme.primary;
    }

    final letter = String.fromCharCode('A'.codeUnitAt(0) + index);

    final tile = Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: shadows,
        ),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: revealed || eliminated ? null : onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: border,
                  width: isCorrectReveal ? 2.2 : 1.5,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: textColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      letter,
                      style: notoSerifJp(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text,
                          style: notoSerifJp(
                            fontSize: subText != null ? 20 : 15,
                            fontWeight: subText != null
                                ? FontWeight.w700
                                : FontWeight.w500,
                            height: 1.5,
                            color: textColor,
                          ),
                        ),
                        if (subText != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subText!,
                            style: notoSansJp(
                              fontSize: 12,
                              color: subTextColor,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailing, color: trailingColor),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (!isCorrectReveal) return tile;
    return tile
        .animate()
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 180.ms,
          curve: Curves.easeOutBack,
        )
        .then()
        .scale(
          begin: const Offset(1.05, 1.05),
          end: const Offset(1, 1),
          duration: 220.ms,
          curve: Curves.easeOut,
        )
        .shimmer(
          delay: 120.ms,
          duration: 900.ms,
          color: Colors.white.withValues(alpha: 0.55),
        );
  }
}

class _TimerBar extends StatelessWidget {
  final int secondsLeft;
  final int totalSeconds;
  const _TimerBar({required this.secondsLeft, required this.totalSeconds});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ratio = (secondsLeft / totalSeconds).clamp(0.0, 1.0);
    final danger = secondsLeft <= 5;
    final color = danger ? scheme.error : scheme.primary;
    final clamped = secondsLeft < 0 ? 0 : secondsLeft;
    return Row(
      children: [
        Icon(Icons.timer_outlined, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 32,
          child: Text(
            '$clamped',
            textAlign: TextAlign.end,
            style: notoSerifJp(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _MeaningRevealCard extends StatelessWidget {
  final QuizQuestion question;
  const _MeaningRevealCard({required this.question});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final idiom = question.idiom;
    final exampleTranslation = idiom.exampleMeaningFor(question.language);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                idiom.idiom,
                style: notoSerifJp(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: scheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: scheme.onPrimaryContainer.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'DELE ${idiom.level}',
                  style: notoSansJp(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                idiom.reading,
                style: notoSansJp(
                  fontSize: 12,
                  color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            idiom.meaningFor(question.language),
            style: notoSerifJp(
              fontSize: 14,
              height: 1.6,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          _HighlightedExample(
            example: idiom.example,
            target: idiom.answer,
            color: scheme.onPrimaryContainer,
          ),
          if (exampleTranslation.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              exampleTranslation,
              style: notoSansJp(
                fontSize: 12,
                height: 1.5,
                color: scheme.onPrimaryContainer.withValues(alpha: 0.78),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HighlightedExample extends StatelessWidget {
  final String example;
  final String target;
  final Color color;
  const _HighlightedExample({
    required this.example,
    required this.target,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final lower = example.toLowerCase();
    final needle = target.toLowerCase();
    final start = needle.isEmpty ? -1 : lower.indexOf(needle);
    if (start < 0) {
      return Text(
        example,
        style: notoSansJp(fontSize: 13, height: 1.5, color: color),
      );
    }
    final end = start + target.length;
    return RichText(
      text: TextSpan(
        style: notoSansJp(fontSize: 13, height: 1.5, color: color),
        children: [
          TextSpan(text: example.substring(0, start)),
          TextSpan(
            text: example.substring(start, end),
            style: notoSansJp(
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w900,
              color: color,
              decoration: TextDecoration.underline,
            ),
          ),
          TextSpan(text: example.substring(end)),
        ],
      ),
    );
  }
}
