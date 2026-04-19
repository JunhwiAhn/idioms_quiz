class Idiom {
  final String idiom;
  final String reading;
  final String meaning;
  final List<String> wrongChoices;
  final int difficulty;

  const Idiom({
    required this.idiom,
    required this.reading,
    required this.meaning,
    required this.wrongChoices,
    required this.difficulty,
  });

  factory Idiom.fromJson(Map<String, dynamic> json) => Idiom(
        idiom: json['idiom'] as String,
        reading: json['reading'] as String,
        meaning: json['meaning'] as String,
        wrongChoices: (json['wrongChoices'] as List<dynamic>)
            .map((e) => e as String)
            .toList(growable: false),
        difficulty: (json['difficulty'] as num?)?.toInt() ?? 3,
      );
}
