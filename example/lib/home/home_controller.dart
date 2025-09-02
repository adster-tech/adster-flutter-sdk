import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';
import 'package:flutter_sdk_example/base_controller.dart';
import 'package:get/get.dart';

class HomeController extends BaseController {
  AdsterAppOpenedAds appOpenedAds = AdsterAppOpenedAds();

  AdsterAppOpnenedAdCallback getAppOpenedAdCallback() {
    return AdsterAppOpnenedAdCallback(
      onAdClicked: () {
        notifySuccess(title: "AppOpenedAd:onAdClicked");
      },
      onAdImpression: () {
        notifySuccess(title: "AppOpenedAd:onAdImpression");
      },
      onAdOpened: () {
        notifySuccess(title: "AppOpenedAd:onAdOpened");
      },
      onAdClosed: () {
        notifySuccess(title: "AppOpenedAd:onAdClosed");
      },
      onFailure: (errorCode, errorMessage) {
        notifyError(
          errorMessage: "AppOpenedAd:onFailure: ($errorCode) $errorMessage",
        );
      },
    );
  }
}
