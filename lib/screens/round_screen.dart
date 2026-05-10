import 'package:flutter/material.dart';
import '../data/ad_service.dart';
import '../data/app_text.dart';
import '../data/audio_service.dart';
import '../data/quiz_session.dart';
import '../data/score_service.dart';
import '../data/stage_plan.dart';
import '../models/idiom.dart';
import '../theme/app_theme.dart';
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

class _RoundScreenState extends State<RoundScreen> {
  ScoreSnapshot? _snap;

  @override
  void initState() {
    super.initState();
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
    final session = QuizSession.build(
      idioms,
      count: idioms.length,
      language: widget.language,
    );
    final snap = _snap;
    if (snap == null) return;
    await AudioService.instance.playBgm(Bgm.quiz);
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          session: session,
          initialHints: snap.hints,
          roundStageIndex: widget.stageIndex,
          roundRoundIndex: roundIndex,
        ),
      ),
    );
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

    return Scaffold(
      appBar: AppBar(title: Text(kStageTitles[widget.stageIndex])),
      body: snap == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    kStageSubtitles[widget.stageIndex],
                    style: notoSansJp(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${text.totalStars} ${snap.starsInStage(widget.stageIndex)} / ${rounds * 5}',
                    style: notoSerifJp(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 120,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                          ),
                      itemCount: rounds,
                      itemBuilder: (context, i) {
                        final stars = snap.starsForRound(widget.stageIndex, i);
                        final prevStars = i == 0
                            ? 5
                            : snap.starsForRound(widget.stageIndex, i - 1);
                        final unlocked = i == 0 || prevStars >= 1;
                        return _RoundTile(
                          index: i,
                          stars: stars,
                          unlocked: unlocked,
                          text: text,
                          onTap: unlocked ? () => _startRound(i) : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _RoundTile extends StatelessWidget {
  final int index;
  final int stars;
  final bool unlocked;
  final AppText text;
  final VoidCallback? onTap;
  const _RoundTile({
    required this.index,
    required this.stars,
    required this.unlocked,
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
        ? scheme.primaryContainer
        : scheme.surface;
    final textColor = !unlocked
        ? scheme.onSurfaceVariant
        : completed
        ? scheme.onPrimaryContainer
        : scheme.onSurface;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: completed ? scheme.primary : scheme.outlineVariant,
              width: completed ? 1.5 : 1,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int s = 0; s < 5; s++)
                    Icon(
                      s < stars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 18,
                      color: unlocked
                          ? (s < stars
                                ? Colors.amber
                                : scheme.onSurfaceVariant.withValues(
                                    alpha: 0.35,
                                  ))
                          : scheme.onSurfaceVariant.withValues(alpha: 0.3),
                    ),
                ],
              ),
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
