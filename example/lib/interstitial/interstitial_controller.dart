import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';
import 'package:flutter_sdk_example/base_controller.dart';

class InterstitialController extends BaseController {
  ///keeping it global to prevent it from reload again & again
  AdsterInterstitialAds interstitialAds = AdsterInterstitialAds();
  AdsterInterstitialAds interstitialAds1 = AdsterInterstitialAds();
  late Future interstitialAdFuture;
  late Future interstitialAdFuture1;

  @override
  void onInit() {
    interstitialAdFuture = interstitialAds.loadAd(
      adPlacementName: "adster_interstitial_test",
      callback: getInterstitialAdCallback(),
    );
    interstitialAdFuture1 = interstitialAds1.loadAd(
      adPlacementName: "adster_interstitial_test",
      callback: getInterstitialAdCallback(),
    );
    super.onInit();
  }

  AdsterInterstitialAdsCallback getInterstitialAdCallback() {
    return AdsterInterstitialAdsCallback(
      onAdClicked: () {
        notifySuccess(title: "InterstitialAd:onAdClicked");
      },
      onAdImpression: () {
        notifySuccess(title: "InterstitialAd:onAdImpression");
      },
      onAdOpened: () {
        notifySuccess(title: "InterstitialAd:onAdOpened");
      },
      onAdClosed: () {
        notifySuccess(title: "InterstitialAd:onAdClosed");
      },
    );
  }
}
