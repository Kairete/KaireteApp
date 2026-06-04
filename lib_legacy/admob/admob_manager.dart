import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobManager {
  static final AdMobManager _instance = AdMobManager._internal();

  factory AdMobManager() {
    return _instance;
  }

  AdMobManager._internal();

  static const String _adUnitId = 'ca-app-pub-0945043098388339/8117697237';

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  void initialize() {
    MobileAds.instance.initialize();
  }

  // Banner Ad
  void loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('Banner ad loaded.');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
          print('Banner ad failed to load: $error');
        },
      ),
    )..load();
  }

  Widget getBannerAdWidget() {
    if (_bannerAd != null) {
      return Container(
        alignment: Alignment.center,
        child: AdWidget(ad: _bannerAd!),
        width: double.infinity,
        height: _bannerAd!.size.height.toDouble(),
      );
    } else {
      return SizedBox.shrink(); // Không hiển thị gì nếu chưa load quảng cáo
    }
  }

  // Interstitial Ad
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          print('Interstitial ad loaded.');
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Interstitial ad failed to load: $error');
        },
      ),
    );
  }

  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      print('Interstitial ad is not ready yet.');
    }
  }
}
