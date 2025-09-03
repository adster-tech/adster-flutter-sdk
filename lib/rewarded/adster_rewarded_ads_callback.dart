import 'dart:ui';

import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';

class AdsterRewardedAdCallback {
  final VoidCallback onAdClicked;
  final VoidCallback onAdImpression;
  final void Function(int? rewardAmount) onUserEarnedReward;
  final VoidCallback onVideoComplete;
  final VoidCallback onVideoClosed;
  final VoidCallback onVideoStart;
  final void Function(AdsterAdsException error)?
  onAdFailToPresentFullScreenContentWithError;
  final Function(double? revenue, String? adUnitId, String? network)? onAdRevenuePaid;

  AdsterRewardedAdCallback({
    required this.onAdClicked,
    required this.onAdImpression,
    required this.onUserEarnedReward,
    required this.onVideoComplete,
    required this.onVideoClosed,
    required this.onVideoStart,
    required this.onAdRevenuePaid,
    this.onAdFailToPresentFullScreenContentWithError,
  });
}
