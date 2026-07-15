import 'dart:math';
import '../models/idiom.dart';
import 'score_service.dart' show HintKind, kActiveHintKinds;

enum QuizMode { translationLookup, wordLookup, sentenceBlank }

extension QuizModeX on QuizMode {
  String get label => switch (this) {
    QuizMode.translationLookup => 'Meaning',
    QuizMode.wordLookup => 'Word',
    QuizMode.sentenceBlank => 'Blank',
  };

  String get description => switch (this) {
    QuizMode.translationLookup =>
      'Choose the translation for the Spanish word.',
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
  final List<String> incorrectIdioms = [];
  final List<HintKind> droppedHints = [];
  final Random _rng;

  QuizSession({required this.questions, int? seed}) : _rng = Random(seed);

  bool get isFinished => currentIndex >= questions.length;
  QuizQuestion get current => questions[currentIndex];
  int get currentStreak => _currentStreak;

  SubmitResult submit(int pickedIndex) {
    final correct = pickedIndex == current.correctIndex;
    HintKind? drop;
    if (correct) {
      correctCount++;
      correctIdioms.add(current.idiom.idiom);
      _currentStreak++;
      if (_currentStreak > longestStreak) longestStreak = _currentStreak;
      if (_rng.nextDouble() < kHintDropChance) {
        final kinds = kActiveHintKinds;
        drop = kinds[_rng.nextInt(kinds.length)];
        droppedHints.add(drop);
      }
    } else {
      incorrectIdioms.add(current.idiom.idiom);
      _currentStreak = 0;
    }
    return SubmitResult(correct: correct, droppedHint: drop);
  }

  void advance() {
    currentIndex++;
  }

  /// [focusIdioms] restricts which idioms become questions while distractor
  /// choices still draw from the whole [pool] — without it a small pool
  /// (e.g. a short wrong-answer list) can't fill 4 choices and yields an
  /// empty session.
  static QuizSession build(
    List<Idiom> pool, {
    int count = 10,
    int? seed,
    StudyLanguage language = StudyLanguage.ko,
    Set<String>? focusIdioms,
  }) {
    if (count <= 0 || pool.isEmpty) {
      return QuizSession(questions: const <QuizQuestion>[], seed: seed);
    }

    final rng = Random(seed);
    final index = _QuizPoolIndex.build(pool, language);
    final candidates = focusIdioms == null
        ? index.questionCandidates
        : index.questionCandidates
              .where((entry) => focusIdioms.contains(entry.idiom.idiom))
              .toList(growable: false);
    final shuffled = [...candidates]..shuffle(rng);
    final questions = <QuizQuestion>[];

    for (final entry in shuffled) {
      final modes = index.availableModes(entry)..shuffle(rng);
      if (modes.isEmpty) continue;

      for (final mode in modes) {
        final question = index.buildQuestion(entry, mode, rng);
        if (question == null) continue;
        questions.add(question);
        break;
      }
      if (questions.length >= count) break;
    }

    return QuizSession(questions: questions, seed: seed);
  }

  static String _choiceKey(String value) => _normalizedKey(value);

  static List<String> _meaningGroups(Idiom idiom, StudyLanguage language) {
    final groups = <String>{
      for (final value in [
        idiom.meaningFor(language),
        idiom.meaningFor(StudyLanguage.ko),
        idiom.meaningFor(StudyLanguage.en),
        idiom.meaningFor(StudyLanguage.ja),
      ])
        if (value.trim().isNotEmpty) _normalizedKey(value),
    };
    final termGroup = _manualMeaningGroup(_normalizedKey(idiom.idiom));
    if (termGroup != null) groups.add(termGroup);
    for (final group in groups.toList()) {
      final mapped = _manualMeaningGroup(group);
      if (mapped != null) groups.add(mapped);
    }
    return groups.toList(growable: false);
  }

  static String? _manualMeaningGroup(String key) {
    const groups = {
      'day_time': {
        'dia',
        'dias',
        'jornada',
        'day',
        'days',
        '날',
        '하루',
        '일',
        '日',
      },
      'work_job': {'trabajo', 'work', 'job', '일', '仕事'},
    };
    for (final entry in groups.entries) {
      if (entry.value.contains(key)) return entry.key;
    }
    return null;
  }

  static String _normalizedKey(String value) {
    const from = 'áàäâãéèëêíìïîóòöôõúùüûñç';
    const to = 'aaaaaeeeeiiiiooooouuuunc';
    final buffer = StringBuffer();
    for (final rune in value.trim().toLowerCase().runes) {
      final char = String.fromCharCode(rune);
      final index = from.indexOf(char);
      buffer.write(index >= 0 ? to[index] : char);
    }
    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ');
  }
}

class _QuizPoolIndex {
  final StudyLanguage language;
  final List<_IndexedIdiom> questionCandidates;
  final int answerChoiceCount;

