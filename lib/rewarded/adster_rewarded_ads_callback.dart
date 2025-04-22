import 'dart:ui';

class AdsterRewardedAdCallback {
  final VoidCallback? onRewardedAdLoaded;
  final VoidCallback? onFailure;
  final VoidCallback onAdClicked;
  final VoidCallback onAdImpression;
  final void Function(int? rewardAmount) onUserEarnedReward;
  final VoidCallback onVideoComplete;
  final VoidCallback onVideoClosed;
  final VoidCallback onVideoStart;

  AdsterRewardedAdCallback({
    this.onRewardedAdLoaded,
    this.onFailure,
    required this.onAdClicked,
    required this.onAdImpression,
    required this.onUserEarnedReward,
    required this.onVideoComplete,
    required this.onVideoClosed,
    required this.onVideoStart,
  });
}
