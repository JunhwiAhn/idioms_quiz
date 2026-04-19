import 'package:shared_preferences/shared_preferences.dart';
import 'rank.dart';

enum HintKind { fiftyFifty, reading, kanji }

String _hintKey(HintKind k) => switch (k) {
      HintKind.fiftyFifty => 'hint_5050',
      HintKind.reading => 'hint_reading',
      HintKind.kanji => 'hint_kanji',
    };

class RunOutcome {
  final int earned;
  final int newTotalPoints;
  final Rank previousRank;
  final Rank newRank;
  final bool leveledUp;
  final Map<HintKind, int> hintDrops;

  const RunOutcome({
    required this.earned,
    required this.newTotalPoints,
    required this.previousRank,
    required this.newRank,
    required this.leveledUp,
    required this.hintDrops,
  });

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
  final Map<HintKind, int> hints;
  final Set<String> mastered;

  const ScoreSnapshot({
    required this.points,
    required this.totalAnswered,
    required this.totalCorrect,
    required this.bestStreak,
    required this.rank,
    required this.next,
    required this.progress,
    required this.hints,
    required this.mastered,
  });
}

class ScoreService {
  static const _kAchievement = 'achievement_points';
  static const _kTotalAnswered = 'total_answered';
  static const _kTotalCorrect = 'total_correct';
  static const _kBestStreak = 'best_streak';
  static const _kMastered = 'mastered_idioms';

  Future<ScoreSnapshot> snapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final correct = prefs.getInt(_kTotalCorrect) ?? 0;
    final rank = rankFor(correct);
    final next = nextRankFor(correct);
    final hints = {
      for (final k in HintKind.values) k: prefs.getInt(_hintKey(k)) ?? 0,
    };
    return ScoreSnapshot(
      points: prefs.getInt(_kAchievement) ?? 0,
      totalAnswered: prefs.getInt(_kTotalAnswered) ?? 0,
      totalCorrect: correct,
      bestStreak: prefs.getInt(_kBestStreak) ?? 0,
      rank: rank,
      next: next,
      progress: rankProgress(correct),
      hints: hints,
      mastered: (prefs.getStringList(_kMastered) ?? const []).toSet(),
    );
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

    final mastered = (prefs.getStringList(_kMastered) ?? const []).toSet();
    mastered.addAll(correctIdioms);
    await prefs.setStringList(_kMastered, mastered.toList());

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
    final leveledUp = newRank.level > prevRank.level;

    return RunOutcome(
      earned: earned,
      newTotalPoints: newPoints,
      previousRank: prevRank,
      newRank: newRank,
      leveledUp: leveledUp,
      hintDrops: hintDrops,
    );
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
    if (prefs.getBool('starter_granted') == true) return;
    for (final k in HintKind.values) {
      await prefs.setInt(_hintKey(k), 2);
    }
    await prefs.setBool('starter_granted', true);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      _kAchievement,
      _kTotalAnswered,
      _kTotalCorrect,
      _kBestStreak,
      _kMastered,
      'starter_granted',
      for (final k in HintKind.values) _hintKey(k),
    ];
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}
