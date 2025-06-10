import 'dart:ui';

class AdsterUnifiedCallback {
  final VoidCallback onAdClicked;
  final VoidCallback onAdImpression;

  AdsterUnifiedCallback({
    required this.onAdClicked,
    required this.onAdImpression,
  });
}
