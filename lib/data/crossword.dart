import 'dart:math';
import '../models/idiom.dart';

const int kCrosswordStageCount = 20;
const int kCrosswordPuzzlesPerStage = 12;
const int kCrosswordWordsPerStage = kCrosswordPuzzlesPerStage * 2;

class CrosswordStageSpec {
  final int index;
  final String level;
  final int targetDifficulty;

  const CrosswordStageSpec({
    required this.index,
    required this.level,
    required this.targetDifficulty,
  });

  String get title => 'Puzzle ${index + 1}';
  String get levelLabel => 'DELE $level';
}

/// A compact crossword puzzle consisting of two 4-letter Spanish words that
/// share exactly one letter. Laid out on a 4×4 grid.
class CrosswordPuzzle {
  final Idiom horizontal;
  final Idiom vertical;
  final int hSharedIndex; // index in horizontal word of shared letter
  final int vSharedIndex; // index in vertical word of shared letter
  final List<String> pool; // letter choices for fillable cells (shuffled)

  const CrosswordPuzzle({
    required this.horizontal,
    required this.vertical,
    required this.hSharedIndex,
    required this.vSharedIndex,
    required this.pool,
  });

  String get sharedChar => horizontal.idiom[hSharedIndex];

  int get gridRow => vSharedIndex;
  int get gridCol => hSharedIndex;
  bool isSharedCell(int r, int c) => r == gridRow && c == gridCol;

  bool isHorizontalCell(int r, int c) => r == gridRow;
  bool isVerticalCell(int r, int c) => c == gridCol;
  bool isCellActive(int r, int c) =>
      isHorizontalCell(r, c) || isVerticalCell(r, c);

  /// Expected letter at (r,c). Must be an active cell.
  String expectedAt(int r, int c) {
    if (r == gridRow) return horizontal.idiom[c];
    if (c == gridCol) return vertical.idiom[r];
    throw StateError('inactive cell ($r,$c)');
  }

  /// Ordered list of all 7 active cells.
  List<(int, int)> get activeCells {
    final cells = <(int, int)>[];
    for (int c = 0; c < 4; c++) {
      cells.add((gridRow, c));
    }
    for (int r = 0; r < 4; r++) {
      if (r != gridRow) cells.add((r, gridCol));
    }
    return cells;
  }

  List<(int, int)> get fillableCells =>
      activeCells.where((cell) => !isSharedCell(cell.$1, cell.$2)).toList();
}

class CrosswordBank {
  /// Precomputed list of valid pairs (a, b, hIdx, vIdx) where a and b share
  /// exactly one letter.
  final List<_PairRef> _pairs;
  final List<Idiom> _pool;
  CrosswordBank._(this._pairs, this._pool);

  int get pairCount => _pairs.length;

  CrosswordStageSpec stageSpec(int index) {
    final safe = index.clamp(0, kCrosswordStageCount - 1).toInt();
    final level = switch (safe ~/ 4) {
      0 => 'A1',
      1 => 'A2',
      2 => 'B1',
      3 => 'B2',
      _ => 'C1',
    };
    return CrosswordStageSpec(
      index: safe,
      level: level,
      targetDifficulty: 1 + (safe * 4 ~/ kCrosswordStageCount),
    );
  }

  static CrosswordBank build(List<Idiom> pool) {
    final crosswordPool =
        pool.where((entry) => entry.idiom.split('').length == 4).toList();
    final pairs = <_PairRef>[];
    for (int i = 0; i < crosswordPool.length; i++) {
      final a = crosswordPool[i];
      final aChars = a.idiom.split('');
      final aSet = aChars.toSet();
      for (int j = i + 1; j < crosswordPool.length; j++) {
        final b = crosswordPool[j];
        final bChars = b.idiom.split('');
        final bSet = bChars.toSet();
        final shared = aSet.intersection(bSet);
        if (shared.length != 1) continue;
        final shared0 = shared.first;
        final aIdx = aChars.indexOf(shared0);
        final bIdx = bChars.indexOf(shared0);
        pairs.add(_PairRef(i, j, aIdx, bIdx));
      }
    }
    return CrosswordBank._(pairs, crosswordPool);
  }

  /// Build N random puzzles.
  List<CrosswordPuzzle> samplePuzzles(int n, {int? seed}) {
    final rng = Random(seed);
    final indices = List<int>.generate(_pairs.length, (i) => i)..shuffle(rng);
    final picked = indices.take(n).toList();
    return picked.map((i) => _buildPuzzle(_pairs[i], rng)).toList();
  }

  List<CrosswordPuzzle> sampleStagePuzzles(
    int stageIndex, {
    int count = kCrosswordPuzzlesPerStage,
    int? seed,
  }) {
    final spec = stageSpec(stageIndex);
    final rng = Random(seed ?? DateTime.now().microsecondsSinceEpoch);
    final ranked = List<_PairRef>.from(_pairs)
      ..sort((a, b) {
        final aDelta = (_pairScore(a) - spec.targetDifficulty).abs();
        final bDelta = (_pairScore(b) - spec.targetDifficulty).abs();
        if (aDelta != bDelta) return aDelta.compareTo(bDelta);
        return _pairScore(a).compareTo(_pairScore(b));
      });

    final windowSize = max(count * 5, 60).clamp(count, ranked.length).toInt();
    final window = ranked.take(windowSize).toList()..shuffle(rng);
    final picked = window.take(count).toList()
      ..sort((a, b) => _pairScore(a).compareTo(_pairScore(b)));
    return picked.map((p) => _buildPuzzle(p, rng)).toList();
  }

  double _pairScore(_PairRef p) {
    final a = _pool[p.a];
    final b = _pool[p.b];
    return (a.difficulty + b.difficulty) / 2;
  }

  CrosswordPuzzle _buildPuzzle(_PairRef p, Random rng) {
    final h = _pool[p.a];
    final v = _pool[p.b];
    final letters = <String>[];
    final hChars = h.idiom.split('');
    final vChars = v.idiom.split('');
    for (int i = 0; i < hChars.length; i++) {
      if (i != p.aIdx) letters.add(hChars[i]);
    }
    for (int i = 0; i < vChars.length; i++) {
      if (i != p.bIdx) letters.add(vChars[i]);
    }
    // Two distractor letters sampled from other words.
    final distractorPool = <String>{};
    for (final other in _pool) {
      if (other.idiom == h.idiom || other.idiom == v.idiom) continue;
      distractorPool.addAll(other.idiom.split(''));
    }
    distractorPool.removeAll(letters.toSet());
    final distractorList = distractorPool.toList()..shuffle(rng);
    final distractors = distractorList.take(2).toList();
    final pool = [...letters, ...distractors]..shuffle(rng);
    return CrosswordPuzzle(
      horizontal: h,
      vertical: v,
      hSharedIndex: p.aIdx,
      vSharedIndex: p.bIdx,
      pool: pool,
    );
  }
}

class _PairRef {
  final int a; // index in pool
  final int b;
  final int aIdx; // shared index in idiom a
  final int bIdx;
  const _PairRef(this.a, this.b, this.aIdx, this.bIdx);
}
