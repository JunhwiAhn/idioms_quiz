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
  Rank(level: 1, name: '白帯', threshold: 0),
  Rank(level: 2, name: '青帯', threshold: 10),
  Rank(level: 3, name: '緑帯', threshold: 30),
  Rank(level: 4, name: '茶帯', threshold: 60),
  Rank(level: 5, name: '黒帯', threshold: 100),
  Rank(level: 6, name: '初段', threshold: 160),
  Rank(level: 7, name: '二段', threshold: 240),
  Rank(level: 8, name: '三段', threshold: 340),
  Rank(level: 9, name: '四段', threshold: 460),
  Rank(level: 10, name: '五段', threshold: 600),
  Rank(level: 11, name: '六段', threshold: 760),
  Rank(level: 12, name: '七段', threshold: 940),
  Rank(level: 13, name: '名人', threshold: 1200),
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
