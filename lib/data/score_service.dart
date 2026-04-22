import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'rank.dart';

const int kMasteryThreshold = 1;

enum HintKind { fiftyFifty, reading, time }

String _hintKey(HintKind k) => switch (k) {
      HintKind.fiftyFifty => 'hint_5050',
      HintKind.reading => 'hint_reading',
      HintKind.time => 'hint_time',
    };

class RunOutcome {
  final int earned;
  final int newTotalPoints;
  final Rank previousRank;
  final Rank newRank;
  final bool rankUp;
  final int previousLevel;
  final int newLevel;
  final int newTotalCorrect;
  final Map<HintKind, int> hintDrops;
  final bool marathonBestUpdated;
  final int previousBestMarathon;
  final int newBestMarathon;
  final int newBestMarathonTotal;
  // Round-mode specifics (0..5). Null when not a stage-round run.
  final int? roundStars;
  final int? previousRoundStars;
  final int? roundStageIndex;
  final int? roundRoundIndex;

  const RunOutcome({
    required this.earned,
    required this.newTotalPoints,
    required this.previousRank,
    required this.newRank,
    required this.rankUp,
    required this.previousLevel,
    required this.newLevel,
    required this.newTotalCorrect,
    required this.hintDrops,
    this.marathonBestUpdated = false,
    this.previousBestMarathon = 0,
    this.newBestMarathon = 0,
    this.newBestMarathonTotal = 0,
    this.roundStars,
    this.previousRoundStars,
    this.roundStageIndex,
    this.roundRoundIndex,
  });

  bool get isRoundRun => roundStars != null;
  bool get roundStarsImproved =>
      isRoundRun && roundStars! > (previousRoundStars ?? 0);

  bool get leveledUp => newLevel > previousLevel;
  int get levelsGained => newLevel - previousLevel;
  int get totalDropped =>
      hintDrops.values.fold(0, (a, b) => a + b);
}

class ScoreSnapshot {
  final int points;
  final int totalAnswered;
  final int totalCorrect;
  final int bestStreak;
  final Rank rank;
  final Rank? next;
  final double progress;
  final int level;
  final int remainingToNextLevel;
  final double levelProgress;
  final Map<HintKind, int> hints;
  final Set<String> mastered;
  // Per-idiom correct counts (0 if never answered correctly)
  final Map<String, int> correctCounts;
  final int bestMarathonScore;
  final int bestMarathonTotal;
  final int lastMarathonScore;
  final int lastMarathonTotal;
  // key "{stage}_{round}" → best star count (0..5)
  final Map<String, int> roundStars;

  const ScoreSnapshot({
    required this.points,
    required this.totalAnswered,
    required this.totalCorrect,
    required this.bestStreak,
    required this.rank,
    required this.next,
    required this.progress,
    required this.level,
    required this.remainingToNextLevel,
    required this.levelProgress,
    required this.hints,
    required this.mastered,
    required this.correctCounts,
    required this.bestMarathonScore,
    required this.bestMarathonTotal,
    required this.lastMarathonScore,
    required this.lastMarathonTotal,
    required this.roundStars,
  });

  int correctCountFor(String idiom) => correctCounts[idiom] ?? 0;

  bool get hasMarathonRecord => bestMarathonTotal > 0;

  int starsInStage(int stageIndex) {
    var sum = 0;
    final prefix = '${stageIndex}_';
    for (final e in roundStars.entries) {
      if (e.key.startsWith(prefix)) sum += e.value;
    }
    return sum;
  }

  int starsForRound(int stageIndex, int roundIndex) =>
      roundStars['${stageIndex}_$roundIndex'] ?? 0;
}

class ScoreService {
  static const _kAchievement = 'achievement_points';
  static const _kTotalAnswered = 'total_answered';
  static const _kTotalCorrect = 'total_correct';
  static const _kBestStreak = 'best_streak';
  static const _kMastered = 'mastered_idioms';
  static const _kCorrectCounts = 'correct_counts_json';
  static const _kBestMarathon = 'best_marathon_score';
  static const _kBestMarathonTotal = 'best_marathon_total';
  static const _kLastMarathon = 'last_marathon_score';
  static const _kLastMarathonTotal = 'last_marathon_total';
  static const _kRoundStarsPrefix = 'round_stars_';