  const _QuizPoolIndex({
    required this.language,
    required this.questionCandidates,
    required this.answerChoiceCount,
  });

  factory _QuizPoolIndex.build(List<Idiom> pool, StudyLanguage language) {
    final indexed = <_IndexedIdiom>[];
    final answerKeys = <String>{};

    for (final idiom in pool) {
      final answer = idiom.answer.trim();
      final answerKey = QuizSession._choiceKey(answer);
      final meaning = idiom.meaningFor(language).trim();
      if (answerKey.isNotEmpty) answerKeys.add(answerKey);

      final isQuizTerm = idiom.isQuizTerm;
      if (!isQuizTerm) continue;

      indexed.add(
        _IndexedIdiom(
          idiom: idiom,
          idiomText: idiom.idiom.trim(),
          idiomKey: QuizSession._choiceKey(idiom.idiom),
          answer: answer,
          answerKey: answerKey,
          meaning: meaning,
          meaningKey: QuizSession._choiceKey(meaning),
          meaningGroups: Set<String>.unmodifiable(
            QuizSession._meaningGroups(idiom, language),
          ),
          hasUsableExample: idiom.hasUsableExample,
        ),
      );
    }

    return _QuizPoolIndex(
      language: language,
      questionCandidates: List<_IndexedIdiom>.unmodifiable(indexed),
      answerChoiceCount: answerKeys.length,
    );
  }

  List<QuizMode> availableModes(_IndexedIdiom entry) {
    final modes = <QuizMode>[];
    if (entry.idiomText.isNotEmpty && entry.meaning.isNotEmpty) {
      modes.add(QuizMode.wordLookup);
    }
    if (entry.meaning.isNotEmpty) {
      modes.add(QuizMode.translationLookup);
    }
    if (entry.hasUsableExample && answerChoiceCount >= 4) {
      modes.add(QuizMode.sentenceBlank);
    }
    return modes;
  }

  QuizQuestion? buildQuestion(
    _IndexedIdiom answer,
    QuizMode mode,
    Random rng,
  ) => switch (mode) {
    QuizMode.wordLookup => _buildWordQuestion(answer, rng),
    QuizMode.translationLookup => _buildMeaningQuestion(answer, rng),
    QuizMode.sentenceBlank => _buildBlankQuestion(answer, rng),
  };

  QuizQuestion? _buildWordQuestion(_IndexedIdiom answer, Random rng) {
    final correct = answer.idiomText;
    final choices = <String>[correct];
    final readings = <String, String>{correct: answer.idiom.reading};
    final seenChoices = <String>{answer.idiomKey};
    final seenMeaningGroups = <String>{...answer.meaningGroups};

    for (final candidate in _randomCandidates(rng)) {
      if (_conflictsWithAnswer(candidate, answer) ||
          candidate.idiomText.isEmpty ||
          !seenChoices.add(candidate.idiomKey) ||
          candidate.meaningGroups.any(seenMeaningGroups.contains)) {
        continue;
      }
      seenMeaningGroups.addAll(candidate.meaningGroups);
      choices.add(candidate.idiomText);
      readings[candidate.idiomText] = candidate.idiom.reading;
      if (choices.length == 4) break;
    }

    return _finishQuestion(answer, QuizMode.wordLookup, choices, readings, rng);
  }

