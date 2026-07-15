import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// No-op AdService for platforms without AdMob support (web, desktop).
/// Matches the surface of the mobile implementation but does nothing.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool get isSupported => false;
  bool get canRequestAds => false;
  final ValueNotifier<bool> _rewardedReady = ValueNotifier(false);
  ValueListenable<bool> get rewardedReadyListenable => _rewardedReady;

  Future<void> ensureInitialized() async {}

  Widget buildBanner() => const SizedBox.shrink();

  Future<void> preloadInterstitial() async {}

  Future<void> maybeShowAfterRound({int frequency = 3}) async {}

  Future<void> preloadRewarded() async {}

  bool get isRewardedReady => false;

  /// Returns true if the ad was shown AND the user earned the reward.
  /// Stub always returns false (ads aren't supported).
  Future<bool> showRewarded() async => false;
}
