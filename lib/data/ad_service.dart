import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob ad unit IDs. Swap these for the real ones before production release.
/// For now we intentionally use Google's public test IDs so no accidental
/// real-impression traffic is generated while we are in development /
/// internal testing.
class AdUnits {
  // Google test IDs (banner / interstitial) — safe for development.
  static const String _testBannerAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIos =
      'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIos =
      'ca-app-pub-3940256099942544/4411468910';

  static String get banner =>
      kIsWeb ? '' : (Platform.isAndroid ? _testBannerAndroid : _testBannerIos);
  static String get interstitial => kIsWeb
      ? ''
      : (Platform.isAndroid
          ? _testInterstitialAndroid
          : _testInterstitialIos);
}

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _initialized = false;
  bool get supported => !kIsWeb;

  Future<void> init() async {
    if (_initialized) return;
    if (!supported) {
      _initialized = true;
      return;
    }
    try {
      await MobileAds.instance.initialize();
    } catch (_) {
      // Ads failing to init should never crash the app.
    }
    _initialized = true;
  }

  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;
  int _roundsSinceLastAd = 0;

  /// Preload the next interstitial so it's ready to show instantly.
  Future<void> preloadInterstitial() async {
    if (!supported) return;
    if (_interstitial != null || _loadingInterstitial) return;
    _loadingInterstitial = true;
    try {
      await InterstitialAd.load(
        adUnitId: AdUnits.interstitial,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitial = ad;
            _loadingInterstitial = false;
          },
          onAdFailedToLoad: (error) {
            _interstitial = null;
            _loadingInterstitial = false;
            if (kDebugMode) {
              // ignore: avoid_print
              print('Interstitial failed to load: $error');
            }
          },
        ),
      );
    } catch (_) {
      _loadingInterstitial = false;
    }
  }

  /// Count a completed round and show an interstitial every N rounds.
  Future<void> maybeShowAfterRound({int frequency = 3}) async {
    if (!supported) return;
    _roundsSinceLastAd++;
    if (_roundsSinceLastAd < frequency) {
      unawaited(preloadInterstitial());
      return;
    }
    final ad = _interstitial;
    if (ad == null) {
      unawaited(preloadInterstitial());
      return;
    }
    _interstitial = null;
    _roundsSinceLastAd = 0;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        unawaited(preloadInterstitial());
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        unawaited(preloadInterstitial());
      },
    );
    try {
      await ad.show();
    } catch (_) {
      ad.dispose();
    }
  }
}

/// `unawaited` without importing dart:async.
void unawaited(Future<void> future) {}
