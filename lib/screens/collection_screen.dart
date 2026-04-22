import 'package:flutter/material.dart';
import '../data/idiom_images.dart';
import '../data/score_service.dart' show kMasteryThreshold;
import '../theme/app_theme.dart';
import '../models/idiom.dart';

enum _Filter { all, mastered, locked }

class CollectionScreen extends StatefulWidget {
  final List<Idiom> idioms;
  final Set<String> mastered;
  final Map<String, int> correctCounts;

  const CollectionScreen({
    super.key,
    required this.idioms,
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
        return a.reading.compareTo(b.reading);
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

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Idiom> get _visible {
    final q = _query.trim();
    return _sorted.where((idiom) {
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
          idiom.reading.contains(q) ||
          idiom.meaning.contains(q);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final visible = _visible;

    return Scaffold(
      appBar: AppBar(
        title: Text('図鑑 ${widget.mastered.length}/${widget.idioms.length}'),
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 200),
        offset: _showToTop ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _showToTop ? 1 : 0,
          child: FloatingActionButton.small(
            heroTag: 'collection-to-top',
            tooltip: '一番上へ',
            onPressed: _showToTop ? _scrollToTop : null,
            child: const Icon(Icons.keyboard_arrow_up_rounded),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: scheme.onSecondaryContainer),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '獲得条件: クイズで $kMasteryThreshold 回以上正解',
                      style: notoSansJp(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              style: notoSansJp(fontSize: 14, color: scheme.onSurface),
              decoration: InputDecoration(
                hintText: '四字熟語・読み・意味で検索',
                hintStyle: notoSansJp(
                  fontSize: 13,
                  color: scheme.onSurfaceVariant,
                ),
                prefixIcon: Icon(Icons.search_rounded,
                    color: scheme.onSurfaceVariant),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'クリア',
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      ),
                isDense: true,
                filled: true,
                fillColor: scheme.surfaceContainerHighest,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
            child: Row(
              children: [
                _FilterChip(
                  label: '全て',
                  selected: _filter == _Filter.all,
                  onTap: () => setState(() => _filter = _Filter.all),
                ),
                const SizedBox(width: 6),
                _FilterChip(
                  label: '獲得済み',
                  selected: _filter == _Filter.mastered,
                  onTap: () => setState(() => _filter = _Filter.mastered),
                ),
                const SizedBox(width: 6),
                _FilterChip(
                  label: '未獲得',
                  selected: _filter == _Filter.locked,
                  onTap: () => setState(() => _filter = _Filter.locked),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    '${visible.length}件',
                    style: notoSansJp(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: visible.isEmpty
                ? _EmptyState(query: _query)
                : GridView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: 140,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    cacheExtent: 600,
                    itemCount: visible.length,
                    itemBuilder: (context, i) {
                      final idiom = visible[i];
                      final isMastered =
                          widget.mastered.contains(idiom.idiom);
                      final count =
                          widget.correctCounts[idiom.idiom] ?? 0;
                      return _CollectionCard(
                        key: ValueKey(idiom.idiom),
                        idiom: idiom,
                        mastered: isMastered,
                        correctCount: count,
                        onTap: () => showModalBottomSheet<void>(
                          context: context,
                          showDragHandle: true,
                          backgroundColor: scheme.surface,
                          builder: (_) => _IdiomSheet(
                            idiom: idiom,
                            mastered: isMastered,
                            correctCount: count,
                          ),
                        ),
                      );
                    },
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
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 48, color: scheme.onSurfaceVariant),
          const SizedBox(height: 10),
          Text(
            query.trim().isEmpty ? '該当する熟語がありません' : '「$query」に一致する熟語はありません',
            style: notoSansJp(
              fontSize: 13,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final Idiom idiom;
  final bool mastered;
  final int correctCount;
  final VoidCallback? onTap;

  const _CollectionCard({
    super.key,
    required this.idiom,
    required this.mastered,
    required this.correctCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: mastered
                  ? LinearGradient(
                      colors: [scheme.primary, scheme.tertiary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: mastered ? null : scheme.surface,
              border: mastered
                  ? null
                  : Border.all(
                      color: scheme.outlineVariant,
                      width: 1,
                    ),
              boxShadow: mastered
                  ? [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        idiom.idiom,
                        style: notoSerifJp(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4,
                          color: mastered
                              ? scheme.onPrimary
                              : scheme.onSurface
                                  .withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        idiom.reading,
                        style: notoSansJp(
                          fontSize: 12,
                          color: mastered
                              ? scheme.onPrimary.withValues(alpha: 0.85)
                              : scheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                if (mastered)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: scheme.onPrimary.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_rounded,
                              size: 12, color: scheme.onPrimary),
                          const SizedBox(width: 2),
                          Text(
                            '獲得済み',
                            style: notoSansJp(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: scheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$correctCount / $kMasteryThreshold',
                        style: notoSansJp(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 6,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (mastered ? scheme.onPrimary : scheme.primary)
                          .withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Lv${idiom.difficulty}',
                      style: notoSansJp(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: mastered ? scheme.onPrimary : scheme.primary,
                      ),
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

class _IdiomSheet extends StatelessWidget {
  final Idiom idiom;
  final bool mastered;
  final int correctCount;
  const _IdiomSheet({
    required this.idiom,
    required this.mastered,
    required this.correctCount,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (mastered)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded,
                        size: 14, color: scheme.onPrimaryContainer),
                    const SizedBox(width: 4),
                    Text(
                      '獲得済み',
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
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline_rounded,
                        size: 14, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '未獲得 ($correctCount / $kMasteryThreshold)',
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
          Center(
            child: Text(
              idiom.idiom,
              style: notoSerifJp(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: 6,
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              idiom.reading,
              style: notoSansJp(
                fontSize: 13,
                color: scheme.onSurfaceVariant,
                letterSpacing: 2,
              ),
            ),
          ),
          if (IdiomImageRegistry.instance.has(idiom.idiom)) ...[
            const SizedBox(height: 14),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 180,
                  height: 180,
                  child: Image.asset(
                    IdiomImageRegistry.instance.pathFor(idiom.idiom)!,
                    fit: BoxFit.cover,
                    cacheWidth: 360,
                    cacheHeight: 360,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: mastered
                  ? scheme.primaryContainer
                  : scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              idiom.meaning,
              style: notoSerifJp(
                fontSize: 15,
                height: 1.6,
                color: mastered
                    ? scheme.onPrimaryContainer
                    : scheme.onSurface,
              ),
            ),
          ),
          if (!mastered) ...[
            const SizedBox(height: 10),
            Text(
              'クイズで $kMasteryThreshold 回正解すると「獲得済み」になります。',
              style: notoSansJp(
                fontSize: 11,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
