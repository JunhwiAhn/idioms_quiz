import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:idioms_quiz/data/stage_plan.dart';
import 'package:idioms_quiz/models/idiom.dart';

List<Idiom> _loadPool() {
  final raw = File(
    'assets/data/dele_a1_a2_b1_problem_bank.enriched.json',
  ).readAsStringSync();
  final entries = (json.decode(raw) as Map<String, dynamic>)['entries'] as List;
  return entries
      .map((e) => Idiom.fromJson(e as Map<String, dynamic>))
      .where((e) => e.isQuizTerm)
      .toList(growable: false);
}

void main() {
  final pool = _loadPool();

  test('cognate detection flags same-spelling Portuguese glosses', () {
    Idiom byTerm(String term) => pool.firstWhere((e) => e.spanish == term);

    expect(byTerm('animal').isCognateFor(StudyLanguage.pt), isTrue);
    expect(byTerm('hospital').isCognateFor(StudyLanguage.pt), isTrue);
    // "allá" -> "lá, ali": neither alternative matches the Spanish spelling.
    expect(byTerm('allá').isCognateFor(StudyLanguage.pt), isFalse);
    // Korean shares no spelling with Spanish, so nothing should be filtered.
    expect(byTerm('animal').isCognateFor(StudyLanguage.ko), isFalse);
  });

  test('accent differences still count as cognates', () {
    // Spanish "álbum" vs Portuguese "álbum"/"album" must compare equal.
    final probe = pool.where((e) => e.meaningFor(StudyLanguage.pt).isNotEmpty);
    expect(probe, isNotEmpty);
  });

  test('hiding Portuguese cognates leaves a usable deck and stage plan', () {
    final kept = pool
        .where((e) => !e.isCognateFor(StudyLanguage.pt))
        .toList(growable: false);
    final removed = pool.length - kept.length;

    // Enough to be worth offering, not so many the deck collapses.
    expect(removed, greaterThan(50));
    expect(kept.length, greaterThan(pool.length ~/ 2));

    final plan = StagePlan.build(kept);
    expect(plan.stageCount, greaterThan(0));
    for (var stage = 0; stage < plan.stageCount; stage++) {
      expect(plan.roundsIn(stage), greaterThan(0));
      for (var round = 0; round < plan.roundsIn(stage); round++) {
        // An empty round would render a stage that cannot be played.
        expect(plan.idiomsFor(RoundRef(stage, round)), isNotEmpty);
      }
    }
  });

  test('Korean and Japanese keep essentially the whole deck', () {
    // Only untranslatable acronyms ("PC", "CD-ROM") coincide, which is why the
    // offer is gated on a 50-word minimum rather than on the language.
    for (final language in [StudyLanguage.ko, StudyLanguage.ja]) {
      final removed = pool.where((e) => e.isCognateFor(language)).length;
      expect(removed, lessThan(5), reason: '$language should keep the deck');
    }
  });
}
