import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../data/ad_service.dart';
import '../data/app_text.dart';
import '../data/quiz_session.dart';
import '../data/score_service.dart';
import '../data/stage_plan.dart';
import '../models/idiom.dart';
import '../route_observer.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import 'quiz_screen.dart';

class RoundScreen extends StatefulWidget {
  final StagePlan plan;
  final StudyLanguage language;
  final int stageIndex;
  const RoundScreen({
    super.key,
    required this.plan,
    required this.language,
    required this.stageIndex,
  });

  @override
  State<RoundScreen> createState() => _RoundScreenState();
}

class _RoundScreenState extends State<RoundScreen> with RouteAware {
  ScoreSnapshot? _snap;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) appRouteObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  // The push future in _startRound completes as soon as the preview route is
  // replaced by the quiz, so its _load() runs mid-run with stale data. This
  // fires when the result screen actually pops back to this list.
  @override
  void didPopNext() {
    _load();
  }

  Future<void> _load() async {
    final snap = await ScoreService().snapshot();
    if (!mounted) return;
    setState(() => _snap = snap);
  }

  Future<void> _startRound(int roundIndex) async {
    final idioms = widget.plan.idiomsFor(
      RoundRef(widget.stageIndex, roundIndex),
    );
    final snap = _snap;
    if (snap == null) return;
    if (!mounted) return;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RoundPreviewScreen(
          idioms: idioms,
          language: widget.language,
          initialHints: snap.hints,
          stageIndex: widget.stageIndex,
          roundIndex: roundIndex,
          title: widget.plan
              .roundFor(RoundRef(widget.stageIndex, roundIndex))
              .topic
              .subtitle(widget.language),
        ),
      ),
    );
    if (changed == true) _changed = true;
    await _load();
    // Show an interstitial every few rounds. Safe no-op on web.
    await AdService.instance.maybeShowAfterRound(frequency: 3);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final snap = _snap;
    final rounds = widget.plan.roundsIn(widget.stageIndex);
    final text = AppText(widget.language);
    var currentRound = -1;
    if (snap != null) {
      for (var i = 0; i < rounds; i++) {
        final previousCleared =
            i == 0 || snap.starsForRound(widget.stageIndex, i - 1) >= 1;
        if (previousCleared && snap.starsForRound(widget.stageIndex, i) == 0) {
          currentRound = i;
          break;
        }
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.of(context).pop(_changed);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.plan.topicFor(widget.stageIndex).title(widget.language),
          ),
        ),
        body: snap == null
            ? const Center(child: CircularProgressIndicator())
            : AppContent(
                maxWidth: AppUi.stageMaxWidth,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.plan
                                  .topicFor(widget.stageIndex)
                                  .subtitle(widget.language),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: notoSansJp(
                                fontSize: 13,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.star_rounded,
                            size: 19,
                            color: Color(0xFFF4B740),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${snap.starsInStage(widget.stageIndex)} / ${rounds * 5}',
                            style: notoSerifJp(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: scheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth >= 700
                              ? 4
                              : constraints.maxWidth >= 460
                              ? 3
                              : 2;
                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  mainAxisExtent: 116,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                ),
                            itemCount: rounds,
                            itemBuilder: (context, i) {
                              final stars = snap.starsForRound(
                                widget.stageIndex,
                                i,
                              );
                              final prevStars = i == 0
                                  ? 5
                                  : snap.starsForRound(
                                      widget.stageIndex,
                                      i - 1,
                                    );
                              final unlocked = i == 0 || prevStars >= 1;
                              return _RoundTile(
                                index: i,
                                stars: stars,
                                unlocked: unlocked,
                                isCurrent: i == currentRound,
                                text: text,
                                onTap: unlocked ? () => _startRound(i) : null,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class RoundPreviewScreen extends StatefulWidget {
  final List<Idiom> idioms;
  final StudyLanguage language;
  final Map<HintKind, int> initialHints;
  final int stageIndex;
  final int roundIndex;
  final String title;

  const RoundPreviewScreen({
    super.key,
    required this.idioms,
    required this.language,
    required this.initialHints,
    required this.stageIndex,
    required this.roundIndex,
    required this.title,
  });

  @override
  State<RoundPreviewScreen> createState() => _RoundPreviewScreenState();
}

class _RoundPreviewScreenState extends State<RoundPreviewScreen> {
  static const int _previewSeconds = 60;
  late int _secondsLeft;
  bool _starting = false;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _previewSeconds;
    _ticker = Ticker((elapsed) {
      final next = (_previewSeconds - elapsed.inSeconds).clamp(
        0,
        _previewSeconds,
      );
      if (next == _secondsLeft) return;
      setState(() => _secondsLeft = next);
      if (next == 0) _beginQuiz();
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Future<void> _beginQuiz() async {
    if (_starting) return;
    _starting = true;
    _ticker.stop();
    final session = QuizSession.build(
      widget.idioms,
      count: widget.idioms.length,
      language: widget.language,
    );
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          session: session,
          initialHints: widget.initialHints,
          roundStageIndex: widget.stageIndex,
          roundRoundIndex: widget.roundIndex,
        ),
      ),
      result: true,
    );
  }

  String get _heading => switch (widget.language) {
    StudyLanguage.ko => '출제 단어 미리보기',
    StudyLanguage.en => 'Round Preview',
    StudyLanguage.ja => '出題語プレビュー',
    StudyLanguage.pt => 'Prévia da rodada',
  };

  String get _body => switch (widget.language) {
    StudyLanguage.ko => '1분 동안 이번 라운드의 단어를 확인하세요.',
    StudyLanguage.en =>
      'Review this round for one minute before the quiz starts.',
    StudyLanguage.ja => '1分間、このラウンドの単語を確認できます。',
    StudyLanguage.pt =>
      'Revise as palavras desta rodada por um minuto antes do quiz.',
  };

  String get _autoStart => switch (widget.language) {
    StudyLanguage.ko => '타이머가 끝나면 자동 시작',
    StudyLanguage.en => 'Auto-starts when the timer ends',
    StudyLanguage.ja => 'タイマー終了で自動開始',
    StudyLanguage.pt => 'Começa sozinho quando o tempo acabar',
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = AppText(widget.language);
    final ratio = _secondsLeft / _previewSeconds;

    return Scaffold(
      appBar: AppBar(title: Text(text.roundLabel(widget.roundIndex + 1))),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: ratio,
            minHeight: 5,
            backgroundColor: scheme.surfaceContainerHighest,
          ),
          Expanded(
            child: AppContent(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
                itemCount: widget.idioms.length + 1,
                separatorBuilder: (_, i) => i == 0
                    ? const SizedBox(height: 14)
                    : const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _PreviewHeader(
                      heading: _heading,
                      title: widget.title,
                      body: _body,
                      autoStart: _autoStart,
                      secondsLeft: _secondsLeft,
                    );
                  }
                  final idiom = widget.idioms[index - 1];
                  return _PreviewWordTile(
                    idiom: idiom,
                    language: widget.language,
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: AppContent(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: FilledButton.icon(
                onPressed: _starting ? null : _beginQuiz,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                ),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(text.start),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewHeader extends StatelessWidget {
  final String heading;
  final String title;
  final String body;
  final String autoStart;
  final int secondsLeft;

  const _PreviewHeader({
    required this.heading,
    required this.title,
    required this.body,
    required this.autoStart,
    required this.secondsLeft,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.onPrimaryContainer.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$secondsLeft',
              style: notoSerifJp(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heading,
                  style: notoSerifJp(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: notoSansJp(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.86),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: notoSansJp(
                    fontSize: 12,
                    height: 1.35,
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  autoStart,
                  style: notoSansJp(
                    fontSize: 11,
                    color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewWordTile extends StatelessWidget {
  final Idiom idiom;
  final StudyLanguage language;

  const _PreviewWordTile({required this.idiom, required this.language});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  idiom.idiom,
                  style: notoSerifJp(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              idiom.meaningFor(language),
              textAlign: TextAlign.end,
              style: notoSansJp(
                fontSize: 13,
                height: 1.35,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundTile extends StatelessWidget {
  final int index;
  final int stars;
  final bool unlocked;
  final bool isCurrent;
  final AppText text;
  final VoidCallback? onTap;
  const _RoundTile({
    required this.index,
    required this.stars,
    required this.unlocked,
    required this.isCurrent,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final completed = stars > 0;
    final bg = !unlocked
        ? scheme.surfaceContainerHigh
        : completed
        ? scheme.primaryContainer.withValues(alpha: 0.6)
        : scheme.surface;
    final textColor = !unlocked
        ? scheme.onSurfaceVariant
        : completed
        ? scheme.onPrimaryContainer
        : scheme.onSurface;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppUi.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppUi.cardRadius),
            border: Border.all(
              color: isCurrent
                  ? scheme.primary
                  : completed
                  ? scheme.tertiary
                  : scheme.outlineVariant,
              width: isCurrent ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text.roundLabel(index + 1),
                style: notoSerifJp(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              AppStarRating(
                value: stars,
                emptyColor: scheme.onSurfaceVariant.withValues(alpha: 0.3),
              ),
              if (isCurrent) ...[
                const SizedBox(height: 4),
                Icon(
                  Icons.play_circle_fill_rounded,
                  size: 16,
                  color: scheme.primary,
                ),
              ],
              if (!unlocked) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      size: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      text.clearPreviousRound,
                      style: notoSansJp(
                        fontSize: 10,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
