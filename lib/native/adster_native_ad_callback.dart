import 'dart:ui';

class AdsterNativeAdCallback {
  VoidCallback? onNativeAdLoaded;
  VoidCallback? onFailure;
  VoidCallback? onAdClicked;
  VoidCallback? onAdImpression;

  AdsterNativeAdCallback({
    this.onNativeAdLoaded,
    this.onFailure,
    this.onAdClicked,
    this.onAdImpression,
  });
}
