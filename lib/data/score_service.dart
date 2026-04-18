import 'package:shared_preferences/shared_preferences.dart';

class ScoreService {
  static const _kAchievement = 'achievement_points';
  static const _kTotalAnswered = 'total_answered';
  static const _kBestStreak = 'best_streak';

  Future<int> achievementPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kAchievement) ?? 0;
  }

  Future<int> totalAnswered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kTotalAnswered) ?? 0;
  }

  Future<int> bestStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kBestStreak) ?? 0;
  }

  /// Commit a finished quiz run. Returns the new achievement total.
  /// Each correct answer grants 10 points plus a 2-point bonus for being in a
  /// streak of 3 or more within the same session.
  Future<int> commitRun({
    required int correct,
    required int total,
    required int longestStreak,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_kAchievement) ?? 0;
    final earned = correct * 10 + (longestStreak >= 3 ? longestStreak * 2 : 0);
    final newTotal = current + earned;
    await prefs.setInt(_kAchievement, newTotal);

    final answered = (prefs.getInt(_kTotalAnswered) ?? 0) + total;
    await prefs.setInt(_kTotalAnswered, answered);

    final best = prefs.getInt(_kBestStreak) ?? 0;
    if (longestStreak > best) {
      await prefs.setInt(_kBestStreak, longestStreak);
    }
    return newTotal;
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAchievement);
    await prefs.remove(_kTotalAnswered);
    await prefs.remove(_kBestStreak);
  }
}

class RunReward {
  final int earned;
  final int newTotal;
  const RunReward({required this.earned, required this.newTotal});
}
