import 'dart:math';
import '../models/idiom.dart';
import 'score_service.dart' show HintKind;

enum QuizMode { translationLookup, wordLookup, sentenceBlank }

extension QuizModeX on QuizMode {
  String get label => switch (this) {
        QuizMode.translationLookup => 'Meaning',
        QuizMode.wordLookup => 'Word',
        QuizMode.sentenceBlank => 'Blank',
      };

  String get description => switch (this) {
        QuizMode.translationLookup => 'Choose the translation for the Spanish word.',
        QuizMode.wordLookup => 'Choose the Spanish word from the translation.',
        QuizMode.sentenceBlank => 'Fill the blank in the example sentence.',
      };
}

class QuizQuestion {
  final Idiom idiom;
  final QuizMode mode;
  final List<int> maskedIndices; // reserved for future typed blanks
  final List<String> choices;
  final int correctIndex;

  /// For word lookup choices carry the pronunciation alongside the Spanish,
  /// looked up from this map to render properly.
  final Map<String, String> readingOf;
  final StudyLanguage language;

  const QuizQuestion({
    required this.idiom,
    required this.mode,
    required this.maskedIndices,
    required this.choices,
    required this.correctIndex,
    required this.readingOf,
    required this.language,
  });

  String get promptMeaning => idiom.meaningFor(language);
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
    StudyLanguage language = StudyLanguage.ko,
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

      if (mode == QuizMode.wordLookup) {
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
      } else if (mode == QuizMode.sentenceBlank) {
        final others = [...pool.where((x) => x.answer != idiom.answer)]
          ..shuffle(rng);
        final distractors = others.map((e) => e.answer).take(3).toList();
        choices = [idiom.answer, ...distractors]..shuffle(rng);
        correctIndex = choices.indexOf(idiom.answer);
      } else {
        final others = [...pool.where((x) => x.idiom != idiom.idiom)]
          ..shuffle(rng);
        final distractors =
            others.map((e) => e.meaningFor(language)).take(3).toList();
        choices = [idiom.meaningFor(language), ...distractors]..shuffle(rng);
        correctIndex = choices.indexOf(idiom.meaningFor(language));
      }

      return QuizQuestion(
        idiom: idiom,
        mode: mode,
        maskedIndices: masked,
        choices: choices,
        correctIndex: correctIndex,
        readingOf: readings,
        language: language,
      );
    }).toList(growable: false);

    return QuizSession(questions: questions);
  }
}
