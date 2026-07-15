import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/idiom.dart';

class IdiomRepository {
  static const _assetPath =
      'assets/data/dele_a1_a2_b1_problem_bank.enriched.json';

  List<Idiom>? _cache;

  Future<List<Idiom>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(_assetPath);
    final decodedJson = json.decode(raw);
    final decoded = decodedJson is List<dynamic>
        ? decodedJson
        : (decodedJson as Map<String, dynamic>)['entries'] as List<dynamic>;
    final entries = decoded
        .map((e) => Idiom.fromJson(e as Map<String, dynamic>))
        .where((entry) => entry.isQuizTerm)
        .where((entry) => entry.hasMeaningFor(StudyLanguage.ko))
        .toList(growable: false);
    _cache = _dedupeByTerm(entries);
    return _cache!;
  }

  List<Idiom> _dedupeByTerm(List<Idiom> entries) {
    final byTerm = <String, Idiom>{};
    for (final entry in entries) {
      final key = _termKey(entry);
      final current = byTerm[key];
      if (current == null || _compareRepresentative(entry, current) < 0) {
        byTerm[key] = entry;
      }
    }
    return byTerm.values.toList(growable: false);
  }

  String _termKey(Idiom entry) => entry.reading.trim().isNotEmpty
      ? entry.reading.trim().toLowerCase()
      : entry.idiom.trim().toLowerCase();

  int _compareRepresentative(Idiom a, Idiom b) {
    final level = _levelRank(a.level).compareTo(_levelRank(b.level));
    if (level != 0) return level;
    final difficulty = a.difficulty.compareTo(b.difficulty);
    if (difficulty != 0) return difficulty;
    return a.idiom.compareTo(b.idiom);
  }

  int _levelRank(String level) => switch (level.toUpperCase()) {
    'A1' => 1,
    'A2' => 2,
    'B1' => 3,
    'B2' => 4,
    'C1' => 5,
    _ => 99,
  };
}
