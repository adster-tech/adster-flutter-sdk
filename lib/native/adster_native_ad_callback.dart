import 'dart:ui';

import 'package:adster_flutter_sdk/core/adster_revenue.dart';

class AdsterNativeAdCallback {
  VoidCallback? onAdClicked;
  VoidCallback? onAdImpression;
  final AdsterRevenueCallback? onAdRevenuePaid;

  AdsterNativeAdCallback({
    this.onAdClicked,
    this.onAdImpression,
    this.onAdRevenuePaid,
  });
}
