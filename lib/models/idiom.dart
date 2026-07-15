enum StudyLanguage {
  ko('ko', '한국어'),
  en('en', 'English'),
  ja('ja', '日本語');

  final String code;
  final String label;
  const StudyLanguage(this.code, this.label);

  static StudyLanguage fromCode(String? code) {
    for (final lang in StudyLanguage.values) {
      if (lang.code == code) return lang;
    }
    return StudyLanguage.ko;
  }

  static StudyLanguage fromLocaleCode(String? code) {
    final normalized = code?.toLowerCase();
    if (normalized == 'ko') return StudyLanguage.ko;
    if (normalized == 'ja') return StudyLanguage.ja;
    return StudyLanguage.en;
  }
}

class Idiom {
  final String spanish;
  final String pronunciation;
  final Map<StudyLanguage, String> meanings;
  final String example;
  final Map<StudyLanguage, String> exampleMeanings;
  final String blankedExample;
  final String answer;
  final String level;
  final String theme;
  final String partOfSpeech;
  final List<String> wrongChoices;
  final int difficulty;

  const Idiom({
    required this.spanish,
    required this.pronunciation,
    required this.meanings,
    required this.example,
    required this.exampleMeanings,
    required this.blankedExample,
    required this.answer,
    required this.level,
    required this.theme,
    required this.partOfSpeech,
    required this.wrongChoices,
    required this.difficulty,
  });

  String get idiom => spanish;
  String get reading => pronunciation;
  String get meaning => meaningFor(StudyLanguage.ko);
  bool get isQuizTerm => !_isPhraseFragment(spanish) && isChildSafeTerm;
  bool get isChildSafeTerm => !_hasMatureContent([
    spanish,
    pronunciation,
    answer,
    ...meanings.values,
    example,
    ...exampleMeanings.values,
  ]);
  bool hasMeaningFor(StudyLanguage language) =>
      _firstNonEmpty([
        meanings[language],
        meanings[StudyLanguage.ko],
        meanings[StudyLanguage.en],
        meanings[StudyLanguage.ja],
      ]) !=
      null;
  bool get hasUsableExample =>
      example.trim().isNotEmpty &&
      blankedExample.contains('____') &&
      answer.trim().isNotEmpty &&
      _blankMatchesAnswer(example, blankedExample, answer) &&
      _exampleIssues(example, blankedExample).isEmpty;
  List<String> get levels => level
      .split('/')
      .map((value) => value.trim().toUpperCase())
      .where((value) => value.isNotEmpty)
      .toList(growable: false);

  bool hasLevel(String value) => levels.contains(value.toUpperCase());

  String meaningFor(StudyLanguage language) =>
      _firstNonEmpty([
        meanings[language],
        meanings[StudyLanguage.ko],
        meanings[StudyLanguage.en],
        meanings[StudyLanguage.ja],
      ]) ??
      '';

