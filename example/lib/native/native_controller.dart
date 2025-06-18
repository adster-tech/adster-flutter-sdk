import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';
import 'package:flutter_sdk_example/base_controller.dart';

class NativeController extends BaseController {
  AdsterNativeAdCallback getNativeAdCallback() {
    return AdsterNativeAdCallback(
      onAdClicked: () {
        notifySuccess(title: "NativeAd:onAdClicked");
      },
      onAdImpression: () {
        notifySuccess(title: "NativeAd:onAdImpression");
      },
    );
  }
}
