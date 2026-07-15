class KankenTier {
  final int min;
  final String label;
  final String subtitle;

  const KankenTier({
    required this.min,
    required this.label,
    required this.subtitle,
  });
}

/// Gamified tiers based on mastered Spanish vocabulary count.
const kankenTiers = <KankenTier>[
  KankenTier(min: 0,   label: 'A1 Starter', subtitle: 'Core survival words'),
  KankenTier(min: 10,  label: 'A1 Explorer', subtitle: 'Daily-life vocabulary'),
  KankenTier(min: 25,  label: 'A2 Builder', subtitle: 'Travel and routine words'),
  KankenTier(min: 45,  label: 'B1 Speaker', subtitle: 'Opinions and experiences'),
  KankenTier(min: 65,  label: 'B2 Analyst', subtitle: 'Abstract and news vocabulary'),
  KankenTier(min: 85,  label: 'DELE Pro', subtitle: 'Exam-ready vocabulary'),
  KankenTier(min: 100, label: 'DELE Master', subtitle: 'Complete mastery track'),
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