  QuizQuestion? _buildMeaningQuestion(_IndexedIdiom answer, Random rng) {
    final correct = answer.meaning;
    final choices = <String>[correct];
    final seenChoices = <String>{answer.meaningKey};
    final seenMeaningGroups = <String>{...answer.meaningGroups};

    for (final candidate in _randomCandidates(rng)) {
      final choice = candidate.meaning;
      if (_conflictsWithAnswer(candidate, answer) ||
          choice.isEmpty ||
          !seenChoices.add(candidate.meaningKey) ||
          candidate.meaningGroups.any(seenMeaningGroups.contains)) {
        continue;
      }
      seenMeaningGroups.addAll(candidate.meaningGroups);
      choices.add(choice);
      if (choices.length == 4) break;
    }

    return _finishQuestion(
      answer,
      QuizMode.translationLookup,
      choices,
      const <String, String>{},
      rng,
    );
  }

  QuizQuestion? _buildBlankQuestion(_IndexedIdiom answer, Random rng) {
    final correct = answer.answer;
    final choices = <String>[correct];
    final seenChoices = <String>{answer.answerKey};

    for (final candidate in _randomCandidates(rng)) {
      if (_conflictsWithAnswer(candidate, answer) ||
          candidate.answer.isEmpty ||
          !seenChoices.add(candidate.answerKey)) {
        continue;
      }
      choices.add(candidate.answer);
      if (choices.length == 4) break;
    }

    return _finishQuestion(
      answer,
      QuizMode.sentenceBlank,
      choices,
      const <String, String>{},
      rng,
    );
  }

  QuizQuestion? _finishQuestion(
    _IndexedIdiom answer,
    QuizMode mode,
    List<String> choices,
    Map<String, String> readings,
    Random rng,
  ) {
    if (choices.length < 4) return null;
    final correct = choices.first;
    choices.shuffle(rng);
    final correctIndex = choices.indexOf(correct);
    if (correctIndex < 0) return null;

    return QuizQuestion(
      idiom: answer.idiom,
      mode: mode,
      maskedIndices: const <int>[],
      choices: choices,
      correctIndex: correctIndex,
      readingOf: readings,
      language: language,
    );
  }

  bool _conflictsWithAnswer(_IndexedIdiom candidate, _IndexedIdiom answer) =>
      candidate.idiomKey == answer.idiomKey ||
      candidate.meaningGroups.any(answer.meaningGroups.contains);

  Iterable<_IndexedIdiom> _randomCandidates(Random rng) sync* {
    var remaining = questionCandidates.length;
    final swaps = <int, int>{};

    while (remaining > 0) {
      final slot = rng.nextInt(remaining);
      final pickedIndex = swaps[slot] ?? slot;
      final lastSlot = remaining - 1;
      final lastIndex = swaps[lastSlot] ?? lastSlot;
      if (slot != lastSlot) swaps[slot] = lastIndex;
      swaps.remove(lastSlot);
      remaining = lastSlot;
      yield questionCandidates[pickedIndex];
    }
  }
}

class _IndexedIdiom {
  final Idiom idiom;
  final String idiomText;
  final String idiomKey;
  final String answer;
  final String answerKey;
  final String meaning;
  final String meaningKey;
  final Set<String> meaningGroups;
  final bool hasUsableExample;

  const _IndexedIdiom({
    required this.idiom,
    required this.idiomText,
    required this.idiomKey,
    required this.answer,
    required this.answerKey,
    required this.meaning,
    required this.meaningKey,
    required this.meaningGroups,
    required this.hasUsableExample,
  });
}
