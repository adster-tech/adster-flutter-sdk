import 'dart:ui';

class AdsterInterstitialAdsCallback {
  final VoidCallback? onInterstitialAdLoaded;
  final VoidCallback? onFailure;
  final VoidCallback onAdClicked;
  final VoidCallback onAdImpression;
  final VoidCallback onAdOpened;
  final VoidCallback onAdClosed;

  AdsterInterstitialAdsCallback({
    this.onInterstitialAdLoaded,
    this.onFailure,
    required this.onAdClicked,
    required this.onAdImpression,
    required this.onAdOpened,
    required this.onAdClosed,
  });
}
