import 'dart:math';
import '../models/idiom.dart';

const int kStagesCount = 5;
const int kRoundsPerStage = 8;
const int kQuestionsPerRound = 10;
const int kTotalPlannedQuestions =
    kStagesCount * kRoundsPerStage * kQuestionsPerRound; // 400

const List<String> kStageTitles = [
  'ステージ 1 / 入門',
  'ステージ 2 / 初級',
  'ステージ 3 / 中級',
  'ステージ 4 / 上級',
  'ステージ 5 / 達人',
];

const List<String> kStageSubtitles = [
  '基礎の四字熟語',
  '中学〜高校で学ぶ定番',
  '一般教養レベル',
  '漢検準1級相当',
  '漢検1級以上',
];

/// Minimum correct answers needed to clear a round. 3 or fewer = fail.
const int kMinCorrectToClear = 4;

bool roundFailed({required int correct}) => correct < kMinCorrectToClear;

/// Stars awarded for a round: 10/10 → 5 stars, then -1 star per 2 wrong.
/// Fewer than [kMinCorrectToClear] correct is a clear failure → 0 stars.
int starsForRound({required int correct, int total = kQuestionsPerRound}) {
  if (correct < kMinCorrectToClear) return 0;
  final wrong = total - correct;
  if (wrong <= 0) return 5;
  return (5 - ((wrong + 1) ~/ 2)).clamp(0, 5);
}

class RoundRef {
  final int stageIndex; // 0..4
  final int roundIndex; // 0..7
  const RoundRef(this.stageIndex, this.roundIndex);

  String get key => 'round_${stageIndex}_$roundIndex';
}

class StagePlan {
  final List<List<List<Idiom>>> stageRounds;

  const StagePlan(this.stageRounds);

  int get stageCount => stageRounds.length;
  int roundsIn(int stage) => stageRounds[stage].length;
  List<Idiom> idiomsFor(RoundRef r) =>
      stageRounds[r.stageIndex][r.roundIndex];

  static StagePlan build(List<Idiom> pool) {
    // Sort by difficulty ascending with a stable fallback on idiom string
    // so the plan is deterministic across runs.
    final sorted = [...pool]
      ..sort((a, b) {
        final c = a.difficulty.compareTo(b.difficulty);
        if (c != 0) return c;
        return a.idiom.compareTo(b.idiom);
      });
    final needed = kTotalPlannedQuestions;
    final take = sorted.length >= needed ? sorted.sublist(0, needed) : sorted;

    final perStage = take.length ~/ kStagesCount;
    final stages = <List<List<Idiom>>>[];
    for (int s = 0; s < kStagesCount; s++) {
      final start = s * perStage;
      final end = s == kStagesCount - 1 ? take.length : start + perStage;
      final stageIdioms = [...take.sublist(start, end)]
        ..shuffle(Random(1000 + s));
      // Split into rounds of kQuestionsPerRound.
      final rounds = <List<Idiom>>[];
      for (int r = 0; r < kRoundsPerStage; r++) {
        final a = r * kQuestionsPerRound;
        if (a >= stageIdioms.length) break;
        final b = (a + kQuestionsPerRound).clamp(0, stageIdioms.length);
        rounds.add(stageIdioms.sublist(a, b));
      }
      stages.add(rounds);
    }
    return StagePlan(stages);
  }
}
