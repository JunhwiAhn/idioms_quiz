class KankenTier {
  final int min;
  final String label;
  final String subtitle;
  final String percentile;

  const KankenTier({
    required this.min,
    required this.label,
    required this.subtitle,
    required this.percentile,
  });
}

/// Gamified tiers based on mastered Spanish vocabulary count.
const kankenTiers = <KankenTier>[
  KankenTier(min: 0,   label: 'A1 Starter', subtitle: 'Core survival words', percentile: 'Top 90% est.'),
  KankenTier(min: 10,  label: 'A1 Explorer', subtitle: 'Daily-life vocabulary', percentile: 'Top 70% est.'),
  KankenTier(min: 25,  label: 'A2 Builder', subtitle: 'Travel and routine words', percentile: 'Top 50% est.'),
  KankenTier(min: 45,  label: 'B1 Speaker', subtitle: 'Opinions and experiences', percentile: 'Top 25% est.'),
  KankenTier(min: 65,  label: 'B2 Analyst', subtitle: 'Abstract and news vocabulary', percentile: 'Top 10% est.'),
  KankenTier(min: 85,  label: 'DELE Pro', subtitle: 'Exam-ready vocabulary', percentile: 'Top 3% est.'),
  KankenTier(min: 100, label: 'DELE Master', subtitle: 'Complete mastery track', percentile: 'Top 1% est.'),
];

KankenTier kankenTierFor(int masteredCount) {
  var current = kankenTiers.first;
  for (final t in kankenTiers) {
    if (masteredCount >= t.min) current = t;
  }
  return current;
}

KankenTier? nextKankenTierFor(int masteredCount) {
  for (final t in kankenTiers) {
    if (masteredCount < t.min) return t;
  }
  return null;
}

/// Heuristic top-percentile label for a marathon score (correct/total).
String marathonPercentile(int correct, int total) {
  if (total <= 0) return 'Top 90% est.';
  final rate = correct / total;
  if (rate >= 1.0) return 'Top 1% est.';
  if (rate >= 0.9) return 'Top 3% est.';
  if (rate >= 0.8) return 'Top 8% est.';
  if (rate >= 0.7) return 'Top 20% est.';
  if (rate >= 0.6) return 'Top 35% est.';
  if (rate >= 0.5) return 'Top 50% est.';
  if (rate >= 0.4) return 'Top 70% est.';
  return 'Top 85% est.';
}
