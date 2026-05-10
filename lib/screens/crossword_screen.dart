import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/audio_service.dart';
import '../data/app_text.dart';
import '../data/crossword.dart';
import '../data/score_service.dart';
import '../models/idiom.dart';
import '../theme/app_theme.dart';

const int kCrosswordPuzzlesPerSession = kCrosswordPuzzlesPerStage;

class CrosswordScreen extends StatefulWidget {
  final CrosswordBank bank;
  final StudyLanguage language;
  final List<CrosswordPuzzle>? puzzles;
  final CrosswordStageSpec? stage;
  const CrosswordScreen({
    super.key,
    required this.bank,
    required this.language,
    this.puzzles,
    this.stage,
  });

  @override
  State<CrosswordScreen> createState() => _CrosswordScreenState();
}

class _CrosswordScreenState extends State<CrosswordScreen> {
  late List<CrosswordPuzzle> _puzzles;
  int _index = 0;
  int? _selectedSlot;
  int _score = 0;
  int _correctSolved = 0;
  int _streak = 0;
  int _longestStreak = 0;
  bool _committing = false;
  final List<String> _correctIdioms = [];

  // Map "r,c" → pool slot index. The slot is considered "used" if it
  // appears in this map's values.
  final Map<String, int> _filled = {};
  final Set<String> _hintedCells = {};
  late List<Map<String, int>> _boardFilled;
  late List<Set<String>> _boardHintedCells;
  int? _selectedPuzzleIndex;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _puzzles =
        widget.puzzles ??
        widget.bank.samplePuzzles(kCrosswordPuzzlesPerSession);
    _boardFilled = List.generate(_puzzles.length, (_) => <String, int>{});
    _boardHintedCells = List.generate(_puzzles.length, (_) => <String>{});
  }

  CrosswordPuzzle get _p => _puzzles[_index];
  int get _total => _puzzles.length;

  String _k(int r, int c) => '$r,$c';

  Set<int> get _usedSlots => _filled.values.toSet();
  int get _hintCount => _hintedCells.length;
  int get _currentPotentialScore =>
      (100 - _hintCount * 20).clamp(20, 100).toInt();
  bool get _isStageBoard => widget.stage != null;

  Set<int> _usedSlotsFor(int puzzleIndex) =>
      _boardFilled[puzzleIndex].values.toSet();

  bool _allFilledFor(int puzzleIndex) {
    final puzzle = _puzzles[puzzleIndex];
    final filled = _boardFilled[puzzleIndex];
    for (final cell in puzzle.activeCells) {
      if (puzzle.isSharedCell(cell.$1, cell.$2)) continue;
      if (filled[_k(cell.$1, cell.$2)] == null) return false;
    }
    return true;
  }

  bool _isCorrectFor(int puzzleIndex) {
    final puzzle = _puzzles[puzzleIndex];
    final filled = _boardFilled[puzzleIndex];
    for (final cell in puzzle.activeCells) {
      if (puzzle.isSharedCell(cell.$1, cell.$2)) continue;
      final slot = filled[_k(cell.$1, cell.$2)];
      if (slot == null) return false;
      if (puzzle.pool[slot] != puzzle.expectedAt(cell.$1, cell.$2)) {
        return false;
      }
    }
    return true;
  }

  bool get _boardAllFilled {
    for (int i = 0; i < _puzzles.length; i++) {
      if (!_allFilledFor(i)) return false;
    }
    return true;
  }

  int get _boardHintCount =>
      _boardHintedCells.fold(0, (sum, cells) => sum + cells.length);

  int get _boardPotentialScore => (_puzzles.length * 100 - _boardHintCount * 20)
      .clamp(20, _puzzles.length * 100)
      .toInt();

  void _accept(int r, int c, int slot) {
    if (_revealed) return;
    setState(() {
      // If this slot is already placed in another cell, clear that cell
      // first so the kanji effectively moves.
      _filled.removeWhere((_, v) => v == slot);
      _filled[_k(r, c)] = slot;
      _selectedSlot = null;
    });
  }

  void _clearCell(int r, int c) {
    if (_revealed) return;
    setState(() {
      _filled.remove(_k(r, c));
    });
  }

  void _removeSlot(int slot) {
    if (_revealed) return;
    setState(() {
      _filled.removeWhere((_, v) => v == slot);
      if (_selectedSlot == slot) _selectedSlot = null;
    });
  }

  void _selectSlot(int slot) {
    if (_revealed || _usedSlots.contains(slot)) return;
    setState(() {
      _selectedSlot = _selectedSlot == slot ? null : slot;
    });
  }

  void _handleCellTap(int r, int c) {
    if (_revealed || _p.isSharedCell(r, c)) return;
    final selected = _selectedSlot;
    if (selected == null) {
      _clearCell(r, c);
      return;
    }
    _accept(r, c, selected);
  }

  int? _matchingUnusedSlot(String expected) {
    for (int i = 0; i < _p.pool.length; i++) {
      if (_usedSlots.contains(i)) continue;
      if (_p.pool[i] == expected) return i;
    }
    return null;
  }

  void _useHint() {
    if (_revealed || _hintCount >= 3) return;
    for (final cell in _p.fillableCells) {
      final key = _k(cell.$1, cell.$2);
      final currentSlot = _filled[key];
      final expected = _p.expectedAt(cell.$1, cell.$2);
      if (currentSlot != null && _p.pool[currentSlot] == expected) {
        continue;
      }
      final slot = _matchingUnusedSlot(expected);
      if (slot == null) continue;
      setState(() {
        _filled.removeWhere((_, v) => v == slot);
        _filled[key] = slot;
        _hintedCells.add(key);
        if (_selectedSlot == slot) _selectedSlot = null;
      });
      AudioService.instance.playSfx(Sfx.correct, multiplier: 0.55);
      return;
    }
  }

  void _boardAccept(int puzzleIndex, int r, int c, int slot) {
    if (_revealed) return;
    setState(() {
      final filled = _boardFilled[puzzleIndex];
      filled.removeWhere((_, v) => v == slot);
      filled[_k(r, c)] = slot;
      _selectedSlot = null;
      _selectedPuzzleIndex = null;
    });
  }

  void _boardClearCell(int puzzleIndex, int r, int c) {
    if (_revealed) return;
    setState(() {
      _boardFilled[puzzleIndex].remove(_k(r, c));
    });
  }

  void _boardRemoveSlot(int puzzleIndex, int slot) {
    if (_revealed) return;
    setState(() {
      _boardFilled[puzzleIndex].removeWhere((_, v) => v == slot);
      if (_selectedPuzzleIndex == puzzleIndex && _selectedSlot == slot) {
        _selectedSlot = null;
        _selectedPuzzleIndex = null;
      }
    });
  }

  void _boardSelectSlot(int puzzleIndex, int slot) {
    if (_revealed || _usedSlotsFor(puzzleIndex).contains(slot)) return;
    setState(() {
      if (_selectedPuzzleIndex == puzzleIndex && _selectedSlot == slot) {
        _selectedSlot = null;
        _selectedPuzzleIndex = null;
      } else {
        _selectedPuzzleIndex = puzzleIndex;
        _selectedSlot = slot;
      }
    });
  }

  void _boardHandleCellTap(int puzzleIndex, int r, int c) {
    final puzzle = _puzzles[puzzleIndex];
    if (_revealed || puzzle.isSharedCell(r, c)) return;
    final selected = _selectedPuzzleIndex == puzzleIndex ? _selectedSlot : null;
    if (selected == null) {
      _boardClearCell(puzzleIndex, r, c);
      return;
    }
    _boardAccept(puzzleIndex, r, c, selected);
  }

  int? _boardMatchingUnusedSlot(int puzzleIndex, String expected) {
    final puzzle = _puzzles[puzzleIndex];
    final used = _usedSlotsFor(puzzleIndex);
    for (int i = 0; i < puzzle.pool.length; i++) {
      if (used.contains(i)) continue;
      if (puzzle.pool[i] == expected) return i;
    }
    return null;
  }

  void _boardUseHint() {
    if (_revealed || _boardHintCount >= 12) return;
    for (int i = 0; i < _puzzles.length; i++) {
      final puzzle = _puzzles[i];
      final filled = _boardFilled[i];
      for (final cell in puzzle.fillableCells) {
        final key = _k(cell.$1, cell.$2);
        final currentSlot = filled[key];
        final expected = puzzle.expectedAt(cell.$1, cell.$2);
        if (currentSlot != null && puzzle.pool[currentSlot] == expected) {
          continue;
        }
        final slot = _boardMatchingUnusedSlot(i, expected);
        if (slot == null) continue;
        setState(() {
          filled.removeWhere((_, v) => v == slot);
          filled[key] = slot;
          _boardHintedCells[i].add(key);
          _selectedSlot = null;
          _selectedPuzzleIndex = null;
        });
        AudioService.instance.playSfx(Sfx.correct, multiplier: 0.55);
        return;
      }
    }
  }

  void _boardReveal() {
    if (!_boardAllFilled) return;
    var correctPuzzles = 0;
    final correctIdioms = <String>[];
    for (int i = 0; i < _puzzles.length; i++) {
      if (!_isCorrectFor(i)) continue;
      correctPuzzles++;
      correctIdioms
        ..add(_puzzles[i].horizontal.idiom)
        ..add(_puzzles[i].vertical.idiom);
    }
    setState(() {
      _revealed = true;
      _selectedSlot = null;
      _selectedPuzzleIndex = null;
      _correctSolved = correctPuzzles * 2;
      _streak = correctPuzzles;
      _longestStreak = correctPuzzles;
      _score = _boardPotentialScore * correctPuzzles ~/ _puzzles.length;
      _correctIdioms
        ..clear()
        ..addAll(correctIdioms);
    });
    AudioService.instance.playSfx(
      correctPuzzles == _puzzles.length ? Sfx.correct : Sfx.wrong,
    );
  }

  bool get _allFilled {
    for (final cell in _p.activeCells) {
      if (_p.isSharedCell(cell.$1, cell.$2)) continue;
      if (_filled[_k(cell.$1, cell.$2)] == null) return false;
    }
    return true;
  }

  bool get _isCorrect {
    for (final cell in _p.activeCells) {
      if (_p.isSharedCell(cell.$1, cell.$2)) continue;
      final slot = _filled[_k(cell.$1, cell.$2)];
      if (slot == null) return false;
      if (_p.pool[slot] != _p.expectedAt(cell.$1, cell.$2)) return false;
    }
    return true;
  }

  void _reveal() {
    if (!_allFilled) return;
    final correct = _isCorrect;
    setState(() {
      _revealed = true;
      _selectedSlot = null;
      if (correct) {
        _correctSolved++;
        _streak++;
        if (_streak > _longestStreak) _longestStreak = _streak;
        _score += _currentPotentialScore;
        _correctIdioms
          ..add(_p.horizontal.idiom)
          ..add(_p.vertical.idiom);
      } else {
        _streak = 0;
      }
    });
    AudioService.instance.playSfx(correct ? Sfx.correct : Sfx.wrong);
  }

  Future<void> _finishSession() async {
    if (_committing) return;
    setState(() => _committing = true);
    await ScoreService().commitRun(
      correct: _correctSolved,
      total: _isStageBoard ? kCrosswordWordsPerStage : _total,
      longestStreak: _longestStreak,
      correctIdioms: _correctIdioms,
      droppedHints: const [],
    );
    if (!mounted) return;
    final text = AppText(widget.language);
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
                Text(
                  text.crosswordClear,
                  style: notoSerifJp(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 14),
                _SessionStatRow(
                  score: _score,
                  correct: _correctSolved,
                  total: _isStageBoard ? kCrosswordWordsPerStage : _total,
                  bestStreak: _longestStreak,
                  text: text,
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(text.done),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _next() async {
    if (_index >= _total - 1) {
      await _finishSession();
      return;
    }
    setState(() {
      _index++;
      _filled.clear();
      _hintedCells.clear();
      _selectedSlot = null;
      _revealed = false;
    });
  }

  Widget _buildStageBoard(BuildContext context, AppText text) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CrosswordStatus(
            score: _score,
            streak: _streak,
            potential: _boardPotentialScore,
            hintsUsed: _boardHintCount,
            maxHints: 12,
            text: text,
            canHint: !_revealed && _boardHintCount < 12,
            onHint: _boardUseHint,
          ),
          const SizedBox(height: 10),
          Text(
            text.stageBoardWords(kCrosswordWordsPerStage),
            textAlign: TextAlign.center,
            style: notoSansJp(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < _puzzles.length; i++) ...[
            _BoardPuzzleCard(
              number: i + 1,
              puzzle: _puzzles[i],
              language: widget.language,
              text: text,
              filled: _boardFilled[i],
              hintedCells: _boardHintedCells[i],
              revealed: _revealed,
              selectedSlot: _selectedPuzzleIndex == i ? _selectedSlot : null,
              usedSlots: _usedSlotsFor(i),
              correct: _revealed ? _isCorrectFor(i) : null,
              onAccept: (r, c, slot) => _boardAccept(i, r, c, slot),
              onTapCell: (r, c) => _boardHandleCellTap(i, r, c),
              onDragRemove: (r, c) => _boardClearCell(i, r, c),
              onRemoveSlot: (slot) => _boardRemoveSlot(i, slot),
              onSelectSlot: (slot) => _boardSelectSlot(i, slot),
            ),
            const SizedBox(height: 12),
          ],
          FilledButton(
            onPressed: _committing
                ? null
                : _revealed
                ? _finishSession
                : (_boardAllFilled ? _boardReveal : null),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(
              _revealed
                  ? (_committing ? text.saving : text.finish)
                  : (_boardAllFilled ? text.checkAnswer : text.fillAll),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = AppText(widget.language);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.stage == null
              ? text.crosswordCounter(_index + 1, _total)
              : '${widget.stage!.title} - ${text.stageBoardWords(kCrosswordWordsPerStage)}',
        ),
      ),
      body: _isStageBoard
          ? _buildStageBoard(context, text)
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ClueLine(
                    label: text.horizontal,
                    meaning: _p.horizontal.meaningFor(widget.language),
                  ),
                  const SizedBox(height: 6),
                  _ClueLine(
                    label: text.vertical,
                    meaning: _p.vertical.meaningFor(widget.language),
                  ),
                  const SizedBox(height: 14),
                  _CrosswordStatus(
                    score: _score,
                    streak: _streak,
                    potential: _currentPotentialScore,
                    hintsUsed: _hintCount,
                    maxHints: 3,
                    text: text,
                    canHint: !_revealed && _hintCount < 3,
                    onHint: _useHint,
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: _Grid(
                      puzzle: _p,
                      filled: _filled,
                      hintedCells: _hintedCells,
                      revealed: _revealed,
                      selectedSlot: _selectedSlot,
                      onAccept: _accept,
                      onTapCell: _handleCellTap,
                      onDragRemove: _clearCell,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    text.dragLetters,
                    textAlign: TextAlign.center,
                    style: notoSansJp(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DragTarget<int>(
                    onWillAcceptWithDetails: (d) =>
                        !_revealed && _usedSlots.contains(d.data),
                    onAcceptWithDetails: (d) => _removeSlot(d.data),
                    builder: (context, candidate, rejected) {
                      final highlight = candidate.isNotEmpty;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: highlight
                              ? scheme.primaryContainer.withValues(alpha: 0.3)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: highlight
                                ? scheme.primary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (int i = 0; i < _p.pool.length; i++)
                              _PoolDraggable(
                                kanji: _p.pool[i],
                                slot: i,
                                used: _usedSlots.contains(i),
                                selected: _selectedSlot == i,
                                disabled: _revealed,
                                onTap: () => _selectSlot(i),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_revealed)
                    _ResultBanner(
                      correct: _isCorrect,
                      puzzle: _p,
                      text: text,
                    ).animate().fadeIn(duration: 250.ms),
                  if (_revealed) const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _committing
                        ? null
                        : _revealed
                        ? _next
                        : (_allFilled ? _reveal : null),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: Text(
                      _revealed
                          ? (_index >= _total - 1
                                ? (_committing ? text.saving : text.finish)
                                : text.next)
                          : (_allFilled ? text.checkAnswer : text.fillAll),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _BoardPuzzleCard extends StatelessWidget {
  final int number;
  final CrosswordPuzzle puzzle;
  final StudyLanguage language;
  final AppText text;
  final Map<String, int> filled;
  final Set<String> hintedCells;
  final bool revealed;
  final int? selectedSlot;
  final Set<int> usedSlots;
  final bool? correct;
  final void Function(int r, int c, int slot) onAccept;
  final void Function(int r, int c) onTapCell;
  final void Function(int r, int c) onDragRemove;
  final void Function(int slot) onRemoveSlot;
  final void Function(int slot) onSelectSlot;

  const _BoardPuzzleCard({
    required this.number,
    required this.puzzle,
    required this.language,
    required this.text,
    required this.filled,
    required this.hintedCells,
    required this.revealed,
    required this.selectedSlot,
    required this.usedSlots,
    required this.correct,
    required this.onAccept,
    required this.onTapCell,
    required this.onDragRemove,
    required this.onRemoveSlot,
    required this.onSelectSlot,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final borderColor = correct == null
        ? scheme.outlineVariant
        : correct!
        ? AppTheme.correctBorder
        : scheme.error;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: correct == null ? 1 : 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$number',
                  style: notoSerifJp(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${text.horizontal}: ${puzzle.horizontal.meaningFor(language)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: notoSansJp(fontSize: 11, color: scheme.onSurface),
                ),
              ),
              if (correct != null)
                Icon(
                  correct! ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 18,
                  color: correct! ? AppTheme.correctFg : scheme.error,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Text(
              '${text.vertical}: ${puzzle.vertical.meaningFor(language)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: notoSansJp(fontSize: 11, color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: _Grid(
              puzzle: puzzle,
              filled: filled,
              hintedCells: hintedCells,
              revealed: revealed,
              selectedSlot: selectedSlot,
              cellSize: 46,
              gap: 4,
              onAccept: onAccept,
              onTapCell: onTapCell,
              onDragRemove: onDragRemove,
            ),
          ),
          const SizedBox(height: 10),
          DragTarget<int>(
            onWillAcceptWithDetails: (d) =>
                !revealed && usedSlots.contains(d.data),
            onAcceptWithDetails: (d) => onRemoveSlot(d.data),
            builder: (context, candidate, rejected) {
              return Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (int i = 0; i < puzzle.pool.length; i++)
                    _PoolDraggable(
                      kanji: puzzle.pool[i],
                      slot: i,
                      used: usedSlots.contains(i),
                      selected: selectedSlot == i,
                      disabled: revealed,
                      compact: true,
                      onTap: () => onSelectSlot(i),
                    ),
                ],
              );
            },
          ),
        ],
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

class _CrosswordStatus extends StatelessWidget {
  final int score;
  final int streak;
  final int potential;
  final int hintsUsed;
  final int maxHints;
  final AppText text;
  final bool canHint;
  final VoidCallback onHint;

  const _CrosswordStatus({
    required this.score,
    required this.streak,
    required this.potential,
    required this.hintsUsed,
    required this.maxHints,
    required this.text,
    required this.canHint,
    required this.onHint,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          _MiniMetric(label: text.score, value: '$score'),
          const SizedBox(width: 12),
          _MiniMetric(label: text.combo, value: 'x$streak'),
          const SizedBox(width: 12),
          _MiniMetric(label: text.thisPuzzle, value: '+$potential'),
          const Spacer(),
          TextButton.icon(
            onPressed: canHint ? onHint : null,
            icon: const Icon(Icons.lightbulb_outline_rounded, size: 18),
            label: Text(text.hintCount(hintsUsed, maxHints)),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;

  const _MiniMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: notoSansJp(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: notoSerifJp(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _SessionStatRow extends StatelessWidget {
  final int score;
  final int correct;
  final int total;
  final int bestStreak;
  final AppText text;

  const _SessionStatRow({
    required this.score,
    required this.correct,
    required this.total,
    required this.bestStreak,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ResultMetric(label: text.score, value: '$score'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ResultMetric(label: text.solved, value: '$correct/$total'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ResultMetric(label: text.best, value: 'x$bestStreak'),
        ),
      ],
    );
  }
}

class _ResultMetric extends StatelessWidget {
  final String label;
  final String value;

  const _ResultMetric({required this.label, required this.value});

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
          const SizedBox(height: 4),
          Text(
            value,
            style: notoSerifJp(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  final CrosswordPuzzle puzzle;
  final Map<String, int> filled;
  final Set<String> hintedCells;
  final bool revealed;
  final int? selectedSlot;
  final double cellSize;
  final double gap;
  final void Function(int r, int c, int slot) onAccept;
  final void Function(int r, int c) onTapCell;
  final void Function(int r, int c) onDragRemove;

  const _Grid({
    required this.puzzle,
    required this.filled,
    required this.hintedCells,
    required this.revealed,
    required this.selectedSlot,
    this.cellSize = 62,
    this.gap = 6,
    required this.onAccept,
    required this.onTapCell,
    required this.onDragRemove,
  });

  @override
  Widget build(BuildContext context) {
    final totalSize = 4 * cellSize + 3 * gap;
    return SizedBox(
      width: totalSize,
      height: totalSize,
      child: Column(
        children: [
          for (int r = 0; r < 4; r++) ...[
            if (r > 0) SizedBox(height: gap),
            SizedBox(
              height: cellSize,
              child: Row(
                children: [
                  for (int c = 0; c < 4; c++) ...[
                    if (c > 0) SizedBox(width: gap),
                    _Cell(
                      size: cellSize,
                      puzzle: puzzle,
                      r: r,
                      c: c,
                      filledSlot: filled['$r,$c'],
                      hinted: hintedCells.contains('$r,$c'),
                      revealed: revealed,
                      selectedSlot: selectedSlot,
                      onAccept: (slot) => onAccept(r, c, slot),
                      onTapCell: () => onTapCell(r, c),
                      onDragRemove: () => onDragRemove(r, c),
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
  final bool hinted;
  final bool revealed;
  final int? selectedSlot;
  final void Function(int slot) onAccept;
  final VoidCallback onTapCell;
  final VoidCallback onDragRemove;

  const _Cell({
    required this.size,
    required this.puzzle,
    required this.r,
    required this.c,
    required this.filledSlot,
    required this.hinted,
    required this.revealed,
    required this.selectedSlot,
    required this.onAccept,
    required this.onTapCell,
    required this.onDragRemove,
  });

  @override
  State<_Cell> createState() => _CellState();
}

class _CellState extends State<_Cell> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = widget.puzzle.isCellActive(widget.r, widget.c);
    if (!active) {
      return SizedBox(width: widget.size, height: widget.size);
    }

    final slot = widget.filledSlot;
    final fixed = widget.puzzle.isSharedCell(widget.r, widget.c);
    final kanji = fixed
        ? widget.puzzle.sharedChar
        : slot == null
        ? null
        : widget.puzzle.pool[slot];

    Color bg = scheme.surface;
    Color border = scheme.outlineVariant;
    Color textColor = scheme.onSurface;
    double borderWidth = 1.2;

    if (widget.revealed) {
      final expected = widget.puzzle.expectedAt(widget.r, widget.c);
      final correct = kanji == expected;
      bg = correct ? AppTheme.correctBg : scheme.errorContainer;
      border = correct ? AppTheme.correctBorder : scheme.error;
      textColor = correct ? AppTheme.correctFg : scheme.onErrorContainer;
    } else if (fixed) {
      bg = scheme.primaryContainer;
      border = scheme.primary;
      textColor = scheme.onPrimaryContainer;
      borderWidth = 1.8;
    } else if (widget.hinted) {
      bg = scheme.tertiaryContainer.withValues(alpha: 0.7);
      border = scheme.tertiary;
      textColor = scheme.onTertiaryContainer;
      borderWidth = 1.8;
    } else if (_hovering) {
      bg = scheme.primaryContainer.withValues(alpha: 0.4);
      border = scheme.primary;
      borderWidth = 2;
    } else if (widget.selectedSlot != null && kanji == null) {
      bg = scheme.primaryContainer.withValues(alpha: 0.24);
      border = scheme.primary.withValues(alpha: 0.7);
    } else if (kanji == null) {
      bg = scheme.surfaceContainerHighest;
    }

    return DragTarget<int>(
      onWillAcceptWithDetails: (_) {
        if (widget.revealed || fixed) return false;
        setState(() => _hovering = true);
        return true;
      },
      onLeave: (_) => setState(() => _hovering = false),
      onAcceptWithDetails: (d) {
        setState(() => _hovering = false);
        widget.onAccept(d.data);
      },
      builder: (context, candidate, rejected) {
        final cellBox = Container(
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
              fontSize: widget.size * 0.48,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        );

        Widget inner = cellBox;
        if (slot != null && !widget.revealed && !fixed) {
          inner = Draggable<int>(
            data: slot,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: Material(
              color: Colors.transparent,
              child: Transform.translate(
                offset: const Offset(-24, -27),
                child: _PoolChip(
                  kanji: kanji ?? '',
                  used: false,
                  disabled: false,
                  dragging: true,
                ),
              ),
            ),
            childWhenDragging: Opacity(opacity: 0.35, child: cellBox),
            onDraggableCanceled: (_, _) {
              widget.onDragRemove();
            },
            child: cellBox,
          );
        }

        return GestureDetector(
          onTap: !widget.revealed && !fixed ? widget.onTapCell : null,
          child: inner,
        );
      },
    );
  }
}

class _PoolDraggable extends StatelessWidget {
  final String kanji;
  final int slot;
  final bool used;
  final bool selected;
  final bool disabled;
  final bool compact;
  final VoidCallback onTap;

  const _PoolDraggable({
    required this.kanji,
    required this.slot,
    required this.used,
    required this.selected,
    required this.disabled,
    this.compact = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chip = GestureDetector(
      onTap: used || disabled ? null : onTap,
      child: _PoolChip(
        kanji: kanji,
        used: used,
        selected: selected,
        disabled: disabled,
        compact: compact,
      ),
    );
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
            selected: false,
            disabled: false,
            dragging: true,
            compact: compact,
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: chip),
      child: chip,
    );
  }
}

class _PoolChip extends StatelessWidget {
  final String kanji;
  final bool used;
  final bool selected;
  final bool disabled;
  final bool dragging;
  final bool compact;
  const _PoolChip({
    required this.kanji,
    required this.used,
    this.selected = false,
    required this.disabled,
    this.dragging = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = dragging
        ? scheme.primaryContainer
        : selected
        ? scheme.primaryContainer
        : used
        ? scheme.surfaceContainerHigh
        : scheme.surface;
    final textColor = used
        ? scheme.onSurfaceVariant.withValues(alpha: 0.4)
        : dragging || selected
        ? scheme.onPrimaryContainer
        : scheme.onSurface;
    return Opacity(
      opacity: disabled ? 0.7 : 1,
      child: Container(
        width: compact ? 38 : 48,
        height: compact ? 42 : 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: used
                ? scheme.outlineVariant.withValues(alpha: 0.5)
                : selected
                ? scheme.primary
                : scheme.primary,
            width: selected ? 2.4 : 1.5,
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
            fontSize: compact ? 21 : 26,
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
  final AppText text;
  const _ResultBanner({
    required this.correct,
    required this.puzzle,
    required this.text,
  });

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
                correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: correct ? AppTheme.correctFg : scheme.onErrorContainer,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                correct ? text.correct : text.incorrect,
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
            '${text.horizontal}: ${puzzle.horizontal.idiom} (${puzzle.horizontal.reading})',
            style: notoSansJp(
              fontSize: 13,
              color: correct
                  ? scheme.onPrimaryContainer
                  : scheme.onErrorContainer,
            ),
          ),
          Text(
            '${text.vertical}: ${puzzle.vertical.idiom} (${puzzle.vertical.reading})',
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
