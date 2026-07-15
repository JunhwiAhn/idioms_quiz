import 'package:flutter/material.dart';
import '../data/ad_service.dart';
import '../data/app_text.dart';
import '../data/quiz_session.dart';
import '../data/score_service.dart';
import '../data/stage_plan.dart';
import '../models/idiom.dart';
import '../theme/app_theme.dart';
import '../widgets/app_ui.dart';
import 'quiz_screen.dart';
import 'round_screen.dart';

const int _stagesPerGroup = 10;

class StageScreen extends StatefulWidget {
  final StagePlan plan;
  final StudyLanguage language;
  const StageScreen({super.key, required this.plan, required this.language});

  @override
  State<StageScreen> createState() => _StageScreenState();
}

class _StageScreenState extends State<StageScreen> {
  ScoreSnapshot? _snap;
  bool _changed = false;
  int _groupIndex = 0;
  bool _groupPickerExpanded = false;
  bool _userSelectedGroup = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final snap = await ScoreService().snapshot();
    if (!mounted) return;
    setState(() {
      _snap = snap;
      if (!_userSelectedGroup) {
        _groupIndex = _currentGroupFor(snap);
      }
    });
  }

  int _maxStarsFor(int stage) => widget.plan.roundsIn(stage) * 5;

  int _questionCountFor(int stage) {
    var count = 0;
    for (var round = 0; round < widget.plan.roundsIn(stage); round++) {
      count += widget.plan.idiomsFor(RoundRef(stage, round)).length;
    }
    return count;
  }

  bool _isUnlocked(ScoreSnapshot snap, int stageIndex) {
    final max = _maxStarsFor(stageIndex);
    final previousStars = stageIndex == 0
        ? max
        : snap.starsInStage(stageIndex - 1);
    final previousMax = stageIndex == 0 ? 1 : _maxStarsFor(stageIndex - 1);
    return stageIndex == 0 || (previousStars / previousMax) >= 0.5;
  }

  int _currentGroupFor(ScoreSnapshot snap) {
    for (var i = 0; i < widget.plan.stageCount; i++) {
      if (snap.starsInStage(i) == 0 && _isUnlocked(snap, i)) {
        return i ~/ _stagesPerGroup;
      }
    }
    if (widget.plan.stageCount == 0) return 0;
    return (widget.plan.stageCount - 1) ~/ _stagesPerGroup;
  }

  int _currentStageFor(ScoreSnapshot snap) {
    for (var i = 0; i < widget.plan.stageCount; i++) {
      if (snap.starsInStage(i) == 0 && _isUnlocked(snap, i)) return i;
    }
    return widget.plan.stageCount == 0 ? 0 : widget.plan.stageCount - 1;
  }

  Future<void> _openStage(int stage) async {
    if (widget.plan.roundsIn(stage) == 1) {
      await _startSingleRound(stage);
      return;
    }
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => RoundScreen(
          plan: widget.plan,
          language: widget.language,
          stageIndex: stage,
        ),
      ),
    );
    if (changed == true) _changed = true;
    await _load();
  }

  Future<void> _startSingleRound(int stage) async {
    final snap = _snap;
    if (snap == null) return;
    final idioms = widget.plan.idiomsFor(RoundRef(stage, 0));
    final session = QuizSession.build(
      idioms,
      count: idioms.length,
      language: widget.language,
    );
    if (!mounted) return;
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          session: session,
          initialHints: snap.hints,
          roundStageIndex: stage,
          roundRoundIndex: 0,
        ),
      ),
    );
    if (changed == true) _changed = true;
    await _load();
    await AdService.instance.maybeShowAfterRound(frequency: 3);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final snap = _snap;
    final text = AppText(widget.language);
    final groupCount = (widget.plan.stageCount / _stagesPerGroup).ceil();
    final groupIndex = groupCount == 0
        ? 0
        : _groupIndex.clamp(0, groupCount - 1);
    final start = groupIndex * _stagesPerGroup;
    final end = (start + _stagesPerGroup).clamp(0, widget.plan.stageCount);
    final currentStage = snap == null ? 0 : _currentStageFor(snap);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.of(context).pop(_changed);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(text.stageMode)),
        body: snap == null
            ? const Center(child: CircularProgressIndicator())
            : AppContent(
                maxWidth: AppUi.stageMaxWidth,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  itemCount: (end - start) + (_groupPickerExpanded ? 3 : 2),
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return _StageRewardSummary(
                        totalStars: snap.totalStars,
                        scheme: scheme,
                        text: text,
                      );
                    }
                    if (i == 1) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 10),
                        child: _StageGroupHeader(
                          groupIndex: groupIndex,
                          groupCount: groupCount,
                          start: start,
                          end: end,
                          total: widget.plan.stageCount,
                          expanded: _groupPickerExpanded,
                          text: text,
                          onTap: () {
                            setState(
                              () =>
                                  _groupPickerExpanded = !_groupPickerExpanded,
                            );
                          },
                        ),
                      );
                    }
                    if (_groupPickerExpanded && i == 2) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _StageGroupPicker(
                          groupIndex: groupIndex,
                          groupCount: groupCount,
                          total: widget.plan.stageCount,
                          onSelected: (value) {
                            setState(() {
                              _groupIndex = value;
                              _userSelectedGroup = true;
                              _groupPickerExpanded = false;
                            });
                          },
                        ),
                      );
                    }
                    final stageIndex =
                        start + i - (_groupPickerExpanded ? 3 : 2);
                    final earned = snap.starsInStage(stageIndex);
                    final max = _maxStarsFor(stageIndex);
                    final unlocked = _isUnlocked(snap, stageIndex);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _StageCard(
                        index: stageIndex,
                        title: widget.plan
                            .topicFor(stageIndex)
                            .title(widget.language),
                        subtitle: widget.plan
                            .topicFor(stageIndex)
                            .subtitle(widget.language),
                        earnedStars: earned,
                        maxStars: max,
                        rounds: widget.plan.roundsIn(stageIndex),
                        questionCount: _questionCountFor(stageIndex),
                        isCurrent: stageIndex == currentStage,
                        unlocked: unlocked,
                        onTap: unlocked ? () => _openStage(stageIndex) : null,
                        scheme: scheme,
                        text: text,
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _StageGroupHeader extends StatelessWidget {
  final int groupIndex;
  final int groupCount;
  final int start;
  final int end;
  final int total;
  final bool expanded;
  final AppText text;
  final VoidCallback onTap;

  const _StageGroupHeader({
    required this.groupIndex,
    required this.groupCount,
    required this.start,
    required this.end,
    required this.total,
    required this.expanded,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: expanded ? scheme.primary : scheme.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${groupIndex + 1}',
                  style: notoSerifJp(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: scheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text.stageRange(start + 1, end),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: notoSerifJp(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      text.stageGroupProgress(
                        groupIndex + 1,
                        groupCount,
                        total,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: notoSansJp(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                expanded ? Icons.expand_less_rounded : Icons.tune_rounded,
                size: 19,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageGroupPicker extends StatelessWidget {
  final int groupIndex;
  final int groupCount;
  final int total;
  final ValueChanged<int> onSelected;

  const _StageGroupPicker({
    required this.groupIndex,
    required this.groupCount,
    required this.total,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: groupCount,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = index == groupIndex;
          return ChoiceChip(
            selected: selected,
            label: Text(
              '${index * _stagesPerGroup + 1}-${((index + 1) * _stagesPerGroup).clamp(0, total)}',
            ),
            onSelected: (_) => onSelected(index),
            showCheckmark: false,
            selectedColor: scheme.primaryContainer,
            labelStyle: notoSansJp(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
            ),
            side: BorderSide(
              color: selected ? scheme.primary : scheme.outlineVariant,
            ),
          );
        },
      ),
    );
  }
}

class _StageRewardSummary extends StatelessWidget {
  final int totalStars;
  final ColorScheme scheme;
  final AppText text;
  const _StageRewardSummary({
    required this.totalStars,
    required this.scheme,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final nextThreshold = totalStars < 20 ? 20 : (totalStars < 40 ? 40 : null);
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          Icon(Icons.workspace_premium_rounded, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text.stageRewards,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: notoSerifJp(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
          ),
          const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF4B740)),
          const SizedBox(width: 3),
          Text(
            '$totalStars',
            style: notoSerifJp(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          if (nextThreshold != null) ...[
            const SizedBox(width: 10),
            Tooltip(
              message: text.stageRewards,
              child: _RewardChip(
                threshold: nextThreshold,
                label: '',
                totalStars: totalStars,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  final int threshold;
  final String label;
  final int totalStars;
  const _RewardChip({
    required this.threshold,
    required this.label,
    required this.totalStars,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final unlocked = totalStars >= threshold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: unlocked
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            unlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
            size: 15,
            color: unlocked
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 5),
          Text(
            label.isEmpty ? '$threshold' : '$label $threshold',
            style: notoSansJp(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: unlocked
                  ? scheme.onPrimaryContainer
                  : scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  final int index;
  final String title;
  final String subtitle;
  final int earnedStars;
  final int maxStars;
  final int rounds;
  final int questionCount;
  final bool isCurrent;
  final bool unlocked;
  final VoidCallback? onTap;
  final ColorScheme scheme;
  final AppText text;

  const _StageCard({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.earnedStars,
    required this.maxStars,
    required this.rounds,
    required this.questionCount,
    required this.isCurrent,
    required this.unlocked,
    required this.onTap,
    required this.scheme,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final cleared = earnedStars > 0;
    final perfect = maxStars > 0 && earnedStars >= maxStars;
    final textOn = unlocked ? scheme.onSurface : scheme.onSurfaceVariant;
    final background = !unlocked
        ? scheme.surfaceContainerHigh
        : isCurrent
        ? scheme.primaryContainer.withValues(alpha: 0.38)
        : scheme.surface;
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppUi.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppUi.cardRadius),
            border: Border.all(
              color: isCurrent
                  ? scheme.primary
                  : cleared
                  ? scheme.tertiary
                  : scheme.outlineVariant,
              width: isCurrent ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? scheme.primary
                          : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: notoSerifJp(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isCurrent ? scheme.onPrimary : scheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: notoSerifJp(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textOn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (cleared)
                    _ClearedBadge(
                      label: perfect ? 'Perfect' : text.cleared,
                      color: scheme.tertiary,
                    ),
                  if (isCurrent && !cleared)
                    _ClearedBadge(
                      label: _currentLabel(text.language),
                      color: scheme.primary,
                    ),
                  if (cleared) const SizedBox(width: 6),
                  if (!unlocked)
                    Icon(Icons.lock_rounded, color: textOn, size: 20),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: notoSansJp(
                  fontSize: 12,
                  height: 1.35,
                  color: textOn.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StageStars(earnedStars: earnedStars, maxStars: maxStars),
                  const SizedBox(width: 8),
                  Text(
                    '$earnedStars / $maxStars',
                    style: notoSerifJp(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textOn,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      _roundMeta(text.language, rounds, questionCount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: notoSansJp(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (cleared)
                    Icon(Icons.check_circle_rounded, color: textOn, size: 24)
                  else if (unlocked)
                    Icon(Icons.chevron_right_rounded, color: textOn),
                ],
              ),
              if (!unlocked) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 15,
                      color: textOn.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        text.clearHalfPreviousStage,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: notoSansJp(
                          fontSize: 11,
                          height: 1.35,
                          color: textOn.withValues(alpha: 0.85),
                        ),
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

class _ClearedBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _ClearedBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 13, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            maxLines: 1,
            style: notoSansJp(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StageStars extends StatelessWidget {
  final int earnedStars;
  final int maxStars;

  const _StageStars({required this.earnedStars, required this.maxStars});

  @override
  Widget build(BuildContext context) {
    final filled = maxStars <= 0
        ? 0
        : ((earnedStars / maxStars) * 5).round().clamp(0, 5);
    return AppStarRating(value: filled);
  }
}

String _currentLabel(StudyLanguage language) => switch (language) {
  StudyLanguage.ko => '이어하기',
  StudyLanguage.en => 'Continue',
  StudyLanguage.ja => '続きから',
};

String _roundMeta(StudyLanguage language, int rounds, int questions) =>
    switch (language) {
      StudyLanguage.ko => '$rounds라운드 · $questions문제',
      StudyLanguage.en => '$rounds rounds · $questions questions',
      StudyLanguage.ja => '$roundsラウンド · $questions問',
    };
