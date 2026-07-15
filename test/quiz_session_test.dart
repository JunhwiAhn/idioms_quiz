import 'package:flutter_test/flutter_test.dart';
import 'package:idioms_quiz/data/quiz_session.dart';
import 'package:idioms_quiz/models/idiom.dart';

void main() {
  test('quiz generation skips entries that would render blank prompts', () {
    final session = QuizSession.build(
      [
        _idiom('hoy', ''),
        _idiom('casa', '집', example: 'Mi casa está cerca del parque.'),
        _idiom('escuela', '학교', example: 'Los niños van a la escuela.'),
        _idiom('agua', '물', example: 'Bebo agua después de correr.'),
        _idiom('libro', '책', example: 'Leo un libro en casa.'),
        _idiom('amigo', '친구', example: 'Carlos es mi amigo.'),
      ],
      count: 6,
      seed: 7,
      language: StudyLanguage.ko,
    );

    expect(session.questions, isNotEmpty);
    for (final question in session.questions) {
      expect(question.choices, hasLength(4));
      expect(
        question.choices.every((choice) => choice.trim().isNotEmpty),
        true,
      );
      expect(question.correctIndex, inInclusiveRange(0, 3));
      switch (question.mode) {
        case QuizMode.wordLookup:
          expect(question.idiom.meaningFor(question.language), isNotEmpty);
        case QuizMode.translationLookup:
          expect(question.idiom.idiom, isNotEmpty);
        case QuizMode.sentenceBlank:
          expect(question.idiom.hasUsableExample, true);
      }
    }
    expect(session.questions.any((q) => q.idiom.idiom == 'hoy'), false);
  });

  test('quiz generation avoids near-synonym multiple-answer choices', () {
    final pool = [
      _idiom('día', '일', enMeaning: 'day'),
      _idiom('jornada', '일', enMeaning: 'day'),
      _idiom('trabajo', '일', enMeaning: 'work'),
      _idiom('casa', '집', enMeaning: 'house'),
      _idiom('escuela', '학교', enMeaning: 'school'),
      _idiom('agua', '물', enMeaning: 'water'),
      _idiom('libro', '책', enMeaning: 'book'),
      _idiom('amigo', '친구', enMeaning: 'friend'),
      _idiom('ciudad', '도시', enMeaning: 'city'),
    ];

    for (var seed = 0; seed < 80; seed += 1) {
      final session = QuizSession.build(
        pool,
        count: 9,
        seed: seed,
        language: StudyLanguage.ko,
      );
      for (final question in session.questions) {
        if (question.mode == QuizMode.wordLookup) {
          final choices = question.choices.toSet();
          if (choices.contains('día')) {
            expect(choices.contains('jornada'), false);
            expect(choices.contains('trabajo'), false);
          }
          if (choices.contains('jornada')) {
            expect(choices.contains('día'), false);
            expect(choices.contains('trabajo'), false);
          }
        }
      }
    }
  });

  test('quiz generation skips demonstrative time phrase fragments', () {
    final session = QuizSession.build(
      [
        _idiom('esta tarde', '오늘 오후', enMeaning: 'this afternoon'),
        _idiom('esta mañana', '오늘 아침', enMeaning: 'this morning'),
        _idiom('este mes', '이번 달', enMeaning: 'this month'),
        _idiom('tarde', '오후', enMeaning: 'afternoon'),
        _idiom('mañana', '아침', enMeaning: 'morning'),
        _idiom('mes', '달', enMeaning: 'month'),
        _idiom('casa', '집', enMeaning: 'house'),
        _idiom('escuela', '학교', enMeaning: 'school'),
        _idiom('agua', '물', enMeaning: 'water'),
        _idiom('libro', '책', enMeaning: 'book'),
      ],
      count: 10,
      seed: 11,
      language: StudyLanguage.ko,
    );

    const blocked = {'esta tarde', 'esta mañana', 'este mes'};
    for (final question in session.questions) {
      expect(blocked.contains(question.idiom.idiom), false);
      expect(question.choices.any(blocked.contains), false);
    }
  });

  test('same seed is deterministic and does not mutate the input pool', () {
    final pool = _quizPool(12);
    final originalOrder = List<Idiom>.of(pool);

    final first = QuizSession.build(
      pool,
      count: 10,
      seed: 2026,
      language: StudyLanguage.ko,
    );
    final second = QuizSession.build(
      pool,
      count: 10,
      seed: 2026,
      language: StudyLanguage.ko,
    );

    expect(pool, orderedEquals(originalOrder));
    expect(_questionSignature(first), equals(_questionSignature(second)));
  });

  test('optimized generation preserves choice invariants in every mode', () {
    final pool = _quizPool(12);
    final seenModes = <QuizMode>{};

    for (var seed = 0; seed < 30; seed++) {
      final session = QuizSession.build(
        pool,
        count: pool.length,
        seed: seed,
        language: StudyLanguage.ko,
      );

      expect(session.questions, hasLength(pool.length));
      expect(
        session.questions.map((question) => question.idiom).toSet(),
        hasLength(pool.length),
      );

      for (final question in session.questions) {
        seenModes.add(question.mode);
        expect(question.choices, hasLength(4));
        expect(question.choices.map(_choiceKeyForTest).toSet(), hasLength(4));
        final expectedAnswer = switch (question.mode) {
          QuizMode.wordLookup => question.idiom.idiom.trim(),
          QuizMode.translationLookup =>
            question.idiom.meaningFor(question.language).trim(),
          QuizMode.sentenceBlank => question.idiom.answer.trim(),
        };
        expect(question.choices[question.correctIndex], expectedAnswer);
        if (question.mode == QuizMode.wordLookup) {
          expect(question.readingOf.keys, containsAll(question.choices));
        }
      }
    }

    expect(seenModes, containsAll(QuizMode.values));
  });

  test('invalid terms never become a target or distractor', () {
    final pool = <Idiom>[
      _idiom('sexo', '성관계', enMeaning: 'sex'),
      _idiom('esta tarde', '오늘 오후', enMeaning: 'this afternoon'),
      ..._quizPool(10),
    ];
    const blockedChoices = {
      'sexo',
      '성관계',
      'sex',
      'esta tarde',
      '오늘 오후',
      'this afternoon',
    };

    for (var seed = 0; seed < 20; seed++) {
      final session = QuizSession.build(
        pool,
        count: 10,
        seed: seed,
        language: StudyLanguage.ko,
      );
      expect(session.questions, hasLength(10));
      for (final question in session.questions) {
        expect(blockedChoices, isNot(contains(question.idiom.idiom)));
        expect(question.choices.any(blockedChoices.contains), false);
      }
    }
  });

  test('zero or negative question count produces an empty session', () {
    final pool = _quizPool(4);

    expect(QuizSession.build(pool, count: 0).questions, isEmpty);
    expect(QuizSession.build(pool, count: -1).questions, isEmpty);
  });

  test('bad generated example templates are not usable examples', () {
    final badExamples = [
      _idiom(
        'caro',
        '비싼',
        enMeaning: 'expensive',
        example: 'El resultado es caro.',
      ),
      _idiom(
        'rico',
        '부유한',
        enMeaning: 'rich',
        example: 'Este resultado es rico.',
      ),
      _idiom(
        'antes',
        '전에',
        enMeaning: 'before',
        example: 'Uso antes para unir dos ideas.',
      ),
      _idiom(
        'madre',
        '어머니',
        enMeaning: 'mother',
        example: 'Conozco a un madre del barrio.',
      ),
      _idiom(
        'correo electrónico',
        '이메일',
        enMeaning: 'email',
        example: 'Necesito correo electrónico hoy.',
      ),
      _idiom(
        'bebida',
        '음료',
        enMeaning: 'drink',
        example: 'Quiero una bebida fría.',
      ),
      _idiom(
        'cafetería',
        '카페테리아',
        enMeaning: 'cafeteria',
        example: 'Tomo cafetería en el desayuno.',
      ),
    ];

    badExamples.addAll([
      _idiom(
        'manana',
        'tomorrow',
        enMeaning: 'tomorrow',
        example: 'Nos vemos manana por la tarde.',
        blankedExample: 'Nos vemos ____ por la tarde.',
      ),
      _idiom(
        'habitacion',
        'room',
        enMeaning: 'room',
        example: 'La habitacion de la casa es pequena.',
        blankedExample: 'La ____ de la casa es pequena.',
      ),
    ]);

    for (final idiom in badExamples) {
      expect(idiom.hasUsableExample, false, reason: idiom.example);
    }
  });

  test('blank example must hide the answer itself', () {
    final mismatchedBlank = _idiom(
      'manana',
      'tomorrow',
      enMeaning: 'tomorrow',
      example: 'Nos vemos manana por la tarde.',
      blankedExample: '____ vemos manana por la tarde.',
    );
    final unaccentedExample = _idiom(
      'manana',
      'tomorrow',
      enMeaning: 'tomorrow',
      example: 'Nos vemos manana por la tarde.',
      blankedExample: 'Nos vemos ____ por la tarde.',
    );
    final matchedBlank = _idiom(
      'ma\u00f1ana',
      'tomorrow',
      enMeaning: 'tomorrow',
      example: 'Nos vemos ma\u00f1ana por la tarde.',
      blankedExample: 'Nos vemos ____ por la tarde.',
    );

    expect(mismatchedBlank.hasUsableExample, false);
    expect(unaccentedExample.hasUsableExample, false);
    expect(matchedBlank.hasUsableExample, true);
  });

  test('awkward electronic address phrase is not a quiz term', () {
    expect(
      _idiom(
        'direccion electronica',
        'email address',
        enMeaning: 'electronic address',
      ).isQuizTerm,
      false,
    );
  });

  test('mature terms are not quiz terms', () {
    final blocked = [
      _idiom('sexo', 'sex', enMeaning: 'sex'),
      _idiom('cerveza', 'beer', enMeaning: 'beer'),
      _idiom('alcohol', 'alcohol', enMeaning: 'alcohol'),
      _idiom('embarazo', 'pregnancy', enMeaning: 'pregnancy'),
    ];
    final allowed = [
      _idiom('farmacia', 'pharmacy', enMeaning: 'pharmacy'),
      _idiom('armario', 'closet', enMeaning: 'closet'),
    ];

    for (final idiom in blocked) {
      expect(idiom.isQuizTerm, false, reason: idiom.idiom);
    }
    for (final idiom in allowed) {
      expect(idiom.isQuizTerm, true, reason: idiom.idiom);
    }
  });
}

