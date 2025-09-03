import 'dart:ui';

class AdsterAppOpnenedAdCallback {
  final VoidCallback onAdClicked;
  final VoidCallback onAdImpression;
  final VoidCallback onAdOpened;
  final VoidCallback onAdClosed;
  final void Function(int errorCode, String errorMessage) onFailure;
  final Function(double? revenue, String? adUnitId, String? network)? onAdRevenuePaid;

  AdsterAppOpnenedAdCallback({
    required this.onAdClicked,
    required this.onAdImpression,
    required this.onAdOpened,
    required this.onAdClosed,
    required this.onAdRevenuePaid,
    required this.onFailure,
  });
}
