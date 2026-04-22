import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob-backed AdService used on Android / iOS. Web builds never import
/// this file thanks to the conditional export in `ad_service.dart`.
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  /// Master kill-switch for ads. Flip to true after AdMob approval /
  /// before the first revenue release. While false, every public method
  /// no-ops via `isSupported` (banner empty, interstitial / rewarded
  /// buttons hidden) — implementation is preserved below.
  static const bool kAdsEnabled = false;

  bool get isSupported =>
      kAdsEnabled &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  // Google public test IDs. Replace with real units for production.
  static const _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const _testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  static const _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const _testInterstitialIos =
      'ca-app-pub-3940256099942544/4411468910';
  static const _testRewardedAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const _testRewardedIos =
      'ca-app-pub-3940256099942544/1712485313';

  String get _bannerUnitId =>
      defaultTargetPlatform == TargetPlatform.android
          ? _testBannerAndroid
          : _testBannerIos;

  String get _interstitialUnitId =>
      defaultTargetPlatform == TargetPlatform.android
          ? _testInterstitialAndroid
          : _testInterstitialIos;

  String get _rewardedUnitId =>
      defaultTargetPlatform == TargetPlatform.android
          ? _testRewardedAndroid
          : _testRewardedIos;

  bool _inited = false;
  bool _initing = false;

  Future<void> ensureInitialized() async {
    if (!isSupported || _inited || _initing) return;
    _initing = true;
    try {
      await MobileAds.instance.initialize();
      _inited = true;
    } catch (e) {
      if (kDebugMode) debugPrint('AdService init failed: $e');
    } finally {
      _initing = false;
    }
  }

  Widget buildBanner() {
    if (!isSupported) return const SizedBox.shrink();
    return _BannerAdWidget(unitId: _bannerUnitId);
  }

  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;
  int _roundsSinceLastAd = 0;

  Future<void> preloadInterstitial() async {
    if (!isSupported) return;
    if (_interstitial != null || _loadingInterstitial) return;
    _loadingInterstitial = true;
    try {
      await ensureInitialized();
      await InterstitialAd.load(
        adUnitId: _interstitialUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitial = ad;
            _loadingInterstitial = false;
          },
          onAdFailedToLoad: (error) {
            _interstitial = null;
            _loadingInterstitial = false;
            if (kDebugMode) debugPrint('Interstitial load failed: $error');
          },
        ),
      );
    } catch (e) {
      _loadingInterstitial = false;
      if (kDebugMode) debugPrint('Interstitial preload failed: $e');
    }
  }

  Future<void> maybeShowAfterRound({int frequency = 3}) async {
    if (!isSupported) return;
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
    } catch (e) {
      ad.dispose();
      if (kDebugMode) debugPrint('Interstitial show failed: $e');
    }
  }

  RewardedAd? _rewarded;
  bool _loadingRewarded = false;

  bool get isRewardedReady => _rewarded != null;

  Future<void> preloadRewarded() async {
    if (!isSupported) return;
    if (_rewarded != null || _loadingRewarded) return;
    _loadingRewarded = true;
    try {
      await ensureInitialized();
      await RewardedAd.load(
        adUnitId: _rewardedUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewarded = ad;
            _loadingRewarded = false;
          },
          onAdFailedToLoad: (error) {
            _rewarded = null;
            _loadingRewarded = false;
            if (kDebugMode) debugPrint('Rewarded load failed: $error');
          },
        ),
      );
    } catch (e) {
      _loadingRewarded = false;
      if (kDebugMode) debugPrint('Rewarded preload failed: $e');
    }
  }

  Future<bool> showRewarded() async {
    if (!isSupported) return false;
    var ad = _rewarded;
    if (ad == null) {
      await preloadRewarded();
      ad = _rewarded;
    }
    if (ad == null) return false;
    _rewarded = null;
    var earned = false;
    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completer.isCompleted) completer.complete(earned);
        unawaited(preloadRewarded());
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        if (!completer.isCompleted) completer.complete(false);
        unawaited(preloadRewarded());
      },
    );
    try {
      await ad.show(onUserEarnedReward: (_, _) {
        earned = true;
      });
    } catch (e) {
      if (!completer.isCompleted) completer.complete(false);
      if (kDebugMode) debugPrint('Rewarded show failed: $e');
    }
    return completer.future;
  }
}

class _BannerAdWidget extends StatefulWidget {
  final String unitId;
  const _BannerAdWidget({required this.unitId});

  @override
  State<_BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<_BannerAdWidget> {
  BannerAd? _ad;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await AdService.instance.ensureInitialized();
      final ad = BannerAd(
        adUnitId: widget.unitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            if (!mounted) return;
            setState(() {});
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            if (!mounted) return;
            setState(() => _failed = true);
            if (kDebugMode) debugPrint('Banner load failed: $error');
          },
        ),
      );
      await ad.load();
      if (!mounted) {
        ad.dispose();
        return;
      }
      setState(() => _ad = ad);
    } catch (e) {
      if (!mounted) return;
      setState(() => _failed = true);
      if (kDebugMode) debugPrint('Banner exception: $e');
    }
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed || _ad == null) return const SizedBox.shrink();
    return SizedBox(
      width: _ad!.size.width.toDouble(),
      height: _ad!.size.height.toDouble(),
      child: AdWidget(ad: _ad!),
    );
  }
}
