import 'dart:ui';

class AdsterBannerAdCallback {
  final VoidCallback onAdClicked;
  final VoidCallback onAdImpression;

  AdsterBannerAdCallback({
    required this.onAdClicked,
    required this.onAdImpression,
  });
}
