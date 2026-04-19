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

/// Thresholds are based on mastered idiom count out of the app's 100-idiom
/// pool, mapped loosely to 漢検 (Kanji Kentei) tier coverage.
/// Percentiles are labeled as "推定 (estimated)" — there is no single
/// authoritative public study for 四字熟語 distribution, so the values are a
/// heuristic calibration meant as gamification, not as research data.
const kankenTiers = <KankenTier>[
  KankenTier(min: 0,   label: '入門',    subtitle: '中学生レベル',       percentile: '推定 上位90%'),
  KankenTier(min: 10,  label: '初級',    subtitle: '高校生レベル',       percentile: '推定 上位70%'),
  KankenTier(min: 25,  label: '中級',    subtitle: '漢検3級相当',         percentile: '推定 上位50%'),
  KankenTier(min: 45,  label: '上級',    subtitle: '漢検2級相当',         percentile: '推定 上位25%'),
  KankenTier(min: 65,  label: '熟練',    subtitle: '漢検準1級相当',       percentile: '推定 上位10%'),
  KankenTier(min: 85,  label: '達人',    subtitle: '漢検1級相当',         percentile: '推定 上位3%'),
  KankenTier(min: 100, label: '師範',    subtitle: '全問制覇',             percentile: '推定 上位1%'),
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
  if (total <= 0) return '推定 上位90%';
  final rate = correct / total;
  if (rate >= 1.0) return '推定 上位1%';
  if (rate >= 0.9) return '推定 上位3%';
  if (rate >= 0.8) return '推定 上位8%';
  if (rate >= 0.7) return '推定 上位20%';
  if (rate >= 0.6) return '推定 上位35%';
  if (rate >= 0.5) return '推定 上位50%';
  if (rate >= 0.4) return '推定 上位70%';
  return '推定 上位85%';
}
