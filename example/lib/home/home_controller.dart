import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';
import 'package:flutter_sdk_example/base_controller.dart';

class HomeController extends BaseController {
  AdsterAppOpenedAds appOpenedAds = AdsterAppOpenedAds();

  AdsterAppOpenedAdCallback getAppOpenedAdCallback() {
    return AdsterAppOpenedAdCallback(
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
      onAdRevenuePaid: (double? revenue, String? adUnitId, String? network) {
        notifySuccess(title: "AppOpenedAd:onAdRevenuePaid: $revenue");
      },
    );
  }
}
