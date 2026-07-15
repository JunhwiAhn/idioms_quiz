import 'dart:async';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/ad_service.dart';
import '../data/app_text.dart';
import '../data/audio_service.dart';
import '../data/pronunciation_service.dart';
import '../data/quiz_session.dart';
import '../data/score_service.dart';
import '../data/stage_plan.dart' show starsForRound;
import '../models/idiom.dart';
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

  bool get isStageRound => roundStageIndex != null && roundRoundIndex != null;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _scoreService = ScoreService();
  late Map<HintKind, int> _hints;

  int? _picked;
  bool _revealed = false;
  HintKind? _lastDrop;
  bool _allowExit = false;
  bool _isConfirmingExit = false;

  // Per-question hint state
  Set<int> _eliminated = {};

  // Per-question countdown. A ValueNotifier keeps the per-second tick from
  // rebuilding the whole screen — only _TimerBar listens to it.
  Timer? _ticker;
  Timer? _autoPronunciationTimer;
  final ValueNotifier<int> _secondsLeft = ValueNotifier(kQuestionSeconds);

  @override
  void initState() {
    super.initState();
    _hints = {...widget.initialHints};
    _syncHints();
    _startTimer();
    _autoPlayWordForMeaningQuestion();
    AdService.instance.preloadInterstitial();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _autoPronunciationTimer?.cancel();
    _secondsLeft.dispose();
    super.dispose();
  }

  void _startTimer() {
    _ticker?.cancel();
    _secondsLeft.value = kQuestionSeconds;
    _resumeTimer();
  }

  void _resumeTimer() {
    _ticker?.cancel();
    if (_revealed || _secondsLeft.value <= 0) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      _secondsLeft.value--;
      if (_secondsLeft.value <= 0) {
        t.cancel();
        _timeOut();
      }
    });
  }

  Future<void> _confirmExit() async {
    if (_isConfirmingExit || _allowExit) return;
    _isConfirmingExit = true;
    _ticker?.cancel();
    final text = AppText(_q.language);
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(text.exitQuizTitle),
        content: Text(text.exitQuizBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(text.keepPlaying),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(text.exitQuiz),
          ),
        ],
      ),
    );
    _isConfirmingExit = false;
    if (!mounted) return;
    if (shouldExit == true) {
      setState(() => _allowExit = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    } else {
      _resumeTimer();
    }
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

  Future<void> _speak(String text) {
    _autoPronunciationTimer?.cancel();
    return PronunciationService.instance.speakSpanish(text);
  }

  void _autoPlayWordForMeaningQuestion() {
    _autoPronunciationTimer?.cancel();
    final question = _q;
    if (question.mode != QuizMode.translationLookup) return;
    final questionIndex = _index;

    _autoPronunciationTimer = Timer(const Duration(milliseconds: 450), () {
      if (!mounted || widget.session.isFinished || _index != questionIndex) {
        return;
      }
      _speak(question.idiom.idiom);
    });
  }

  // The stored hint counts are the source of truth for consumeHint; a stale
  // snapshot passed as initialHints would make the buttons lie.
  Future<void> _syncHints() async {
    final snap = await _scoreService.snapshot();
    if (!mounted) return;
    setState(() => _hints = {...snap.hints});
  }

  void _pick(int i) {
    if (_revealed || _eliminated.contains(i)) return;
    _ticker?.cancel();
    final result = widget.session.submit(i);
    if (result.droppedHint != null) {
      // Persist right away so the drop is spendable within this run.
      _scoreService.grantHint(result.droppedHint!);
    }
    if (result.correct) {
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
    final isLastQuestion = widget.session.currentIndex == _total - 1;
    if (!isLastQuestion) {
      await AdService.instance.maybeShowAfterRound(frequency: 4);
      if (!mounted) return;
    }
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
        incorrectIdioms: widget.session.incorrectIdioms,
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
        result: true,
      );
    } else {
      setState(() {
        _picked = null;
        _revealed = false;
        _lastDrop = null;
        _eliminated = {};
      });
      _startTimer();
      _autoPlayWordForMeaningQuestion();
    }
  }

  bool _hintUsable(HintKind kind) {
    if ((_hints[kind] ?? 0) <= 0) return false;
    if (_revealed) return false;
    switch (kind) {
      case HintKind.fiftyFifty:
        return _eliminated.length < 2;
      case HintKind.reading:
        return false;
      case HintKind.time:
        return _secondsLeft.value < kQuestionSeconds;
    }
  }

  // A dead tap on the hint bar reads as a bug — always explain why the hint
  // could not be used.
  void _explainUnusableHint(HintKind kind) {
    final text = AppText(_q.language);
    final String message;
    if ((_hints[kind] ?? 0) <= 0) {
      message = text.hintNoneLeft;
    } else if (_revealed) {
      message = text.hintAfterReveal;
    } else if (kind == HintKind.time) {
      message = text.hintTimerFull;
    } else {
      message = text.hintAlreadyUsed;
    }
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _useHint(HintKind kind) async {
    if (!_hintUsable(kind)) {
      _explainUnusableHint(kind);
      return;
    }
    final ok = await _scoreService.consumeHint(kind);
    if (!ok) {
      await _syncHints();
      if (mounted) _explainUnusableHint(kind);
      return;
    }
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
          break;
        case HintKind.time:
          _secondsLeft.value = (_secondsLeft.value + kTimeHintBonus).clamp(
            0,
            kQuestionSeconds,
          );
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

    return PopScope(
      canPop: _allowExit,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(text.questionCounter(_index + 1, _total)),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: _confirmExit,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    text.quizModeLabel(_q.mode.name),
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
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
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
                                QuizMode.translationLookup =>
                                  text.wordToMeaning,
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
                              fullReveal: _revealed,
                              onSpeak: _speak,
                            ),
                            const SizedBox(height: 18),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 260),
                              switchInCurve: Curves.easeOutBack,
                              switchOutCurve: Curves.easeIn,
                              child: _revealed
                                  ? _AnswerFeedbackBanner(
                                      key: ValueKey('feedback_$_index'),
                                      isCorrect: _picked == _q.correctIndex,
                                      language: _q.language,
                                    )
                                  : _HintBar(
                                      key: const ValueKey('hints'),
                                      hints: _hints,
                                      usable: {
                                        for (final k in HintKind.values)
                                          k: _hintUsable(k),
                                      },
                                      onUse: _useHint,
                                    ),
                            ),
                            const SizedBox(height: 14),
                            for (int i = 0; i < _q.choices.length; i++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _ChoiceTile(
                                  index: i,
                                  text: _q.choices[i],
                                  subText: null,
                                  picked: _picked,
                                  correct: _q.correctIndex,
                                  revealed: _revealed,
                                  eliminated: _eliminated.contains(i),
                                  comboStreak: widget.session.currentStreak,
                                  language: _q.language,
                                  speakTooltip: text.playPronunciation,
                                  onSpeak: _q.mode == QuizMode.wordLookup
                                      ? () => _speak(_q.choices[i])
                                      : null,
                                  onTap: () => _pick(i),
                                ),
                              ),
                            if (_revealed) ...[
                              const SizedBox(height: 6),
                              _MeaningRevealCard(
                                question: _q,
                                onSpeak: _speak,
                              ).animate().fadeIn(duration: 300.ms),
                            ],
                            if (_lastDrop != null) ...[
                              const SizedBox(height: 10),
                              _DropBanner(
                                    kind: _lastDrop!,
                                    language: _q.language,
                                  )
                                  .animate(key: ValueKey(_index))
                                  .fadeIn(duration: 250.ms)
                                  .slideY(
                                    begin: -0.2,
                                    end: 0,
                                    duration: 300.ms,
                                  ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: _revealed
                      ? SafeArea(
                          minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 720),
                              child: FilledButton(
                                onPressed: _next,
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(56),
                                  backgroundColor: _picked == _q.correctIndex
                                      ? AppTheme.correctFg
                                      : scheme.error,
                                  shadowColor:
                                      (_picked == _q.correctIndex
                                              ? AppTheme.correctBorder
                                              : scheme.error)
                                          .withValues(alpha: 0.45),
                                  elevation: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.session.currentIndex == _total - 1
                                          ? text.seeResult
                                          : text.nextQuestion,
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      widget.session.currentIndex == _total - 1
                                          ? Icons.emoji_events_rounded
                                          : Icons.arrow_forward_rounded,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerFeedbackBanner extends StatelessWidget {
  final bool isCorrect;
  final StudyLanguage language;

  const _AnswerFeedbackBanner({
    super.key,
    required this.isCorrect,
    required this.language,
  });

  String get _message {
    if (isCorrect) {
      return switch (language) {
        StudyLanguage.ko => '멋져요! 정답 감각이 살아있어요.  +10점',
        StudyLanguage.en => 'Brilliant! Your instincts are on point.  +10 pts',
        StudyLanguage.ja => 'すごい！見事に正解です。  +10点',
      };
    }
    return switch (language) {
      StudyLanguage.ko => '괜찮아요! 정답을 눈에 익히고 다음 문제에서 되찾아요.',
      StudyLanguage.en =>
        'So close! Lock in the answer and bounce back next round.',
      StudyLanguage.ja => '惜しい！正解を覚えて、次の問題で取り返そう。',
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final strong = isCorrect ? AppTheme.correctFg : scheme.error;
    final soft = isCorrect
        ? AppTheme.correctBg
        : scheme.errorContainer.withValues(alpha: 0.82);
    final title = isCorrect
        ? AppText(language).correct
        : AppText(language).incorrect;

    return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [soft, Color.lerp(soft, Colors.white, 0.42)!],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: strong, width: 2),
            boxShadow: [
              BoxShadow(
                color: strong.withValues(alpha: 0.24),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: strong,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: strong.withValues(alpha: 0.32),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  isCorrect ? Icons.bolt_rounded : Icons.close_rounded,
                  color: Colors.white,
                  size: 31,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: notoSerifJp(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: strong,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _message,
                      style: notoSansJp(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                        color: strong,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 160.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 360.ms,
          curve: Curves.easeOutBack,
        );
  }
}

class _PromptDisplay extends StatelessWidget {
  final QuizQuestion question;
  final bool fullReveal;
  final Future<void> Function(String text) onSpeak;

  const _PromptDisplay({
    required this.question,
    required this.fullReveal,
    required this.onSpeak,
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
      final showAnswer = fullReveal;
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
              idiom.hasUsableExample
                  ? idiom.blankedExample
                  : idiom.meaningFor(question.language),
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
              opacity: showAnswer ? 1 : 0,
              child: SizedBox(
                height: 20,
                child: Text(
                  showAnswer ? idiom.answer : ' ',
                  style: notoSansJp(
                    fontSize: 13,
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                idiom.idiom,
                textAlign: TextAlign.center,
                style: AppTheme.idiomDisplay(context),
              ),
            ),
            const SizedBox(width: 8),
            _SpeakButton(
              tooltip: AppText(question.language).playPronunciation,
              onPressed: () => onSpeak(idiom.idiom),
            ),
          ],
        ).animate(key: ValueKey(idiom.idiom)).fadeIn(duration: 350.ms),
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
  final StudyLanguage language;
  const _DropBanner({required this.kind, required this.language});

  String get _label => switch (kind) {
    HintKind.fiftyFifty => '50:50',
    HintKind.reading => '50:50',
    HintKind.time => 'Time+',
  };

  IconData get _icon => switch (kind) {
    HintKind.fiftyFifty => Icons.filter_alt_rounded,
    HintKind.reading => Icons.filter_alt_rounded,
    HintKind.time => Icons.more_time_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = AppText(language);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.card_giftcard_rounded,
            color: scheme.onTertiaryContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text.itemGained,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: notoSerifJp(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: scheme.onTertiaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 8),
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
    super.key,
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
      color: active ? scheme.secondaryContainer : scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: active ? scheme.secondary : scheme.outlineVariant,
        ),
      ),
      child: InkWell(
        // Stay tappable while inactive so _useHint can explain why the hint
        // is unavailable instead of silently ignoring the tap.
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: active
                      ? scheme.onSecondaryContainer
                      : scheme.onSurfaceVariant.withValues(alpha: 0.55),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: notoSansJp(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: active
                        ? scheme.onSecondaryContainer
                        : scheme.onSurfaceVariant.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (active
                                ? scheme.onSecondaryContainer
                                : scheme.onSurfaceVariant)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '×$count',
                    style: notoSerifJp(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: active
                          ? scheme.onSecondaryContainer
                          : scheme.onSurfaceVariant.withValues(alpha: 0.65),
                    ),
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

class _ChoiceTile extends StatelessWidget {
  final int index;
  final String text;
  final String? subText;
  final int? picked;
  final int correct;
  final bool revealed;
  final bool eliminated;
  final int comboStreak;
  final StudyLanguage language;
  final String speakTooltip;
  final VoidCallback? onSpeak;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.index,
    required this.text,
    required this.subText,
    required this.picked,
    required this.correct,
    required this.revealed,
    required this.eliminated,
    required this.comboStreak,
    required this.language,
    required this.speakTooltip,
    required this.onSpeak,
    required this.onTap,
  });

  String get _comboLabel {
    if (comboStreak >= 10) return 'Perfecto';
    if (comboStreak >= 5) return 'Excelente';
    return AppText(language).combo;
  }

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
    final isWrongReveal = revealed && index == picked && index != correct;
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
      } else {
        opacity = 0.52;
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
                        if (isCorrectReveal && comboStreak >= 3) ...[
                          const SizedBox(height: 7),
                          Align(
                            alignment: Alignment.centerLeft,
                            child:
                                Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFFF7A18),
                                            Color(0xFFFFB000),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFFFF8A00,
                                            ).withValues(alpha: 0.32),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.local_fire_department_rounded,
                                            size: 17,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$_comboLabel  ×$comboStreak',
                                            style: notoSansJp(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    .animate(
                                      key: ValueKey(
                                        'answer_combo_${index}_$comboStreak',
                                      ),
                                    )
                                    .fadeIn(duration: 120.ms)
                                    .scale(
                                      begin: const Offset(0.72, 0.72),
                                      end: const Offset(1, 1),
                                      duration: 340.ms,
                                      curve: Curves.elasticOut,
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
                  if (onSpeak != null) ...[
                    const SizedBox(width: 8),
                    _SpeakButton(
                      tooltip: speakTooltip,
                      onPressed: onSpeak!,
                      compact: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (isWrongReveal) {
      return tile.animate().shakeX(
        amount: 6,
        duration: 420.ms,
        curve: Curves.easeInOut,
      );
    }
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
  final ValueListenable<int> secondsLeft;
  final int totalSeconds;
  const _TimerBar({required this.secondsLeft, required this.totalSeconds});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<int>(
      valueListenable: secondsLeft,
      builder: (context, value, _) {
        final ratio = (value / totalSeconds).clamp(0.0, 1.0);
        final danger = value <= 5;
        final color = danger ? scheme.error : scheme.primary;
        final clamped = value < 0 ? 0 : value;
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
      },
    );
  }
}

class _MeaningRevealCard extends StatelessWidget {
  final QuizQuestion question;
  final Future<void> Function(String text) onSpeak;
  const _MeaningRevealCard({required this.question, required this.onSpeak});

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
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      idiom.idiom,
                      style: notoSerifJp(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              _SpeakButton(
                tooltip: AppText(question.language).playPronunciation,
                onPressed: () => onSpeak(idiom.idiom),
                compact: true,
              ),
              const SizedBox(width: 8),
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
          if (idiom.hasUsableExample)
            _HighlightedExample(
              example: idiom.example,
              target: idiom.answer,
              color: scheme.onPrimaryContainer,
            ),
          if (idiom.hasUsableExample && exampleTranslation.isNotEmpty) ...[
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

class _SpeakButton extends StatelessWidget {
  final String tooltip;
  final VoidCallback onPressed;
  final bool compact;

  const _SpeakButton({
    required this.tooltip,
    required this.onPressed,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(Icons.volume_up_rounded, size: compact ? 18 : 20),
      style: IconButton.styleFrom(
        minimumSize: Size.square(compact ? 34 : 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: scheme.secondaryContainer,
        foregroundColor: scheme.onSecondaryContainer,
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
