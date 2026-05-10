import 'package:flutter/material.dart';
import '../data/app_text.dart';
import '../data/crossword.dart';
import '../models/idiom.dart';
import '../theme/app_theme.dart';
import 'crossword_screen.dart';

class CrosswordStageScreen extends StatelessWidget {
  final CrosswordBank bank;
  final StudyLanguage language;

  const CrosswordStageScreen({
    super.key,
    required this.bank,
    required this.language,
  });

  Future<void> _openStartModal(BuildContext context, int index) async {
    final spec = bank.stageSpec(index);
    final text = AppText(language);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        final scheme = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.grid_on_rounded,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            spec.title,
                            style: notoSerifJp(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            text.crosswordStage,
                            style: notoSansJp(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _StageInfoBox(
                        label: text.level,
                        value: spec.levelLabel,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StageInfoBox(
                        label: text.words,
                        value: '$kCrosswordWordsPerStage',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StageInfoBox(
                        label: text.puzzles,
                        value: '$kCrosswordPuzzlesPerStage',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  text.crosswordStageDescription(kCrosswordWordsPerStage),
                  style: notoSansJp(
                    fontSize: 12,
                    height: 1.45,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    final puzzles = bank.sampleStagePuzzles(index);
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CrosswordScreen(
                          bank: bank,
                          language: language,
                          puzzles: puzzles,
                          stage: spec,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(text.start),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = AppText(language);
    return Scaffold(
      appBar: AppBar(title: Text(text.crosswordStages)),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        itemCount: kCrosswordStageCount,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final spec = bank.stageSpec(index);
          final t = index / (kCrosswordStageCount - 1);
          return _CrosswordStageCard(
            spec: spec,
            text: text,
            color: Color.lerp(scheme.primary, scheme.tertiary, t)!,
            onTap: () => _openStartModal(context, index),
          );
        },
      ),
    );
  }
}

class _CrosswordStageCard extends StatelessWidget {
  final CrosswordStageSpec spec;
  final AppText text;
  final Color color;
  final VoidCallback onTap;

  const _CrosswordStageCard({
    required this.spec,
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color, Color.lerp(color, Colors.black, 0.18)!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text(
                    '${spec.index + 1}',
                    style: notoSerifJp(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: scheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spec.title,
                        style: notoSerifJp(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: scheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        text.crosswordStageSummary(
                          spec.levelLabel,
                          kCrosswordWordsPerStage,
                          kCrosswordPuzzlesPerStage,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: notoSansJp(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: scheme.onPrimary.withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.onPrimary.withValues(alpha: 0.78),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StageInfoBox extends StatelessWidget {
  final String label;
  final String value;

  const _StageInfoBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: notoSansJp(fontSize: 10, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: notoSerifJp(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
