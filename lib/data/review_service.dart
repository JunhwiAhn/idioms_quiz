import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Asks for a Play Store rating at the one moment a learner is most likely to
/// give a good one: right after a perfect round.
///
/// The store listing has no ratings at all, which is the single biggest gap in
/// its search ranking — Play has no quality signal to rank on. Users almost
/// never navigate to the store on their own, so the ask has to happen in-app.
///
/// Play throttles its own review dialog and silently does nothing when the
/// quota is spent, so a single attempt would often be wasted without the user
/// ever seeing anything. Hence a small number of attempts, spread over
/// different days, each one gated on a genuinely good moment.
class ReviewService {
  ReviewService._();
  static final ReviewService instance = ReviewService._();

  static const String _kAttempts = 'review_prompt_attempts';
  static const String _kLastDate = 'review_prompt_last_date';
  static const String _kDone = 'review_prompt_done';

  /// Total times the dialog may be requested across the app's lifetime.
  static const int _maxAttempts = 3;

  /// Rounds that must be cleared before asking at all — someone who has played
  /// two rounds has no basis for a rating yet.
  static const int _minClearedRounds = 3;

  /// Stars the round must earn to count as a good moment. Perfect rounds alone
  /// are too rare at this install base to ever surface the dialog.
  static const int _minStars = 4;

  final InAppReview _review = InAppReview.instance;

  /// Test seam: overridden in unit tests so no platform channel is touched.
  static Future<bool> Function()? debugIsAvailable;
  static Future<void> Function()? debugRequestReview;

  /// Call after a round result is on screen.
  ///
  /// [stars] is the star count for the round just played, [clearedRounds] the
  /// number of rounds cleared so far. Returns true when the request was
  /// actually handed to the platform.
  Future<bool> maybeAskAfterRound({
    required int? stars,
    required int clearedRounds,
  }) async {
    if (stars == null || stars < _minStars) return false;
    if (clearedRounds < _minClearedRounds) return false;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kDone) ?? false) return false;

    final attempts = prefs.getInt(_kAttempts) ?? 0;
    if (attempts >= _maxAttempts) return false;

    // At most one ask per day, so a session of perfect rounds asks only once.
    final today = _today();
    if (prefs.getString(_kLastDate) == today) return false;

    final available = await (debugIsAvailable?.call() ?? _review.isAvailable());
    if (!available) return false;

    await prefs.setInt(_kAttempts, attempts + 1);
    await prefs.setString(_kLastDate, today);
    if (attempts + 1 >= _maxAttempts) await prefs.setBool(_kDone, true);

    await (debugRequestReview?.call() ?? _review.requestReview());
    return true;
  }

  /// Marks the flow finished, e.g. after the user reaches the listing another
  /// way. Nothing else should ask again.
  Future<void> markDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDone, true);
  }

  /// Opens the Play listing so the learner can rate on demand. Also stops the
  /// automatic prompt, since anyone who came here has already been asked.
  /// Returns false when no store app could be opened.
  Future<bool> openStoreListing() async {
    try {
      await (debugOpenStoreListing?.call() ??
          _review.openStoreListing(appStoreId: _appStoreId));
      await markDone();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// iOS only; harmless on Android, where the package id is used instead.
  static const String _appStoreId = '';

  /// Test seam, as above.
  static Future<void> Function()? debugOpenStoreListing;

  static String _today() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }
}
