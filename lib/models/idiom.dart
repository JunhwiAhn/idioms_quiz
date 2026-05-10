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
    required this.partOfSpeech,
    required this.wrongChoices,
    required this.difficulty,
  });

  String get idiom => spanish;
  String get reading => pronunciation;
  String get meaning => meaningFor(StudyLanguage.ko);

  String meaningFor(StudyLanguage language) =>
      meanings[language] ?? meanings[StudyLanguage.ko] ?? spanish;

  factory Idiom.fromJson(Map<String, dynamic> json) => Idiom(
        spanish: (json['spanish'] ?? json['idiom']) as String,
        pronunciation: (json['pronunciation'] ?? json['reading']) as String,
        meanings: _readMeanings(json),
        example: (json['example'] ?? '') as String,
        exampleMeanings: _readTranslationMap(json, 'exampleMeanings'),
        blankedExample: (json['blankedExample'] ?? '') as String,
        answer: (json['answer'] ?? json['spanish'] ?? json['idiom']) as String,
        level: (json['level'] ?? 'A1') as String,
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
}
