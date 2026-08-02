import 'package:flutter/material.dart';
import '../data/app_text.dart';
import '../data/audio_service.dart';
import '../widgets/pronounce.dart';
import '../data/quiz_session.dart';
import '../data/score_service.dart';
import '../models/idiom.dart';
import '../theme/app_theme.dart';
import 'quiz_screen.dart';

const int _kWrongNoteReviewCount = 20;
const int _kWrongNoteMinReviewCount = 10;

class WrongNoteScreen extends StatelessWidget {
  final List<Idiom> idioms;
  final StudyLanguage language;
  final ScoreSnapshot snap;

  const WrongNoteScreen({
    super.key,
    required this.idioms,
    required this.language,
    required this.snap,
  });

  @override
  Widget build(BuildContext context) {
    final text = AppText(language);
    final scheme = Theme.of(context).colorScheme;
    final wrong = idioms
        .where((idiom) => snap.wrongIdioms.contains(idiom.idiom))
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: Text(text.wrongNote)),
      // AppBar covers the top inset; guard the bottom so the last row is not
      // hidden behind the gesture bar under edge-to-edge.
      body: SafeArea(
        top: false,
        child: wrong.isEmpty
            ? _WrongNoteEmpty(text: text)
            : ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text.wrongNoteCount(wrong.length),
                          style: notoSerifJp(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          text.wrongNoteSubtitle,
                          style: notoSansJp(
                            fontSize: 12,
                            height: 1.45,
                            color: scheme.onPrimaryContainer.withValues(
                              alpha: 0.82,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: wrong.length >= _kWrongNoteMinReviewCount
                                ? () => _startReview(context, wrong)
                                : null,
                            icon: const Icon(Icons.replay_rounded),
                            label: Text(text.startReview),
                          ),
                        ),
                        if (wrong.length < _kWrongNoteMinReviewCount) ...[
                          const SizedBox(height: 8),
                          Text(
                            text.wrongNoteReviewLocked(
                              _kWrongNoteMinReviewCount,
                            ),
                            style: notoSansJp(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: scheme.onPrimaryContainer.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (final idiom in wrong.take(50))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _WrongNoteWord(
                        idiom: idiom,
                        language: language,
                        text: text,
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  void _startReview(BuildContext context, List<Idiom> wrong) {
    if (wrong.length < _kWrongNoteMinReviewCount) return;
    final picked = wrong.take(_kWrongNoteReviewCount).toList(growable: false);
    if (picked.isEmpty) return;
    // Quiz only the wrong idioms, but draw distractor choices from the full
    // list — a short wrong list alone can't fill 4 choices per question.
    final session = QuizSession.build(
      idioms,
      count: picked.length,
      language: language,
      focusIdioms: {for (final idiom in picked) idiom.idiom},
    );
    if (session.questions.isEmpty) return;
    AudioService.instance.playSfx(Sfx.modeStart, multiplier: 2.0);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          session: session,
          initialHints: snap.hints,
          isMarathon: false,
        ),
      ),
    );
  }
}

class _WrongNoteEmpty extends StatelessWidget {
  final AppText text;
  const _WrongNoteEmpty({required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.task_alt_rounded, size: 58, color: scheme.primary),
            const SizedBox(height: 12),
            Text(
              text.noWrongNotes,
              textAlign: TextAlign.center,
              style: notoSerifJp(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              text.noWrongNotesBody,
              textAlign: TextAlign.center,
              style: notoSansJp(
                fontSize: 12,
                height: 1.5,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WrongNoteWord extends StatefulWidget {
  final Idiom idiom;
  final StudyLanguage language;
  final AppText text;

  const _WrongNoteWord({
    required this.idiom,
    required this.language,
    required this.text,
  });

  @override
  State<_WrongNoteWord> createState() => _WrongNoteWordState();
}

class _WrongNoteWordState extends State<_WrongNoteWord> {
  bool _expanded = false;

  void _toggleExpanded() {
    if (widget.idiom.example.trim().isEmpty) return;
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final idiom = widget.idiom;
    final hasExample = idiom.example.trim().isNotEmpty;
    final exampleTranslation = idiom.exampleMeaningFor(widget.language).trim();

    return Material(
      color: scheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        onTap: hasExample ? _toggleExpanded : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(13, 10, 8, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          idiom.idiom,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: notoSerifJp(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          idiom.meaningFor(widget.language),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: notoSansJp(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    idiom.level,
                    style: notoSansJp(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: scheme.primary,
                    ),
                  ),
                  PronounceButton(
                    text: idiom.idiom,
                    appText: widget.text,
                    builder: (context, available, onPressed) => IconButton(
                      key: ValueKey('wrong_note_speak_${idiom.idiom}'),
                      tooltip: available
                          ? widget.text.playPronunciation
                          : widget.text.ttsDownloadVoice,
                      onPressed: onPressed,
                      icon: Icon(
                        available
                            ? Icons.volume_up_rounded
                            : Icons.download_rounded,
                      ),
                      color: scheme.primary,
                    ),
                  ),
                  if (hasExample)
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: !_expanded
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(2, 10, 5, 3),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.text.example,
                                style: notoSansJp(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                idiom.example,
                                style: notoSerifJp(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: scheme.onSurface,
                                ),
                              ),
                              if (exampleTranslation.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  exampleTranslation,
                                  style: notoSansJp(
                                    fontSize: 12,
                                    height: 1.5,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
