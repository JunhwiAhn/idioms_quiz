import 'package:flutter/material.dart';
import '../data/app_text.dart';
import '../widgets/pronounce.dart';
import '../data/score_service.dart'
    show MasteryStage, kMasteryThreshold, masteryStageForCount;
import '../theme/app_theme.dart';
import '../models/idiom.dart';

enum _Filter { all, mastered, locked }

class CollectionScreen extends StatefulWidget {
  final List<Idiom> idioms;
  final StudyLanguage language;
  final Set<String> mastered;
  final Map<String, int> correctCounts;

  const CollectionScreen({
    super.key,
    required this.idioms,
    required this.language,
    required this.mastered,
    required this.correctCounts,
  });

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  late final List<Idiom> _sorted;
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String _query = '';
  _Filter _filter = _Filter.all;
  bool _showOverview = false;
  bool _showToTop = false;

  @override
  void initState() {
    super.initState();
    _sorted = [...widget.idioms]
      ..sort((a, b) {
        final am = widget.mastered.contains(a.idiom);
        final bm = widget.mastered.contains(b.idiom);
        if (am != bm) return am ? -1 : 1;
        final d = a.difficulty.compareTo(b.difficulty);
        if (d != 0) return d;
        return a.idiom.compareTo(b.idiom);
      });
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    final show = _scrollCtrl.hasClients && _scrollCtrl.offset > 400;
    if (show != _showToTop) {
      setState(() => _showToTop = show);
    }
  }

  Future<void> _scrollToTop() async {
    if (!_scrollCtrl.hasClients) return;
    await _scrollCtrl.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _jumpListToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(0);
      }
    });
  }

  void _setFilter(_Filter filter) {
    setState(() => _filter = filter);
    _jumpListToTop();
  }

  void _setQuery(String value) {
    setState(() => _query = value);
    _jumpListToTop();
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Idiom> get _visible {
    final q = _query.trim();
    return _sorted
        .where((idiom) {
          if (_filter == _Filter.mastered &&
              !widget.mastered.contains(idiom.idiom)) {
            return false;
          }
          if (_filter == _Filter.locked &&
              widget.mastered.contains(idiom.idiom)) {
            return false;
          }
          if (q.isEmpty) return true;
          return idiom.idiom.contains(q) ||
              idiom.meaningFor(widget.language).contains(q) ||
              idiom.level.toLowerCase().contains(q.toLowerCase());
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final text = AppText(widget.language);
    final levelStats = _levelStats();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          text.wordbookTitle(widget.mastered.length, widget.idioms.length),
        ),
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 200),
        offset: _showToTop ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _showToTop ? 1 : 0,
          child: FloatingActionButton.small(
            heroTag: 'collection-to-top',
            tooltip: text.backToTop,
            onPressed: _showToTop ? _scrollToTop : null,
            child: const Icon(Icons.keyboard_arrow_up_rounded),
          ),
        ),
      ),
      // AppBar covers the top inset; guard the bottom so the last word card is
      // not hidden behind the gesture bar under edge-to-edge.
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;
            return Column(
              children: [
                _CollectionToolbar(
                  maxWidth: 1000,
                  isWide: isWide,
                  searchController: _searchCtrl,
                  query: _query,
                  text: text,
                  filter: _filter,
                  resultCount: visible.length,
                  stats: levelStats,
                  showOverview: _showOverview,
                  onOverviewTap: () =>
                      setState(() => _showOverview = !_showOverview),
                  onQueryChanged: _setQuery,
                  onClearQuery: () {
                    _searchCtrl.clear();
                    _setQuery('');
                  },
                  onFilterChanged: _setFilter,
                ),
                Expanded(
                  child: visible.isEmpty
                      ? _EmptyState(query: _query, text: text)
                      : Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1000),
                            child: isWide
                                ? GridView.builder(
                                    controller: _scrollCtrl,
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      8,
                                      16,
                                      80,
                                    ),
                                    cacheExtent: 700,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          mainAxisExtent: 174,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                        ),
                                    itemCount: visible.length,
                                    itemBuilder: (context, i) =>
                                        _buildCollectionCard(
                                          context,
                                          visible[i],
                                          text,
                                        ),
                                  )
                                : ListView.separated(
                                    controller: _scrollCtrl,
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      6,
                                      12,
                                      80,
                                    ),
                                    cacheExtent: 600,
                                    itemCount: visible.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(height: 8),
                                    itemBuilder: (context, i) =>
                                        _buildCollectionCard(
                                          context,
                                          visible[i],
                                          text,
                                        ),
                                  ),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCollectionCard(BuildContext context, Idiom idiom, AppText text) {
    final isMastered = widget.mastered.contains(idiom.idiom);
    final count = widget.correctCounts[idiom.idiom] ?? 0;
    return _CollectionCard(
      key: ValueKey(idiom.idiom),
      idiom: idiom,
      language: widget.language,
      text: text,
      mastered: isMastered,
      correctCount: count,
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 36,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
            child: _IdiomSheet(
              idiom: idiom,
              language: widget.language,
              text: text,
              mastered: isMastered,
              correctCount: count,
            ),
          ),
        ),
      ),
    );
  }

  List<_LevelMasteryStat> _levelStats() {
    const levels = ['A1', 'A2', 'B1'];
    return [
      for (final level in levels)
        _LevelMasteryStat(
          level: level,
          total: widget.idioms
              .where((idiom) => idiom.level.toUpperCase() == level)
              .length,
          mastered: widget.idioms
              .where(
                (idiom) =>
                    idiom.level.toUpperCase() == level &&
                    widget.mastered.contains(idiom.idiom),
              )
              .length,
        ),
    ];
  }
}

