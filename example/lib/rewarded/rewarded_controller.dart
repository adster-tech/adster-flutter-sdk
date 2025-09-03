import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';
import 'package:flutter_sdk_example/base_controller.dart';

class RewardedController extends BaseController {
  ///keeping it global to prevent it from reload again & again
  AdsterRewardedAds rewardedAds = AdsterRewardedAds();
  late Future rewardAdFuture;

  @override
  void onInit() {
    rewardAdFuture = rewardedAds.loadAd(
      adPlacementName: "adster_rewarded_test",
      callback: getRewardedAdCallback(),
    );
    super.onInit();
  }

  AdsterRewardedAdCallback getRewardedAdCallback() {
    return AdsterRewardedAdCallback(
      onAdClicked: () {
        notifySuccess(title: "RewardedAd:onAdClicked");
      },
      onAdImpression: () {
        notifySuccess(title: "RewardedAd:onAdImpression");
      },
      onUserEarnedReward: (rewardAmount) {
        notifySuccess(title: "RewardedAd:onUserEarnedReward: \$$rewardAmount");
      },
      onVideoComplete: () {
        notifySuccess(title: "RewardedAd:onVideoComplete");
      },
      onVideoClosed: () {
        notifySuccess(title: "RewardedAd:onVideoClosed");
      },
      onVideoStart: () {
        notifySuccess(title: "RewardedAd:onVideoStart");
      },
      onAdRevenuePaid: (double? revenue, String? adUnitId, String? network) {
        notifySuccess(title: "RewardedAd:onAdRevenuePaid: \$$revenue");
      },
    );
  }
}
