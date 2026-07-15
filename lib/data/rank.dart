class Rank {
  final int level;
  final String name;
  final int threshold;
  final String imageAsset;
  final String cultureTitle;
  final String cultureDescription;

  const Rank({
    required this.level,
    required this.name,
    required this.threshold,
    required this.imageAsset,
    required this.cultureTitle,
    required this.cultureDescription,
  });
}

const String _spainRankImage = 'assets/images/rank_spain_emblem.png';

/// Ranks are unlocked once total_correct crosses the threshold.
const ranks = <Rank>[
  Rank(
    level: 1,
    name: 'Novato',
    threshold: 0,
    imageAsset: _spainRankImage,
    cultureTitle: '첫 학습 시작',
    cultureDescription: '새로운 단어를 익히며 랭크 여정을 시작했어요.',
  ),
  Rank(
    level: 2,
    name: 'Aprendiz',
    threshold: 10,
    imageAsset: _spainRankImage,
    cultureTitle: '플라멩코 리듬',
    cultureDescription: '부채와 춤 동작은 플라멩코의 리듬을 뜻해요. 꾸준히 맞히며 감각을 쌓아가요.',
  ),
  Rank(
    level: 3,
    name: 'Explorador',
    threshold: 30,
    imageAsset: _spainRankImage,
    cultureTitle: '지중해 광장',
    cultureDescription: '따뜻한 타일과 햇살 가득한 광장은 스페인의 일상 표현을 떠올리게 해요.',
  ),
  Rank(
    level: 4,
    name: 'Estudiante',
    threshold: 60,
    imageAsset: _spainRankImage,
    cultureTitle: '파에야 테이블',
    cultureDescription: '여러 재료가 어우러진 파에야처럼 단어, 예문, 문법 패턴을 함께 익혀요.',
  ),
  Rank(
    level: 5,
    name: 'Hablante',
    threshold: 100,
    imageAsset: _spainRankImage,
    cultureTitle: '스페인 기타',
    cultureDescription: '기타는 발음과 흐름을 상징해요. 이제 스페인어 회상이 리듬을 얻고 있어요.',
  ),
  Rank(
    level: 6,
    name: 'Viajero',
    threshold: 160,
    imageAsset: _spainRankImage,
    cultureTitle: '여행 표현',
    cultureDescription: '역, 카페, 시장, 거리에서 바로 쓸 수 있는 단어들이 늘어나는 단계예요.',
  ),
  Rank(
    level: 7,
    name: 'Conversador',
    threshold: 240,
    imageAsset: _spainRankImage,
    cultureTitle: '대화의 무대',
    cultureDescription: '단어 암기를 넘어 자연스러운 대화에 필요한 표현으로 확장하는 랭크예요.',
  ),
  Rank(
    level: 8,
    name: 'Intérprete',
    threshold: 340,
    imageAsset: _spainRankImage,
    cultureTitle: '뜻을 잇는 다리',
    cultureDescription: '한국어, 영어, 일본어와 스페인어 의미가 더 빠르게 연결되는 단계예요.',
  ),
  Rank(
    level: 9,
    name: 'Lingüista',
    threshold: 460,
    imageAsset: _spainRankImage,
    cultureTitle: '언어 패턴',
    cultureDescription: '어휘 기반이 넓어지며 문법 연결과 단어 계열이 더 선명하게 보이기 시작해요.',
  ),
  Rank(
    level: 10,
    name: 'Embajador',
    threshold: 600,
    imageAsset: _spainRankImage,
    cultureTitle: '문화 대사',
    cultureDescription: '자신 있는 학습 진도와 넓어진 어휘 인식을 보여줘요.',
  ),
  Rank(
    level: 11,
    name: 'Maestro',
    threshold: 760,
    imageAsset: _spainRankImage,
    cultureTitle: '숙련의 리듬',
    cultureDescription: '연습된 공연처럼 답변 속도, 기억력, 정확도가 안정적으로 올라온 단계예요.',
  ),
  Rank(
    level: 12,
    name: 'Sabio',
    threshold: 940,
    imageAsset: _spainRankImage,
    cultureTitle: '깊은 기억',
    cultureDescription: '단어, 뜻, 예문이 단기 암기를 지나 오래 남는 지식으로 자리 잡고 있어요.',
  ),
  Rank(
    level: 13,
    name: 'Gran Maestro',
    threshold: 1200,
    imageAsset: _spainRankImage,
    cultureTitle: '그란 마에스트로 엠블럼',
    cultureDescription: '꾸준한 퀴즈 숙련으로 얻는 최고 랭크의 완성 단계예요.',
  ),
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
