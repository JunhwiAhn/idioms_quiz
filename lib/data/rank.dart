class Rank {
  final int level;
  final String name;
  final int threshold;

  const Rank({
    required this.level,
    required this.name,
    required this.threshold,
  });
}

/// Ranks are unlocked once total_correct crosses the threshold.
const ranks = <Rank>[
  Rank(level: 1, name: 'Novato', threshold: 0),
  Rank(level: 2, name: 'Aprendiz', threshold: 10),
  Rank(level: 3, name: 'Explorador', threshold: 30),
  Rank(level: 4, name: 'Estudiante', threshold: 60),
  Rank(level: 5, name: 'Hablante', threshold: 100),
  Rank(level: 6, name: 'Viajero', threshold: 160),
  Rank(level: 7, name: 'Conversador', threshold: 240),
  Rank(level: 8, name: 'Intérprete', threshold: 340),
  Rank(level: 9, name: 'Lingüista', threshold: 460),
  Rank(level: 10, name: 'Embajador', threshold: 600),
  Rank(level: 11, name: 'Maestro', threshold: 760),
  Rank(level: 12, name: 'Sabio', threshold: 940),
  Rank(level: 13, name: 'Gran Maestro', threshold: 1200),
];

Rank rankFor(int totalCorrect) {
  var current = ranks.first;
  for (final r in ranks) {
    if (totalCorrect >= r.threshold) current = r;
  }
  return current;
}

Rank? nextRankFor(int totalCorrect) {
  for (final r in ranks) {
    if (totalCorrect < r.threshold) return r;
  }
  return null;
}

/// Progress toward next rank. 1.0 if at max rank.
double rankProgress(int totalCorrect) {
  final cur = rankFor(totalCorrect);
  final next = nextRankFor(totalCorrect);
  if (next == null) return 1.0;
  final span = next.threshold - cur.threshold;
  if (span <= 0) return 1.0;
  return ((totalCorrect - cur.threshold) / span).clamp(0.0, 1.0);
}

/// Every [kCorrectPerLevel] correct answers earn 1 level. Chosen low so
/// early-game users see frequent level-ups.
const int kCorrectPerLevel = 5;

int levelFor(int totalCorrect) => (totalCorrect ~/ kCorrectPerLevel) + 1;

/// Remaining correct answers needed to reach the next level.
int remainingToNextLevel(int totalCorrect) =>
    kCorrectPerLevel - (totalCorrect % kCorrectPerLevel);

/// Fraction 0..1 toward next level.
double levelProgress(int totalCorrect) =>
    (totalCorrect % kCorrectPerLevel) / kCorrectPerLevel;
