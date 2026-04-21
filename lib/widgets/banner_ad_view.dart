import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../data/ad_service.dart';

/// An adaptive banner that loads lazily and collapses to a plain spacer on
/// web (Google Mobile Ads has no web support yet) or when loading fails.
class BannerAdView extends StatefulWidget {
  const BannerAdView({super.key});

  @override
  State<BannerAdView> createState() => _BannerAdViewState();
}

class _BannerAdViewState extends State<BannerAdView> {
  BannerAd? _ad;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) _load();
  }

  Future<void> _load() async {
    final unitId = AdUnits.banner;
    if (unitId.isEmpty) {
      setState(() => _failed = true);
      return;
    }
    final ad = BannerAd(
      adUnitId: unitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          setState(() {});
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (!mounted) return;
          setState(() => _failed = true);
        },
      ),
    );
    try {
      await ad.load();
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
    _ad = ad;
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || _failed || _ad == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: _ad!.size.width.toDouble(),
      height: _ad!.size.height.toDouble(),
      child: AdWidget(ad: _ad!),
    );
  }
}