List<Idiom> _quizPool(int count) => [
  for (var index = 0; index < count; index++)
    _idiom(
      'palabra$index',
      '뜻 $index',
      enMeaning: 'meaning $index',
      example: 'Veo palabra$index cerca del parque.',
    ),
];

List<Object?> _questionSignature(QuizSession session) => [
  for (final question in session.questions)
    <Object?>[
      question.idiom.idiom,
      question.mode.name,
      List<String>.of(question.choices),
      question.correctIndex,
      Map<String, String>.of(question.readingOf),
    ],
];

String _choiceKeyForTest(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll('á', 'a')
    .replaceAll('à', 'a')
    .replaceAll('ä', 'a')
    .replaceAll('â', 'a')
    .replaceAll('ã', 'a')
    .replaceAll('é', 'e')
    .replaceAll('è', 'e')
    .replaceAll('ë', 'e')
    .replaceAll('ê', 'e')
    .replaceAll('í', 'i')
    .replaceAll('ì', 'i')
    .replaceAll('ï', 'i')
    .replaceAll('î', 'i')
    .replaceAll('ó', 'o')
    .replaceAll('ò', 'o')
    .replaceAll('ö', 'o')
    .replaceAll('ô', 'o')
    .replaceAll('õ', 'o')
    .replaceAll('ú', 'u')
    .replaceAll('ù', 'u')
    .replaceAll('ü', 'u')
    .replaceAll('û', 'u')
    .replaceAll('ñ', 'n')
    .replaceAll('ç', 'c')
    .replaceAll(RegExp(r'\s+'), ' ');

Idiom _idiom(
  String spanish,
  String koMeaning, {
  String? enMeaning,
  String example = '',
  String? blankedExample,
}) {
  final hasExample = example.isNotEmpty;
  return Idiom(
    spanish: spanish,
    pronunciation: spanish,
    meanings: {
      StudyLanguage.ko: koMeaning,
      StudyLanguage.en: koMeaning.isEmpty ? '' : enMeaning ?? spanish,
      StudyLanguage.ja: koMeaning.isEmpty ? '' : spanish,
    },
    example: example,
    exampleMeanings: const {
      StudyLanguage.ko: '',
      StudyLanguage.en: '',
      StudyLanguage.ja: '',
    },
    blankedExample:
        blankedExample ??
        (hasExample
            ? example.replaceFirst(
                RegExp(RegExp.escape(spanish), caseSensitive: false),
                '____',
              )
            : ''),
    answer: spanish,
    level: 'A1',
    theme: 'test',
    partOfSpeech: 'noun',
    wrongChoices: const [],
    difficulty: 1,
  );
}
