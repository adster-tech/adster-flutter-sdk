import 'dart:ui';

class AdsterNativeAdCallback {
  VoidCallback? onAdClicked;
  VoidCallback? onAdImpression;
  final Function(double? revenue, String? adUnitId, String? network)? onAdRevenuePaid;

  AdsterNativeAdCallback({
    this.onAdClicked,
    this.onAdImpression,
    this.onAdRevenuePaid,
  });
}
