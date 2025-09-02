import 'dart:ui';

import 'package:adster_flutter_sdk/core/asdter_typedefs.dart';

class AdsterInterstitialAdsCallback {
  final VoidCallback onAdClicked;
  final VoidCallback onAdImpression;
  final VoidCallback onAdOpened;
  final VoidCallback onAdClosed;
  final void Function(AdsterAdsException error)?
  onAdFailToPresentFullScreenContentWithError;

  AdsterInterstitialAdsCallback({
    required this.onAdClicked,
    required this.onAdImpression,
    required this.onAdOpened,
    required this.onAdClosed,
    this.onAdFailToPresentFullScreenContentWithError,
  });
}
