import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:idioms_quiz/models/idiom.dart';
import 'package:idioms_quiz/screens/word_slide_screen.dart';
import 'package:idioms_quiz/theme/app_theme.dart';

void main() {
  const first = Idiom(
    spanish: 'casa',
    pronunciation: 'casa',
    meanings: {
      StudyLanguage.ko: '집',
      StudyLanguage.en: 'house',
      StudyLanguage.ja: '家',
      StudyLanguage.pt: 'casa',
    },
    example: 'La casa es grande.',
    exampleMeanings: {StudyLanguage.ko: '그 집은 큽니다.'},
    blankedExample: 'La ____ es grande.',
    answer: 'casa',
    level: 'A1',
    theme: 'home',
    partOfSpeech: 'noun',
    wrongChoices: [],
    difficulty: 1,
  );
  const second = Idiom(
    spanish: 'libro',
    pronunciation: 'libro',
    meanings: {
      StudyLanguage.ko: '책',
      StudyLanguage.en: 'book',
      StudyLanguage.ja: '本',
      StudyLanguage.pt: 'livro',
    },
    example: 'Leo un libro.',
    exampleMeanings: {StudyLanguage.ko: '나는 책을 읽습니다.'},
    blankedExample: 'Leo un ____.',
    answer: 'libro',
    level: 'A1',
    theme: 'study',
    partOfSpeech: 'noun',
    wrongChoices: [],
    difficulty: 1,
  );

  testWidgets('shows a word and its example from the start', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: WordSlideScreen(
          idioms: const [first, second],
          language: StudyLanguage.ko,
        ),
      ),
    );

    expect(find.text('쉐도잉'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);
    expect(find.text('casa'), findsOneWidget);
    expect(find.text('집'), findsOneWidget);
    expect(find.text('La casa es grande.'), findsOneWidget);
    expect(find.text('그 집은 큽니다.'), findsOneWidget);
    expect(find.text('광고 보고 자동재생'), findsOneWidget);
    expect(find.byTooltip('쉐도잉 설정'), findsOneWidget);
  });

  testWidgets('moves between slides with the navigation controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: WordSlideScreen(
          idioms: const [first, second],
          language: StudyLanguage.ko,
        ),
      ),
    );

    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();

    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.text('libro'), findsOneWidget);
    expect(find.text('책'), findsOneWidget);
    expect(find.text('완료'), findsOneWidget);
  });
}
