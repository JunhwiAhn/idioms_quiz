import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/audio_service.dart';
import '../data/crossword.dart';
import '../theme/app_theme.dart';

const int kCrosswordPuzzlesPerSession = 5;

class CrosswordScreen extends StatefulWidget {
  final CrosswordBank bank;
  const CrosswordScreen({super.key, required this.bank});

  @override
  State<CrosswordScreen> createState() => _CrosswordScreenState();
}

class _CrosswordScreenState extends State<CrosswordScreen> {
  late List<CrosswordPuzzle> _puzzles;
  int _index = 0;

  // Map "r,c" → pool slot index. The slot is considered "used" if it
  // appears in this map's values.
  final Map<String, int> _filled = {};
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _puzzles = widget.bank.samplePuzzles(kCrosswordPuzzlesPerSession);
  }

  CrosswordPuzzle get _p => _puzzles[_index];
  int get _total => _puzzles.length;

  String _k(int r, int c) => '$r,$c';

  Set<int> get _usedSlots => _filled.values.toSet();

  void _accept(int r, int c, int slot) {
    if (_revealed) return;
    setState(() {
      _filled[_k(r, c)] = slot;
    });
  }

  void _clearCell(int r, int c) {
    if (_revealed) return;
    setState(() {
      _filled.remove(_k(r, c));
    });
  }

  bool get _allFilled {
    for (final cell in _p.activeCells) {
      if (_filled[_k(cell.$1, cell.$2)] == null) return false;
    }
    return true;
  }

  bool get _isCorrect {
    for (final cell in _p.activeCells) {
      final slot = _filled[_k(cell.$1, cell.$2)];
      if (slot == null) return false;
      if (_p.pool[slot] != _p.expectedAt(cell.$1, cell.$2)) return false;
    }
    return true;
  }

  void _reveal() {
    if (!_allFilled) return;
    setState(() => _revealed = true);
    AudioService.instance
        .playSfx(_isCorrect ? Sfx.correct : Sfx.wrong);
  }

  void _next() {
    if (_index >= _total - 1) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _index++;
      _filled.clear();
      _revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('クロスワード ${_index + 1} / $_total'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ClueLine(label: 'よこ', meaning: _p.horizontal.meaning),
            const SizedBox(height: 6),
            _ClueLine(label: 'たて', meaning: _p.vertical.meaning),
            const SizedBox(height: 18),
            Center(
              child: _Grid(
                puzzle: _p,
                filled: _filled,
                revealed: _revealed,
                onAccept: _accept,
                onTapClear: _clearCell,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              '下の漢字を空きマスへドラッグ&ドロップ (マスをタップで戻す)',
              textAlign: TextAlign.center,
              style: notoSansJp(
                fontSize: 12,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int i = 0; i < _p.pool.length; i++)
                  _PoolDraggable(
                    kanji: _p.pool[i],
                    slot: i,
                    used: _usedSlots.contains(i),
                    disabled: _revealed,
                  ),
              ],
            ),
            const SizedBox(height: 24),
            if (_revealed)
              _ResultBanner(correct: _isCorrect, puzzle: _p)
                  .animate()
                  .fadeIn(duration: 250.ms),
            if (_revealed) const SizedBox(height: 12),
            FilledButton(
              onPressed: _revealed
                  ? _next
                  : (_allFilled ? _reveal : null),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: Text(
                _revealed
                    ? (_index >= _total - 1 ? '終了' : '次へ')
                    : (_allFilled ? '答え合わせ' : 'すべて埋めよう'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClueLine extends StatelessWidget {
  final String label;
  final String meaning;
  const _ClueLine({required this.label, required this.meaning});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: notoSansJp(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: scheme.onPrimaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            meaning,
            style: notoSerifJp(
              fontSize: 13,
              height: 1.5,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _Grid extends StatelessWidget {
  final CrosswordPuzzle puzzle;
  final Map<String, int> filled;
  final bool revealed;
  final void Function(int r, int c, int slot) onAccept;
  final void Function(int r, int c) onTapClear;

  const _Grid({
    required this.puzzle,
    required this.filled,
    required this.revealed,
    required this.onAccept,
    required this.onTapClear,
  });

  @override
  Widget build(BuildContext context) {
    const cellSize = 62.0;
    const gap = 6.0;
    final totalSize = 4 * cellSize + 3 * gap;
    return SizedBox(
      width: totalSize,
      height: totalSize,
      child: Column(
        children: [
          for (int r = 0; r < 4; r++) ...[
            if (r > 0) const SizedBox(height: gap),
            SizedBox(
              height: cellSize,
              child: Row(
                children: [
                  for (int c = 0; c < 4; c++) ...[
                    if (c > 0) const SizedBox(width: gap),
                    _Cell(
                      size: cellSize,
                      puzzle: puzzle,
                      r: r,
                      c: c,
                      filledSlot: filled['$r,$c'],
                      revealed: revealed,
                      onAccept: (slot) => onAccept(r, c, slot),
                      onTapClear: () => onTapClear(r, c),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Cell extends StatefulWidget {
  final double size;
  final CrosswordPuzzle puzzle;
  final int r;
  final int c;
  final int? filledSlot;
  final bool revealed;
  final void Function(int slot) onAccept;
  final VoidCallback onTapClear;

  const _Cell({
    required this.size,
    required this.puzzle,
    required this.r,
    required this.c,
    required this.filledSlot,
    required this.revealed,
    required this.onAccept,
    required this.onTapClear,
  });

  @override
  State<_Cell> createState() => _CellState();
}

class _CellState extends State<_Cell> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active =
        widget.puzzle.isCellActive(widget.r, widget.c);
    if (!active) {
      return SizedBox(width: widget.size, height: widget.size);
    }

    final slot = widget.filledSlot;
    final kanji = slot == null ? null : widget.puzzle.pool[slot];

    Color bg = scheme.surface;
    Color border = scheme.outlineVariant;
    Color textColor = scheme.onSurface;
    double borderWidth = 1.2;

    if (widget.revealed) {
      final expected =
          widget.puzzle.expectedAt(widget.r, widget.c);
      final correct = kanji == expected;
      bg = correct ? AppTheme.correctBg : scheme.errorContainer;
      border = correct ? AppTheme.correctBorder : scheme.error;
      textColor =
          correct ? AppTheme.correctFg : scheme.onErrorContainer;
    } else if (_hovering) {
      bg = scheme.primaryContainer.withValues(alpha: 0.4);
      border = scheme.primary;
      borderWidth = 2;
    } else if (kanji == null) {
      bg = scheme.surfaceContainerHighest;
    }

    return DragTarget<int>(
      onWillAcceptWithDetails: (_) {
        if (widget.revealed) return false;
        setState(() => _hovering = true);
        return true;
      },
      onLeave: (_) => setState(() => _hovering = false),
      onAcceptWithDetails: (d) {
        setState(() => _hovering = false);
        widget.onAccept(d.data);
      },
      builder: (context, candidate, rejected) {
        return GestureDetector(
          onTap: kanji != null && !widget.revealed
              ? widget.onTapClear
              : null,
          child: Container(
            width: widget.size,
            height: widget.size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border, width: borderWidth),
            ),
            child: Text(
              kanji ?? '',
              style: notoSerifJp(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PoolDraggable extends StatelessWidget {
  final String kanji;
  final int slot;
  final bool used;
  final bool disabled;

  const _PoolDraggable({
    required this.kanji,
    required this.slot,
    required this.used,
    required this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    final chip = _PoolChip(kanji: kanji, used: used, disabled: disabled);
    if (used || disabled) return chip;
    return Draggable<int>(
      data: slot,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.translate(
          offset: const Offset(-24, -27),
          child: _PoolChip(
            kanji: kanji,
            used: false,
            disabled: false,
            dragging: true,
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: chip,
      ),
      child: chip,
    );
  }
}

class _PoolChip extends StatelessWidget {
  final String kanji;
  final bool used;
  final bool disabled;
  final bool dragging;
  const _PoolChip({
    required this.kanji,
    required this.used,
    required this.disabled,
    this.dragging = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = dragging
        ? scheme.primaryContainer
        : used
            ? scheme.surfaceContainerHigh
            : scheme.surface;
    final textColor = used
        ? scheme.onSurfaceVariant.withValues(alpha: 0.4)
        : dragging
            ? scheme.onPrimaryContainer
            : scheme.onSurface;
    return Opacity(
      opacity: disabled ? 0.7 : 1,
      child: Container(
        width: 48,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: used
                ? scheme.outlineVariant.withValues(alpha: 0.5)
                : scheme.primary,
            width: 1.5,
          ),
          boxShadow: dragging
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          kanji,
          style: notoSerifJp(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  final bool correct;
  final CrosswordPuzzle puzzle;
  const _ResultBanner({required this.correct, required this.puzzle});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: correct ? AppTheme.correctBg : scheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                correct
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                color: correct
                    ? AppTheme.correctFg
                    : scheme.onErrorContainer,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                correct ? '正解!' : '不正解',
                style: notoSerifJp(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: correct
                      ? scheme.onPrimaryContainer
                      : scheme.onErrorContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'よこ: ${puzzle.horizontal.idiom} (${puzzle.horizontal.reading})',
            style: notoSansJp(
              fontSize: 13,
              color: correct
                  ? scheme.onPrimaryContainer
                  : scheme.onErrorContainer,
            ),
          ),
          Text(
            'たて: ${puzzle.vertical.idiom} (${puzzle.vertical.reading})',
            style: notoSansJp(
              fontSize: 13,
              color: correct
                  ? scheme.onPrimaryContainer
                  : scheme.onErrorContainer,
            ),
          ),
        ],
      ),
    );
  }
}
