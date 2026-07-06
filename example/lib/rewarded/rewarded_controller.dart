import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';
import 'package:flutter_sdk_example/base_controller.dart';
import 'package:flutter_sdk_example/targeting_demo.dart';

class RewardedController extends BaseController {
  ///keeping it global to prevent it from reload again & again
  AdsterRewardedAds rewardedAds = AdsterRewardedAds();
  late Future rewardAdFuture;

  @override
  void onInit() {
    rewardAdFuture = rewardedAds.loadAd(
      adPlacementName: "adster_rewarded_test",
      callback: getRewardedAdCallback(),
      // Optional GAM targeting passed with the ad request.
      customTargetArgs: kDemoCustomTargetArgs,
      publisherProvidedId: kDemoPublisherProvidedId,
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
      onAdRevenuePaid: (revenue, adUnitId, network, currency, precisionType) {
        notifySuccess(
          title:
              "RewardedAd:onAdRevenuePaid: $revenue $currency $precisionType",
        );
      },
    );
  }
}