class _CollectionToolbar extends StatelessWidget {
  final double maxWidth;
  final bool isWide;
  final TextEditingController searchController;
  final String query;
  final AppText text;
  final _Filter filter;
  final int resultCount;
  final List<_LevelMasteryStat> stats;
  final bool showOverview;
  final VoidCallback onOverviewTap;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final ValueChanged<_Filter> onFilterChanged;

  const _CollectionToolbar({
    required this.maxWidth,
    required this.isWide,
    required this.searchController,
    required this.query,
    required this.text,
    required this.filter,
    required this.resultCount,
    required this.stats,
    required this.showOverview,
    required this.onOverviewTap,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, isWide ? 12 : 8, 16, 4),
          child: Column(
            children: [
              _CollectionOverview(
                stats: stats,
                text: text,
                expanded: showOverview,
                onTap: onOverviewTap,
              ),
              SizedBox(height: isWide ? 10 : 8),
              if (isWide)
                Row(
                  children: [
                    Expanded(child: _buildSearchField(context)),
                    const SizedBox(width: 12),
                    _buildFilters(context),
                  ],
                )
              else ...[
                _buildSearchField(context),
                const SizedBox(height: 6),
                _buildFilters(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 44,
      child: TextField(
        controller: searchController,
        textInputAction: TextInputAction.search,
        style: notoSansJp(fontSize: 14, color: scheme.onSurface),
        decoration: InputDecoration(
          hintText: text.searchWordbookHint,
          hintStyle: notoSansJp(fontSize: 13, color: scheme.onSurfaceVariant),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: scheme.onSurfaceVariant,
          ),
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 19),
                  tooltip: text.clear,
                  onPressed: onClearQuery,
                ),
          isDense: true,
          filled: true,
          fillColor: scheme.surfaceContainerHighest,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: onQueryChanged,
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final chips = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FilterChip(
          label: text.filterAll,
          selected: filter == _Filter.all,
          onTap: () => onFilterChanged(_Filter.all),
        ),
        const SizedBox(width: 6),
        _FilterChip(
          label: text.unlocked,
          selected: filter == _Filter.mastered,
          onTap: () => onFilterChanged(_Filter.mastered),
        ),
        const SizedBox(width: 6),
        _FilterChip(
          label: text.locked,
          selected: filter == _Filter.locked,
          onTap: () => onFilterChanged(_Filter.locked),
        ),
      ],
    );
    final resultBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$resultCount',
        style: notoSansJp(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
    if (isWide) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [chips, const SizedBox(width: 10), resultBadge],
      );
    }
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: chips,
          ),
        ),
        const SizedBox(width: 10),
        resultBadge,
      ],
    );
  }
}

