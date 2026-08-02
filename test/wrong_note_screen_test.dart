import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idioms_quiz/data/rank.dart';
import 'package:idioms_quiz/data/score_service.dart';
import 'package:idioms_quiz/models/idiom.dart';
import 'package:idioms_quiz/screens/wrong_note_screen.dart';

void main() {
  testWidgets('wrong-note word exposes pronunciation and expands its example', (
    tester,
  ) async {
    const idiom = Idiom(
      spanish: 'hola',
      pronunciation: 'hola',
      meanings: {
        StudyLanguage.ko: '안녕',
        StudyLanguage.en: 'hello',
        StudyLanguage.ja: 'こんにちは',
      },
      example: '¡Hola! ¿Cómo estás?',
      exampleMeanings: {
        StudyLanguage.ko: '안녕! 어떻게 지내?',
        StudyLanguage.en: 'Hello! How are you?',
        StudyLanguage.ja: 'こんにちは！元気ですか？',
      },
      blankedExample: '¡____! ¿Cómo estás?',
      answer: 'Hola',
      level: 'A1',
      theme: 'greetings',
      partOfSpeech: 'phrase',
      wrongChoices: [],
      difficulty: 1,
    );
    final snapshot = ScoreSnapshot(
      points: 0,
      totalAnswered: 1,
      totalCorrect: 0,
      bestStreak: 0,
      rank: ranks.first,
      next: null,
      progress: 0,
      level: 1,
      remainingToNextLevel: 10,
      levelProgress: 0,
      hints: {},
      mastered: {},
      wrongIdioms: {'hola'},
      correctCounts: {},
      bestMarathonScore: 0,
      bestMarathonTotal: 0,
      lastMarathonScore: 0,
      lastMarathonTotal: 0,
      roundStars: {},
      studyStreakDays: 0,
      lastStudyDate: '',
      equippedTitleId: '',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: WrongNoteScreen(
          idioms: const [idiom],
          language: StudyLanguage.ko,
          snap: snapshot,
        ),
      ),
    );

    expect(find.byKey(const ValueKey('wrong_note_speak_hola')), findsOneWidget);
    expect(find.text('¡Hola! ¿Cómo estás?'), findsNothing);

    await tester.tap(find.text('hola'));
    await tester.pumpAndSettle();

    expect(find.text('¡Hola! ¿Cómo estás?'), findsOneWidget);
    expect(find.text('안녕! 어떻게 지내?'), findsOneWidget);
  });
}
