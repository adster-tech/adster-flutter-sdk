import 'dart:ui';

class AdsterBannerAdCallback {
  final VoidCallback onAdClicked;
  final VoidCallback onAdImpression;
  final Function(
    double? revenue,
    String? adUnitId,
    String? network,
  )
  onAdRevenuePaid;

  AdsterBannerAdCallback({
    required this.onAdClicked,
    required this.onAdImpression,
    required this.onAdRevenuePaid,
  });
}