class _CollectionOverview extends StatelessWidget {
  final List<_LevelMasteryStat> stats;
  final AppText text;
  final bool expanded;
  final VoidCallback onTap;

  const _CollectionOverview({
    required this.stats,
    required this.text,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mastered = stats.fold<int>(0, (sum, stat) => sum + stat.mastered);
    final total = stats.fold<int>(0, (sum, stat) => sum + stat.total);
    return Material(
      color: scheme.secondaryContainer.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.insights_rounded,
                      size: 18,
                      color: scheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        '${text.unlocked} $mastered/$total',
                        style: notoSansJp(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: scheme.onSecondaryContainer,
                    ),
                  ],
                ),
                if (expanded) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      text.unlockHint(kMasteryThreshold),
                      style: notoSansJp(
                        fontSize: 11,
                        height: 1.35,
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _LevelMasterySummary(stats: stats),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelMasteryStat {
  final String level;
  final int mastered;
  final int total;

  const _LevelMasteryStat({
    required this.level,
    required this.mastered,
    required this.total,
  });

  double get progress => total == 0 ? 0 : mastered / total;
}

class _LevelMasterySummary extends StatelessWidget {
  final List<_LevelMasteryStat> stats;

  const _LevelMasterySummary({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          Expanded(child: _LevelMasteryCard(stat: stats[i])),
          if (i != stats.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _LevelMasteryCard extends StatelessWidget {
  final _LevelMasteryStat stat;

  const _LevelMasteryCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final percent = (stat.progress * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                stat.level,
                style: notoSerifJp(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '$percent%',
                style: notoSansJp(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: stat.progress,
              minHeight: 4,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primary : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: notoSansJp(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  final AppText text;
  const _EmptyState({required this.query, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(height: 10),
          Text(
            query.trim().isEmpty ? text.noWordsFound : text.noWordsMatch(query),
            style: notoSansJp(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final Idiom idiom;
  final StudyLanguage language;
  final AppText text;
  final bool mastered;
  final int correctCount;
  final VoidCallback? onTap;

  const _CollectionCard({
    super.key,
    required this.idiom,
    required this.language,
    required this.text,
    required this.mastered,
    required this.correctCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stage = masteryStageForCount(correctCount);
    final stageLabel = _masteryLabel(stage, language);
    final progress = (correctCount / kMasteryThreshold).clamp(0.0, 1.0);
    final statusColor = mastered ? scheme.primary : scheme.tertiary;
    final statusBg = mastered
        ? scheme.primaryContainer
        : scheme.surfaceContainerHighest;
    final example = idiom.hasUsableExample ? idiom.example.trim() : '';
    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: scheme.surface,
              border: Border.all(
                color: mastered
                    ? scheme.primary.withValues(alpha: 0.45)
                    : scheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                idiom.idiom,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: notoSerifJp(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: scheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _TinyTag(label: idiom.level),
                            const SizedBox(width: 4),
                            _TinyTag(
                              label: text.partOfSpeechName(idiom.partOfSpeech),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              idiom.meaningFor(language),
                              style: notoSansJp(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        if (example.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            example,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: notoSerifJp(
                              fontSize: 13,
                              height: 1.35,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (!mastered) ...[
                          const SizedBox(height: 5),
                          Text(
                            text.lockedProgress(
                              correctCount,
                              kMasteryThreshold,
                            ),
                            style: notoSansJp(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        _MasteryProgress(
                          label: stageLabel,
                          correctCount: correctCount,
                          progress: progress,
                          mastered: mastered,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          mastered
                              ? Icons.check_rounded
                              : Icons.menu_book_outlined,
                          size: 13,
                          color: statusColor,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          mastered ? text.unlocked : text.locked,
                          style: notoSansJp(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
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

String _masteryLabel(MasteryStage stage, StudyLanguage language) {
  return switch (language) {
    StudyLanguage.ko => switch (stage) {
      MasteryStage.locked => '학습 전',
      MasteryStage.familiar => '학습 중',
      MasteryStage.learned => '익힘',
      MasteryStage.mastered => '수집 완료',
    },
    StudyLanguage.en => switch (stage) {
      MasteryStage.locked => 'Not studied',
      MasteryStage.familiar => 'Learning',
      MasteryStage.learned => 'Learned',
      MasteryStage.mastered => 'Collected',
    },
    StudyLanguage.ja => switch (stage) {
      MasteryStage.locked => '学習前',
      MasteryStage.familiar => '学習中',
      MasteryStage.learned => '習得',
      MasteryStage.mastered => '収集済み',
    },
  };
}

class _MasteryProgress extends StatelessWidget {
  final String label;
  final int correctCount;
  final double progress;
  final bool mastered;

  const _MasteryProgress({
    required this.label,
    required this.correctCount,
    required this.progress,
    required this.mastered,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = mastered ? scheme.primary : scheme.tertiary;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: notoSansJp(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$correctCount/$kMasteryThreshold',
          style: notoSansJp(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _TinyTag extends StatelessWidget {
  final String label;
  const _TinyTag({required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: notoSansJp(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _IdiomSheet extends StatelessWidget {
  final Idiom idiom;
  final StudyLanguage language;
  final AppText text;
  final bool mastered;
  final int correctCount;
  const _IdiomSheet({
    required this.idiom,
    required this.language,
    required this.text,
    required this.mastered,
    required this.correctCount,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stage = masteryStageForCount(correctCount);
    final progress = (correctCount / kMasteryThreshold).clamp(0.0, 1.0);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (mastered)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: scheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      text.unlocked,
                      style: notoSansJp(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      text.lockedProgress(correctCount, kMasteryThreshold),
                      style: notoSansJp(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  idiom.idiom,
                  textAlign: TextAlign.center,
                  style: notoSerifJp(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PronounceButton(
                text: idiom.idiom,
                appText: text,
                builder: (context, available, onPressed) =>
                    IconButton.filledTonal(
                      tooltip: available
                          ? text.playPronunciation
                          : text.ttsDownloadVoice,
                      onPressed: onPressed,
                      icon: Icon(
                        available
                            ? Icons.volume_up_rounded
                            : Icons.download_rounded,
                      ),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _MasteryProgress(
            label: _masteryLabel(stage, language),
            correctCount: correctCount,
            progress: progress,
            mastered: mastered,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: mastered
                  ? scheme.primaryContainer
                  : scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              idiom.meaningFor(language),
              style: notoSerifJp(
                fontSize: 15,
                height: 1.6,
                color: mastered ? scheme.onPrimaryContainer : scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'DELE', value: idiom.level),
          _InfoRow(
            label: text.partOfSpeech,
            value: text.partOfSpeechName(idiom.partOfSpeech),
          ),
          if (idiom.hasUsableExample) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text.example,
                    style: notoSansJp(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    idiom.example,
                    style: notoSerifJp(
                      fontSize: 15,
                      height: 1.5,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (!mastered) ...[
            const SizedBox(height: 10),
            Text(
              text.lockedUnlockBody(kMasteryThreshold),
              style: notoSansJp(fontSize: 11, color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: notoSansJp(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: notoSansJp(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
