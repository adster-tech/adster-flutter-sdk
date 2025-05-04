import 'dart:ui';

class AdsterNativeAdCallback {
  VoidCallback? onAdClicked;
  VoidCallback? onAdImpression;

  AdsterNativeAdCallback({
    this.onAdClicked,
    this.onAdImpression,
  });
}
