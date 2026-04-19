import 'dart:math';
import '../models/idiom.dart';
import 'score_service.dart' show HintKind;

enum QuizMode { normal, fillBlank, noReading, reverseLookup }

extension QuizModeX on QuizMode {
  String get label => switch (this) {
        QuizMode.normal => 'ふつう',
        QuizMode.fillBlank => '穴埋め',
        QuizMode.noReading => '読みなし',
        QuizMode.reverseLookup => '意味先出し',
      };

  String get description => switch (this) {
        QuizMode.normal => '漢字とふりがなを見て意味を選ぶ。',
        QuizMode.fillBlank => '漢字の一部が伏せられる。ふりがなは表示。',
        QuizMode.noReading => 'ふりがな無し。漢字だけで意味を選ぶ。',
        QuizMode.reverseLookup => '意味を見て該当する四字熟語を当てる。',
      };
}

class QuizQuestion {
  final Idiom idiom;
  final QuizMode mode;
  final List<int> maskedIndices; // for fillBlank
  final List<String> choices;
  final int correctIndex;

  /// For reverseLookup choices carry the *reading* alongside the kanji,
  /// looked up from this map to render properly.
  final Map<String, String> readingOf;

  const QuizQuestion({
    required this.idiom,
    required this.mode,
    required this.maskedIndices,
    required this.choices,
    required this.correctIndex,
    required this.readingOf,
  });
}

/// Chance of dropping a hint on a correct answer.
const double kHintDropChance = 0.20;

class SubmitResult {
  final bool correct;
  final HintKind? droppedHint;
  const SubmitResult({required this.correct, required this.droppedHint});
}

class QuizSession {
  final List<QuizQuestion> questions;
  int currentIndex = 0;
  int correctCount = 0;
  int _currentStreak = 0;
  int longestStreak = 0;
  final List<String> correctIdioms = [];
  final List<HintKind> droppedHints = [];
  final Random _rng;

  QuizSession({required this.questions, int? seed})
      : _rng = Random(seed);

  bool get isFinished => currentIndex >= questions.length;
  QuizQuestion get current => questions[currentIndex];

  SubmitResult submit(int pickedIndex) {
    final correct = pickedIndex == current.correctIndex;
    HintKind? drop;
    if (correct) {
      correctCount++;
      correctIdioms.add(current.idiom.idiom);
      _currentStreak++;
      if (_currentStreak > longestStreak) longestStreak = _currentStreak;
      if (_rng.nextDouble() < kHintDropChance) {
        final kinds = HintKind.values;
        drop = kinds[_rng.nextInt(kinds.length)];
        droppedHints.add(drop);
      }
    } else {
      _currentStreak = 0;
    }
    return SubmitResult(correct: correct, droppedHint: drop);
  }

  void advance() {
    currentIndex++;
  }

  static QuizSession build(
    List<Idiom> pool, {
    int count = 10,
    int? seed,
  }) {
    final rng = Random(seed);
    final shuffled = [...pool]..shuffle(rng);
    final picked = shuffled.take(count).toList();
    final modes = QuizMode.values;

    final questions = picked.map((idiom) {
      final mode = modes[rng.nextInt(modes.length)];

      List<String> choices;
      int correctIndex;
      final masked = <int>[];
      final readings = <String, String>{};

      if (mode == QuizMode.reverseLookup) {
        final others = [...pool.where((x) => x.idiom != idiom.idiom)]
          ..shuffle(rng);
        final distractors = others.take(3).toList();
        choices = [idiom.idiom, ...distractors.map((e) => e.idiom)]
          ..shuffle(rng);
        correctIndex = choices.indexOf(idiom.idiom);
        readings[idiom.idiom] = idiom.reading;
        for (final d in distractors) {
          readings[d.idiom] = d.reading;
        }
      } else {
        final opts = [idiom.meaning, ...idiom.wrongChoices]..shuffle(rng);
        choices = opts;
        correctIndex = choices.indexOf(idiom.meaning);

        if (mode == QuizMode.fillBlank) {
          final len = idiom.idiom.length;
          // Hide 1 char usually, 2 chars ~30% of the time for added difficulty.
          final hideCount = rng.nextDouble() < 0.3 ? 2 : 1;
          final indices = List<int>.generate(len, (i) => i)..shuffle(rng);
          masked.addAll(indices.take(hideCount));
          masked.sort();
        }
      }

      return QuizQuestion(
        idiom: idiom,
        mode: mode,
        maskedIndices: masked,
        choices: choices,
        correctIndex: correctIndex,
        readingOf: readings,
      );
    }).toList(growable: false);

    return QuizSession(questions: questions);
  }
}
