import 'dart:ui';

import 'package:adster_flutter_sdk/core/adster_revenue.dart';

class AdsterAppOpenedAdCallback {
  final VoidCallback onAdClicked;
  final VoidCallback onAdImpression;
  final VoidCallback onAdOpened;
  final VoidCallback onAdClosed;
  final void Function(int errorCode, String errorMessage) onFailure;
  final AdsterRevenueCallback? onAdRevenuePaid;

  AdsterAppOpenedAdCallback({
    required this.onAdClicked,
    required this.onAdImpression,
    required this.onAdOpened,
    required this.onAdClosed,
    required this.onAdRevenuePaid,
    required this.onFailure,
  });
}
