import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';
import 'package:flutter_sdk_example/base_controller.dart';

class UnifiedController extends BaseController {
  AdsterBannerAdCallback getUnifiedAdCallback(String bannerSize) {
    return AdsterBannerAdCallback(
      onAdClicked: () {
        notifySuccess(title: "UnifiedAd($bannerSize):onAdClicked");
      },
      onAdImpression: () {
        notifySuccess(title: "UnifiedAd($bannerSize):onAdImpression");
      },
      onAdRevenuePaid: (revenue, adUnitId, network, currency, precisionType) {
        notifySuccess(
          title:
              "UnifiedAd($bannerSize):onAdRevenuePaid, revenue: $revenue, adUnitId: $adUnitId, network: $network, currency: $currency, precisionType: $precisionType",
        );
      },
    );
  }
}
