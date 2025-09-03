import 'dart:ui';

class AdsterUnifiedCallback {
  final VoidCallback onAdClicked;
  final VoidCallback onAdImpression;
  final Function(double? revenue, String? adUnitId, String? network)? onAdRevenuePaid;

  AdsterUnifiedCallback({
    required this.onAdClicked,
    required this.onAdImpression,
    required this.onAdRevenuePaid,
  });
}