  static String? _firstNonEmpty(Iterable<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    }
    return null;
  }

  static bool _isPhraseFragment(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'\s+'), ' ');
    if (RegExp(
      r'^est[ae]\s+(manana|tarde|noche|semana|mes)$',
    ).hasMatch(normalized)) {
      return true;
    }
    if (normalized == 'direccion electronica') {
      return true;
    }
    return false;
  }

  static bool _blankMatchesAnswer(
    String example,
    String blankedExample,
    String answer,
  ) {
    final blankCount = RegExp('____').allMatches(blankedExample).length;
    if (blankCount != 1) return false;
    final restored = blankedExample.replaceFirst('____', answer);
    return _sentenceKey(restored) == _sentenceKey(example);
  }

  static String _sentenceKey(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('\u00e1', 'a')
        .replaceAll('\u00e9', 'e')
        .replaceAll('\u00ed', 'i')
        .replaceAll('\u00f3', 'o')
        .replaceAll('\u00fa', 'u')
        .replaceAll('\u00f1', 'n')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static bool _hasMatureContent(Iterable<String> values) {
    final text = values.map(_contentKey).join(' ');
    final tokens = text
        .split(RegExp(r'[^a-z0-9가-힣]+'))
        .where((token) => token.isNotEmpty)
        .toSet();
    const blockedTokens = {
      'sexo',
      'sexual',
      'sexy',
      'heterosexual',
      'homosexual',
      'erotico',
      'pornografia',
      'condon',
      'prostitucion',
      'prostituta',
      'alcohol',
      'cerveza',
      'vino',
      'tabaco',
      'cigarro',
      'cigarrillo',
      'fumar',
      'droga',
      'drogas',
      'cocaina',
      'heroina',
      'marihuana',
      'embarazo',
      'embarazada',
      'parto',
      'cesarea',
      '섹스',
      '성관계',
      '성적',
      '포르노',
      '술',
      '맥주',
      '와인',
      '담배',
      '마약',
    };
    if (tokens.any(blockedTokens.contains)) return true;
    return RegExp(
      r'\b(sex|sexual|porn|erotic|condom|prostitut|alcohol|beer|wine|tobacco|cigarette|drug|cocaine|heroin|marijuana|pregnan|childbirth|cesarean)\b',
      caseSensitive: false,
    ).hasMatch(text);
  }

  static String _contentKey(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('\u00e1', 'a')
        .replaceAll('\u00e9', 'e')
        .replaceAll('\u00ed', 'i')
        .replaceAll('\u00f3', 'o')
        .replaceAll('\u00fa', 'u')
        .replaceAll('\u00f1', 'n')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  factory Idiom.fromJson(Map<String, dynamic> json) => Idiom(
    spanish: (json['spanish'] ?? json['idiom'] ?? json['term']) as String,
    pronunciation:
        (json['pronunciation'] ??
                json['reading'] ??
                json['normalizedTerm'] ??
                json['term'] ??
                json['spanish'] ??
                json['idiom'])
            as String,
    meanings: _readMeanings(json),
    example: (json['example'] ?? '') as String,
    exampleMeanings: _readTranslationMap(json, 'exampleMeanings'),
    blankedExample: (json['blankedExample'] ?? '') as String,
    answer:
        (json['answer'] ?? json['spanish'] ?? json['idiom'] ?? json['term'])
            as String,
    level: (json['level'] ?? 'A1') as String,
    theme: (json['theme'] ?? '') as String,
    partOfSpeech: (json['partOfSpeech'] ?? 'word') as String,
    wrongChoices: ((json['wrongChoices'] as List<dynamic>?) ?? const [])
        .map((e) => e as String)
        .toList(growable: false),
    difficulty: (json['difficulty'] as num?)?.toInt() ?? 3,
  );

  static Map<StudyLanguage, String> _readMeanings(Map<String, dynamic> json) {
    final result = _readTranslationMap(json, 'meanings');
    if (result.values.any((v) => v.isNotEmpty)) return result;
    return {
      StudyLanguage.ko: (json['meaning'] ?? '') as String,
      StudyLanguage.en: (json['meaningEn'] ?? json['meaning'] ?? '') as String,
      StudyLanguage.ja: (json['meaningJa'] ?? json['meaning'] ?? '') as String,
    };
  }

  static Map<StudyLanguage, String> _readTranslationMap(
    Map<String, dynamic> json,
    String key,
  ) {
    final raw = json['meanings'];
    final selected = json[key];
    if (selected is Map<String, dynamic>) {
      return {
        for (final lang in StudyLanguage.values)
          lang: (selected[lang.code] as String?) ?? '',
      };
    }
    if (raw is Map<String, dynamic>) {
      return {
        for (final lang in StudyLanguage.values)
          lang: key == 'meanings' ? (raw[lang.code] as String?) ?? '' : '',
      };
    }
    return {for (final lang in StudyLanguage.values) lang: ''};
  }

  String exampleMeaningFor(StudyLanguage language) =>
      exampleMeanings[language] ?? exampleMeanings[StudyLanguage.ko] ?? '';

  static List<String> _exampleIssues(String example, String blankedExample) {
    final joined = '$example $blankedExample';
    final issues = <String>[];
    if (RegExp(
      r'La palabra|Estudio la palabra|aparece en la lista|Review the Spanish item',
      caseSensitive: false,
    ).hasMatch(joined)) {
      issues.add('meta_word_example');
    }
    if (RegExp(
      r'^Uso (el|la|un|una) .+ en una situacion diaria\.?$',
      caseSensitive: false,
    ).hasMatch(example.trim())) {
      issues.add('generic_placeholder_example');
    }
    if (RegExp(
      r'\b(situacion|manana|pequena|montana|clinica|galeria|bateria|averia|perdida)\b',
      caseSensitive: false,
    ).hasMatch(joined)) {
      issues.add('missing_accent_example');
    }
    if (RegExp(
      r'^(El|Este)\s+resultado es .+\.?$',
      caseSensitive: false,
    ).hasMatch(example.trim())) {
      issues.add('generic_result_example');
    }
    if (RegExp(
      r'^Uso .+ para unir dos ideas\.?$',
      caseSensitive: false,
    ).hasMatch(example.trim())) {
      issues.add('generic_connector_example');
    }
    if (RegExp(
      r'^Conozco a (un|una) .+ del barrio\.?$',
      caseSensitive: false,
    ).hasMatch(example.trim())) {
      issues.add('generic_person_example');
    }
    if (RegExp(
      r'^Necesito .+ hoy\.?$',
      caseSensitive: false,
    ).hasMatch(example.trim())) {
      issues.add('generic_need_example');
    }
    if (RegExp(
      r'^Quiero un(a)? .+ fr[ií]a\.?$',
      caseSensitive: false,
    ).hasMatch(example.trim())) {
      issues.add('ambiguous_category_example');
    }
    if (RegExp(
      r'^Tomo .+ en el desayuno\.?$',
      caseSensitive: false,
    ).hasMatch(example.trim())) {
      issues.add('ambiguous_meal_example');
    }
    if (RegExp(
      r'^Voy a \S+(me)? esta tarde\.?$',
      caseSensitive: false,
    ).hasMatch(example.trim())) {
      issues.add('weak_context_example');
    }
    if (RegExp(
      r'^Necesito el .+ para viajar\.?$',
      caseSensitive: false,
    ).hasMatch(example.trim())) {
      issues.add('weak_context_example');
    }
    return issues;
  }
}
