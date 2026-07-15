import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const _androidReleaseBannerAdUnitId = 'ca-app-pub-1633662132825683/8303811636';
const _androidReleaseInterstitialAdUnitId =
    'ca-app-pub-1633662132825683/7740292166';
const _androidReleaseRewardedAdUnitId =
    'ca-app-pub-1633662132825683/1024087410';
const _androidTestBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
const _iosTestBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716';
const _androidTestInterstitialAdUnitId =
    'ca-app-pub-3940256099942544/1033173712';
const _iosTestInterstitialAdUnitId = 'ca-app-pub-3940256099942544/4411468910';
const _androidTestRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
const _iosTestRewardedAdUnitId = 'ca-app-pub-3940256099942544/1712485313';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  Future<void>? _initializeFuture;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  final ValueNotifier<bool> _rewardedReady = ValueNotifier(false);
  int _roundCounter = 0;
  bool _canRequestAds = false;

  bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  bool get canRequestAds => _canRequestAds;

  bool get isRewardedReady => isSupported && _rewardedAd != null;
  ValueListenable<bool> get rewardedReadyListenable => _rewardedReady;

  Future<void> ensureInitialized() {
    if (!isSupported) return Future.value();
    return _initializeFuture ??= _initializeWithConsent();
  }

  /// Gathers UMP consent (GDPR form in required regions), then initializes
  /// the Mobile Ads SDK only when ads may legally be requested.
  Future<void> _initializeWithConsent() async {
    final consentGathered = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        ConsentForm.loadAndShowConsentFormIfRequired((formError) {
          if (formError != null && kDebugMode) {
            debugPrint('Consent form error: $formError');
          }
          if (!consentGathered.isCompleted) consentGathered.complete();
        });
      },
      (updateError) {
        if (kDebugMode) debugPrint('Consent update error: $updateError');
        if (!consentGathered.isCompleted) consentGathered.complete();
      },
    );
    await consentGathered.future;

    _canRequestAds = await ConsentInformation.instance.canRequestAds();
    if (!_canRequestAds) return;
    await MobileAds.instance.initialize();
  }

  Widget buildBanner() {
    if (!isSupported) return const SizedBox.shrink();
    return const _AdMobBanner();
  }

  Future<void> preloadInterstitial() async {
    final adUnitId = _interstitialAdUnitId;
    if (!isSupported || _interstitialAd != null || adUnitId == null) return;
    await ensureInitialized();
    if (!_canRequestAds) return;
    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          if (kDebugMode) debugPrint('Interstitial load failed: $error');
        },
      ),
    );
  }

  Future<void> maybeShowAfterRound({int frequency = 3}) async {
    if (!isSupported || !_canRequestAds || frequency <= 0) return;
    _roundCounter++;
    if (_roundCounter % frequency != 0) return;
    final ad = _interstitialAd;
    if (ad == null) {
      preloadInterstitial();
      return;
    }
    _interstitialAd = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        preloadInterstitial();
      },
    );
    await ad.show();
  }

  Future<void> preloadRewarded() async {
    final adUnitId = _rewardedAdUnitId;
    if (!isSupported || adUnitId == null) return;
    if (_rewardedAd != null) {
      _rewardedReady.value = true;
      return;
    }
    await ensureInitialized();
    if (!_canRequestAds) return;
    await RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedReady.value = true;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _rewardedReady.value = false;
          if (kDebugMode) debugPrint('Rewarded load failed: $error');
        },
      ),
    );
  }

  Future<bool> showRewarded() async {
    if (!isSupported) return false;
    if (_rewardedAd == null) {
      await preloadRewarded();
    }
    final ad = _rewardedAd;
    if (ad == null) return false;

    final completer = Completer<bool>();
    var earned = false;
    _rewardedAd = null;
    _rewardedReady.value = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preloadRewarded();
        if (!completer.isCompleted) completer.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        preloadRewarded();
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    await ad.show(
      onUserEarnedReward: (_, _) {
        earned = true;
      },
    );
    return completer.future;
  }

  String get _bannerAdUnitId {
    if (Platform.isAndroid && kReleaseMode) {
      return _androidReleaseBannerAdUnitId;
    }
    return Platform.isIOS ? _iosTestBannerAdUnitId : _androidTestBannerAdUnitId;
  }

  String? get _interstitialAdUnitId {
    if (Platform.isAndroid && kReleaseMode) {
      return _androidReleaseInterstitialAdUnitId;
    }
    if (kReleaseMode) return null;
    return Platform.isIOS
        ? _iosTestInterstitialAdUnitId
        : _androidTestInterstitialAdUnitId;
  }

  String? get _rewardedAdUnitId {
    if (Platform.isAndroid && kReleaseMode) {
      return _androidReleaseRewardedAdUnitId;
    }
    if (kReleaseMode) return null;
    return Platform.isIOS
        ? _iosTestRewardedAdUnitId
        : _androidTestRewardedAdUnitId;
  }
}

class _AdMobBanner extends StatefulWidget {
  const _AdMobBanner();

  @override
  State<_AdMobBanner> createState() => _AdMobBannerState();
}

class _AdMobBannerState extends State<_AdMobBanner> {
  BannerAd? _ad;
  bool _loaded = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await AdService.instance.ensureInitialized();
    if (!mounted) return;
    if (!AdService.instance.canRequestAds) {
      setState(() => _failed = true);
      return;
    }
    final ad = BannerAd(
      adUnitId: AdService.instance._bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          setState(() => _failed = true);
          if (kDebugMode) debugPrint('Banner load failed: $error');
        },
      ),
    );
    _ad = ad;
    await ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return const SizedBox.shrink();
    final ad = _ad;
    return SizedBox(
      width: AdSize.banner.width.toDouble(),
      height: AdSize.banner.height.toDouble(),
      child: _loaded && ad != null
          ? AdWidget(ad: ad)
          : const Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
    );
  }
}
