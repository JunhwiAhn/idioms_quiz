import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/audio_service.dart';
import '../data/quiz_session.dart';
import '../data/score_service.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';

const int kQuestionSeconds = 20;

class QuizScreen extends StatefulWidget {
  final QuizSession session;
  final Map<HintKind, int> initialHints;
  const QuizScreen({
    super.key,
    required this.session,
    required this.initialHints,
  });

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
  bool _kanjiRevealed = false;
  int? _kanjiRevealIndex;
  Set<int> _eliminated = {};

  // Per-question countdown
  Timer? _ticker;
  int _secondsLeft = kQuestionSeconds;

  @override
  void initState() {
    super.initState();
    _hints = {...widget.initialHints};
    _confetti = ConfettiController(duration: const Duration(milliseconds: 600));
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
      final outcome = await _scoreService.commitRun(
        correct: widget.session.correctCount,
        total: widget.session.questions.length,
        longestStreak: widget.session.longestStreak,
        correctIdioms: widget.session.correctIdioms,
        droppedHints: widget.session.droppedHints,
      );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            correct: widget.session.correctCount,
            total: widget.session.questions.length,
            longestStreak: widget.session.longestStreak,
            outcome: outcome,
          ),
        ),
      );
    } else {
      setState(() {
        _picked = null;
        _revealed = false;
        _lastDrop = null;
        _readingRevealed = false;
        _kanjiRevealed = false;
        _kanjiRevealIndex = null;
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
        return _q.mode == QuizMode.noReading ||
            _q.mode == QuizMode.reverseLookup;
      case HintKind.kanji:
        if (_kanjiRevealed) return false;
        return _q.mode == QuizMode.fillBlank && _q.maskedIndices.isNotEmpty;
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
        case HintKind.kanji:
          _kanjiRevealed = true;
          // Reveal first masked index by default.
          _kanjiRevealIndex =
              _q.maskedIndices.isEmpty ? null : _q.maskedIndices.first;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final progress = _index / _total;

    return Scaffold(
      appBar: AppBar(
        title: Text('問題 ${_index + 1} / $_total'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            AudioService.instance.playBgm(Bgm.home);
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
                      QuizMode.reverseLookup =>
                        'つぎの意味に当てはまる四字熟語は?',
                      QuizMode.fillBlank => '空白に入る漢字は?',
                      _ => 'つぎの四字熟語の意味は?',
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
                    kanjiRevealIndex: _kanjiRevealIndex,
                    fullReveal: _revealed,
                  ),
                  if (_revealed &&
                      (_q.mode == QuizMode.fillBlank ||
                          _q.mode == QuizMode.reverseLookup ||
                          _q.mode == QuizMode.noReading)) ...[
                    const SizedBox(height: 14),
                    _MeaningRevealCard(idiom: _q.idiom)
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
                  if (_q.mode == QuizMode.fillBlank)
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.35,
                      children: [
                        for (int i = 0; i < _q.choices.length; i++)
                          _KanjiChoiceTile(
                            index: i,
                            char: _q.choices[i],
                            picked: _picked,
                            correct: _q.correctIndex,
                            revealed: _revealed,
                            eliminated: _eliminated.contains(i),
                            onTap: () => _pick(i),
                          ),
                      ],
                    )
                  else
                    for (int i = 0; i < _q.choices.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ChoiceTile(
                          index: i,
                          text: _q.choices[i],
                          subText: _q.mode == QuizMode.reverseLookup
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
                      ? '結果を見る'
                      : '次の問題へ',
                ),
              ),
            ),
          ),
        ],
      ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: pi / 2,
              maxBlastForce: 20,
              minBlastForce: 8,
              emissionFrequency: 0.06,
              numberOfParticles: 18,
              gravity: 0.3,
              shouldLoop: false,
              colors: [
                scheme.primary,
                scheme.tertiary,
                scheme.secondary,
                scheme.primaryContainer,
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
  final int? kanjiRevealIndex;
  final bool fullReveal;

  const _PromptDisplay({
    required this.question,
    required this.readingRevealed,
    required this.kanjiRevealIndex,
    required this.fullReveal,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final idiom = question.idiom;

    if (question.mode == QuizMode.reverseLookup) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Text(
          idiom.meaning,
          textAlign: TextAlign.center,
          style: notoSerifJp(
            fontSize: 17,
            height: 1.6,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
      );
    }

    final chars = idiom.idiom.split('');
    final showReading = fullReveal
        ? true
        : (question.mode == QuizMode.noReading ? readingRevealed : true);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < chars.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              _IdiomChar(
                ch: chars[i],
                masked: question.mode == QuizMode.fillBlank &&
                    question.maskedIndices.contains(i) &&
                    kanjiRevealIndex != i &&
                    !fullReveal,
                highlight: fullReveal &&
                    question.mode == QuizMode.fillBlank &&
                    question.maskedIndices.contains(i),
              ),
            ],
          ],
        ).animate(key: ValueKey(idiom.idiom)).fadeIn(duration: 350.ms),
        const SizedBox(height: 12),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: showReading ? 1 : 0,
          child: Text(
            showReading ? idiom.reading : '・・・・・',
            style: notoSansJp(
              fontSize: 14,
              color: scheme.onSurfaceVariant,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }
}

class _IdiomChar extends StatelessWidget {
  final String ch;
  final bool masked;
  final bool highlight;
  const _IdiomChar({
    required this.ch,
    required this.masked,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (masked) {
      return Container(
        width: 52,
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: scheme.outlineVariant,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Text(
          '?',
          style: notoSerifJp(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: scheme.onSurfaceVariant,
          ),
        ),
      );
    }
    if (highlight) {
      return Container(
        width: 52,
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          ch,
          style: AppTheme.idiomDisplay(context).copyWith(
            letterSpacing: 0,
            color: scheme.onPrimaryContainer,
          ),
        ),
      );
    }
    return Text(
      ch,
      style: AppTheme.idiomDisplay(context).copyWith(letterSpacing: 0),
    );
  }
}

class _DropBanner extends StatelessWidget {
  final HintKind kind;
  const _DropBanner({required this.kind});

  String get _label => switch (kind) {
        HintKind.fiftyFifty => '50:50',
        HintKind.reading => 'ふりがな',
        HintKind.kanji => '漢字一字',
      };

  IconData get _icon => switch (kind) {
        HintKind.fiftyFifty => Icons.filter_alt_rounded,
        HintKind.reading => Icons.record_voice_over_rounded,
        HintKind.kanji => Icons.visibility_rounded,
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
            'ヒント獲得!',
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
            label: '読み',
            count: hints[HintKind.reading] ?? 0,
            enabled: usable[HintKind.reading] ?? false,
            onTap: () => onUse(HintKind.reading),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _HintButton(
            icon: Icons.visibility_rounded,
            label: '漢字',
            count: hints[HintKind.kanji] ?? 0,
            enabled: usable[HintKind.kanji] ?? false,
            onTap: () => onUse(HintKind.kanji),
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
    IconData? trailing;
    Color? trailingColor;
    double opacity = 1;

    if (eliminated) {
      opacity = 0.35;
    }

    if (revealed) {
      if (index == correct) {
        bg = scheme.primaryContainer;
        border = scheme.primary;
        trailing = Icons.check_circle_rounded;
        trailingColor = scheme.primary;
      } else if (index == picked) {
        bg = scheme.errorContainer;
        border = scheme.error;
        trailing = Icons.cancel_rounded;
        trailingColor = scheme.error;
      }
    } else if (picked == index) {
      border = scheme.primary;
    }

    final letter = String.fromCharCode('A'.codeUnitAt(0) + index);

    return Opacity(
      opacity: opacity,
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
              border: Border.all(color: border, width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    letter,
                    style: notoSerifJp(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
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
                          letterSpacing: subText != null ? 4 : 0,
                          color: scheme.onSurface,
                        ),
                      ),
                      if (subText != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subText!,
                          style: notoSansJp(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
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
    );
  }
}

class _KanjiChoiceTile extends StatelessWidget {
  final int index;
  final String char;
  final int? picked;
  final int correct;
  final bool revealed;
  final bool eliminated;
  final VoidCallback onTap;

  const _KanjiChoiceTile({
    required this.index,
    required this.char,
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
    double opacity = eliminated ? 0.35 : 1;

    if (revealed) {
      if (index == correct) {
        bg = scheme.primaryContainer;
        border = scheme.primary;
        textColor = scheme.onPrimaryContainer;
      } else if (index == picked) {
        bg = scheme.errorContainer;
        border = scheme.error;
        textColor = scheme.onErrorContainer;
      }
    } else if (picked == index) {
      border = scheme.primary;
    }

    return Opacity(
      opacity: opacity,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: revealed || eliminated ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 1.8),
            ),
            child: Text(
              char,
              style: notoSerifJp(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
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
  final dynamic idiom; // Idiom — use dynamic to avoid extra import noise
  const _MeaningRevealCard({required this.idiom});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
                  letterSpacing: 3,
                  color: scheme.onPrimaryContainer,
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
            idiom.meaning,
            style: notoSerifJp(
              fontSize: 14,
              height: 1.6,
              color: scheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
