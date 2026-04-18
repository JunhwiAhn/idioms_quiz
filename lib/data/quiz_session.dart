import 'dart:math';
import '../models/idiom.dart';

class QuizQuestion {
  final Idiom idiom;
  final List<String> choices;
  final int correctIndex;

  const QuizQuestion({
    required this.idiom,
    required this.choices,
    required this.correctIndex,
  });
}

class QuizSession {
  final List<QuizQuestion> questions;
  int currentIndex = 0;
  int correctCount = 0;
  int _currentStreak = 0;
  int longestStreak = 0;

  QuizSession(this.questions);

  bool get isFinished => currentIndex >= questions.length;
  QuizQuestion get current => questions[currentIndex];

  void submit(int pickedIndex) {
    if (pickedIndex == current.correctIndex) {
      correctCount++;
      _currentStreak++;
      if (_currentStreak > longestStreak) longestStreak = _currentStreak;
    } else {
      _currentStreak = 0;
    }
    currentIndex++;
  }

  static QuizSession build(List<Idiom> pool, {int count = 10, int? seed}) {
    final rng = Random(seed);
    final shuffled = [...pool]..shuffle(rng);
    final picked = shuffled.take(count).toList();
    final questions = picked.map((idiom) {
      final options = [idiom.meaning, ...idiom.wrongChoices]..shuffle(rng);
      final correctIndex = options.indexOf(idiom.meaning);
      return QuizQuestion(
        idiom: idiom,
        choices: options,
        correctIndex: correctIndex,
      );
    }).toList(growable: false);
    return QuizSession(questions);
  }
}
