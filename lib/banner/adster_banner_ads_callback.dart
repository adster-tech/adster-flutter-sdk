import 'dart:ui';

import 'package:adster_flutter_sdk/core/adster_revenue.dart';

class AdsterBannerAdCallback {
  final VoidCallback onAdClicked;
  final VoidCallback onAdImpression;
  final AdsterRevenueCallback onAdRevenuePaid;

  AdsterBannerAdCallback({
    required this.onAdClicked,
    required this.onAdImpression,
    required this.onAdRevenuePaid,
  });
}
