import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';
import 'package:flutter_sdk_example/base_controller.dart';

class UnifiedController extends BaseController {
  AdsterBannerAdCallback getUnifiedBannerAdCallback(String bannerSize) {
    return AdsterBannerAdCallback(
      onAdClicked: () {
        notifySuccess(title: "UnifiedBannerAd($bannerSize):onAdClicked");
      },
      onAdImpression: () {
        notifySuccess(title: "UnifiedBannerAd($bannerSize):onAdImpression");
      },
    );
  }

  AdsterNativeAdCallback getUnifiedNativeAdCallback() {
    return AdsterNativeAdCallback(
      onAdClicked: () {
        notifySuccess(title: "UnifiedNativeAd:onAdClicked");
      },
      onAdImpression: () {
        notifySuccess(title: "UnifiedNativeAd:onAdImpression");
      },
    );
  }
}