  Future<ScoreSnapshot> snapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final correct = prefs.getInt(_kTotalCorrect) ?? 0;
    final rank = rankFor(correct);
    final next = nextRankFor(correct);
    final hints = {
      for (final k in HintKind.values) k: prefs.getInt(_hintKey(k)) ?? 0,
    };
    final roundStars = <String, int>{};
    for (final key in prefs.getKeys()) {
      if (key.startsWith(_kRoundStarsPrefix)) {
        final suffix = key.substring(_kRoundStarsPrefix.length);
        roundStars[suffix] = prefs.getInt(key) ?? 0;
      }
    }
    final counts = await _loadCorrectCounts(prefs);
    final mastered = {
      for (final e in counts.entries)
        if (e.value >= kMasteryThreshold) e.key,
    };
    return ScoreSnapshot(
      points: prefs.getInt(_kAchievement) ?? 0,
      totalAnswered: prefs.getInt(_kTotalAnswered) ?? 0,
      totalCorrect: correct,
      bestStreak: prefs.getInt(_kBestStreak) ?? 0,
      rank: rank,
      next: next,
      progress: rankProgress(correct),
      level: levelFor(correct),
      remainingToNextLevel: remainingToNextLevel(correct),
      levelProgress: levelProgress(correct),
      hints: hints,
      mastered: mastered,
      correctCounts: counts,
      bestMarathonScore: prefs.getInt(_kBestMarathon) ?? 0,
      bestMarathonTotal: prefs.getInt(_kBestMarathonTotal) ?? 0,
      lastMarathonScore: prefs.getInt(_kLastMarathon) ?? 0,
      lastMarathonTotal: prefs.getInt(_kLastMarathonTotal) ?? 0,
      roundStars: roundStars,
    );
  }

  Future<Map<String, int>> _loadCorrectCounts(
    SharedPreferences prefs,
  ) async {
    final raw = prefs.getString(_kCorrectCounts);
    if (raw != null && raw.isNotEmpty) {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      return {for (final e in decoded.entries) e.key: (e.value as num).toInt()};
    }
    // Migrate legacy _kMastered set → counts at threshold so existing
    // mastered idioms stay mastered under the new system.
    final legacy = prefs.getStringList(_kMastered);
    if (legacy == null || legacy.isEmpty) return <String, int>{};
    final migrated = {for (final k in legacy) k: kMasteryThreshold};
    await prefs.setString(_kCorrectCounts, json.encode(migrated));
    await prefs.remove(_kMastered);
    return migrated;
  }

  Future<int> getRoundStars(int stageIndex, int roundIndex) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_kRoundStarsPrefix${stageIndex}_$roundIndex') ?? 0;
  }

  /// Save round stars (keeps the max).
  Future<void> saveRoundStars(
    int stageIndex,
    int roundIndex,
    int stars,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_kRoundStarsPrefix${stageIndex}_$roundIndex';
    final cur = prefs.getInt(key) ?? 0;
    if (stars > cur) await prefs.setInt(key, stars);
  }

  /// Commit a finished run. Points: +10 per correct, streak bonus +2×longest
  /// when longestStreak >= 3. Hint drops were rolled per-correct-answer and
  /// are already counted; we persist them here.
  Future<RunOutcome> commitRun({
    required int correct,
    required int total,
    required int longestStreak,
    required Iterable<String> correctIdioms,
    required Iterable<HintKind> droppedHints,
    bool isMarathon = false,
    int? roundStageIndex,
    int? roundRoundIndex,
    int? roundStars,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final prevCorrect = prefs.getInt(_kTotalCorrect) ?? 0;
    final prevRank = rankFor(prevCorrect);

    final earned = correct * 10 + (longestStreak >= 3 ? longestStreak * 2 : 0);
    final newPoints = (prefs.getInt(_kAchievement) ?? 0) + earned;
    await prefs.setInt(_kAchievement, newPoints);

    final newCorrect = prevCorrect + correct;
    await prefs.setInt(_kTotalCorrect, newCorrect);
    await prefs.setInt(
      _kTotalAnswered,
      (prefs.getInt(_kTotalAnswered) ?? 0) + total,
    );

    final best = prefs.getInt(_kBestStreak) ?? 0;
    if (longestStreak > best) {
      await prefs.setInt(_kBestStreak, longestStreak);
    }

    final counts = await _loadCorrectCounts(prefs);
    for (final idiom in correctIdioms) {
      counts[idiom] = (counts[idiom] ?? 0) + 1;
    }
    await prefs.setString(_kCorrectCounts, json.encode(counts));

    final hintDrops = <HintKind, int>{
      for (final k in HintKind.values) k: 0,
    };
    for (final k in droppedHints) {
      hintDrops[k] = (hintDrops[k] ?? 0) + 1;
    }
    for (final entry in hintDrops.entries) {
      if (entry.value == 0) continue;
      final cur = prefs.getInt(_hintKey(entry.key)) ?? 0;
      await prefs.setInt(_hintKey(entry.key), cur + entry.value);
    }

    final newRank = rankFor(newCorrect);
    final rankUp = newRank.level > prevRank.level;

    var marathonBestUpdated = false;
    final prevBest = prefs.getInt(_kBestMarathon) ?? 0;
    final prevBestTotal = prefs.getInt(_kBestMarathonTotal) ?? 0;
    var newBest = prevBest;
    var newBestTotal = prevBestTotal;
    if (isMarathon) {
      await prefs.setInt(_kLastMarathon, correct);
      await prefs.setInt(_kLastMarathonTotal, total);
      // Compare by rate so different totals can be meaningfully compared.
      final prevRate = prevBestTotal == 0 ? 0.0 : prevBest / prevBestTotal;
      final curRate = total == 0 ? 0.0 : correct / total;
      if (curRate > prevRate || (curRate == prevRate && correct > prevBest)) {
        marathonBestUpdated = true;
        newBest = correct;
        newBestTotal = total;
        await prefs.setInt(_kBestMarathon, correct);
        await prefs.setInt(_kBestMarathonTotal, total);
      }
    }

    int? prevRoundStars;
    if (roundStageIndex != null &&
        roundRoundIndex != null &&
        roundStars != null) {
      final key =
          '$_kRoundStarsPrefix${roundStageIndex}_$roundRoundIndex';
      prevRoundStars = prefs.getInt(key) ?? 0;
      if (roundStars > prevRoundStars) {
        await prefs.setInt(key, roundStars);
      }
    }

    return RunOutcome(
      earned: earned,
      newTotalPoints: newPoints,
      previousRank: prevRank,
      newRank: newRank,
      rankUp: rankUp,
      previousLevel: levelFor(prevCorrect),
      newLevel: levelFor(newCorrect),
      newTotalCorrect: newCorrect,
      hintDrops: hintDrops,
      marathonBestUpdated: marathonBestUpdated,
      previousBestMarathon: prevBest,
      newBestMarathon: newBest,
      newBestMarathonTotal: newBestTotal,
      roundStars: roundStars,
      previousRoundStars: prevRoundStars,
      roundStageIndex: roundStageIndex,
      roundRoundIndex: roundRoundIndex,
    );
  }

  /// Grants a single hint of a random kind. Returns the kind that was given.
  Future<HintKind> grantRandomHint() async {
    final kinds = HintKind.values;
    final kind = kinds[Random().nextInt(kinds.length)];
    final prefs = await SharedPreferences.getInstance();
    final cur = prefs.getInt(_hintKey(kind)) ?? 0;
    await prefs.setInt(_hintKey(kind), cur + 1);
    return kind;
  }

  Future<bool> consumeHint(HintKind kind) async {
    final prefs = await SharedPreferences.getInstance();
    final cur = prefs.getInt(_hintKey(kind)) ?? 0;
    if (cur <= 0) return false;
    await prefs.setInt(_hintKey(kind), cur - 1);
    return true;
  }

  /// Debug helper — give the user an initial hint pack on first launch so
  /// the mechanic is discoverable. No-op if already granted.
  Future<void> grantStarterPackOnce() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('starter_granted') != true) {
      for (final k in HintKind.values) {
        await prefs.setInt(_hintKey(k), 2);
      }
      await prefs.setBool('starter_granted', true);
    }
    // Backfill for users who started before the time hint existed — only
    // runs once per user.
    if (prefs.getBool('time_hint_granted') != true) {
      final cur = prefs.getInt(_hintKey(HintKind.time)) ?? 0;
      if (cur < 2) await prefs.setInt(_hintKey(HintKind.time), 2);
      await prefs.setBool('time_hint_granted', true);
    }
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      _kAchievement,
      _kTotalAnswered,
      _kTotalCorrect,
      _kBestStreak,
      _kMastered,
      _kCorrectCounts,
      _kBestMarathon,
      _kBestMarathonTotal,
      _kLastMarathon,
      _kLastMarathonTotal,
      'starter_granted',
      for (final k in HintKind.values) _hintKey(k),
    ];
    for (final k in keys) {
      await prefs.remove(k);
    }
    for (final k in prefs.getKeys()) {
      if (k.startsWith(_kRoundStarsPrefix)) {
        await prefs.remove(k);
      }
    }
  }
}
