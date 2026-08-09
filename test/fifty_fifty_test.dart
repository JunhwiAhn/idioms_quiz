import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idioms_quiz/data/quiz_session.dart';
import 'package:idioms_quiz/data/score_service.dart';
import 'package:idioms_quiz/models/idiom.dart';
import 'package:idioms_quiz/screens/quiz_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Idiom _idiom(String word, String meaning) => Idiom.fromJson({
  'idiom': word,
  'pronunciation': word,
  'meaning_ko': meaning,
  'meaning_en': meaning,
  'meaning_ja': meaning,
  'level': 'A1',
  'example': 'El gato tiene una $word larga.',
  'example_ko': '예문 번역',
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    '50:50 hint eliminates two wrong choices on wordLookup question',
    (tester) async {
      SharedPreferences.setMockInitialValues({'hint_5050': 2, 'hint_time': 2});

      final question = QuizQuestion(
        idiom: _idiom('cola', '꼬리'),
        mode: QuizMode.wordLookup,
        maskedIndices: const [],
        choices: const ['cola', 'perro', 'gato', 'casa'],
        correctIndex: 0,
        readingOf: const {},
        language: StudyLanguage.ko,
      );
      final session = QuizSession(questions: [question], seed: 1);

      await tester.pumpWidget(
        MaterialApp(
          home: QuizScreen(
            session: session,
            initialHints: const {
              HintKind.fiftyFifty: 2,
              HintKind.reading: 0,
              HintKind.time: 2,
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      final fiftyFifty = find.text('50:50');
      expect(fiftyFifty, findsOneWidget);

      await tester.tap(fiftyFifty);
      await tester.pump(const Duration(milliseconds: 500));

      // Two wrong choices should now be dimmed to opacity 0.35.
      final dimmed = tester
          .widgetList<Opacity>(find.byType(Opacity))
          .where((w) => w.opacity == 0.35)
          .length;
      expect(
        dimmed,
        2,
        reason: '50:50 should eliminate exactly 2 wrong choices',
      );
    },
  );
}
