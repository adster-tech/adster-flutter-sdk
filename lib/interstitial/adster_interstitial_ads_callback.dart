import 'dart:ui';

import 'package:adster_flutter_sdk/core/asdter_typedefs.dart';
import 'package:adster_flutter_sdk/core/adster_revenue.dart';

class AdsterInterstitialAdsCallback {
  final VoidCallback onAdClicked;
  final VoidCallback onAdImpression;
  final VoidCallback onAdOpened;
  final VoidCallback onAdClosed;
  final void Function(AdsterAdsException error)?
  onAdFailToPresentFullScreenContentWithError;
  final AdsterRevenueCallback onAdRevenuePaid;

  AdsterInterstitialAdsCallback({
    required this.onAdClicked,
    required this.onAdImpression,
    required this.onAdOpened,
    required this.onAdClosed,
    required this.onAdRevenuePaid,
    this.onAdFailToPresentFullScreenContentWithError,
  });
}
