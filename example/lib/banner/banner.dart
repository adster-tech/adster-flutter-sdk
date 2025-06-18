import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_sdk_example/banner/banner_controller.dart';
import 'package:get/get.dart';

class BannerWidget extends GetView<BannerController> {
  const BannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Banner")),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            Text("Banner (320x250)"),
            AdsterBannerAd(
              key: UniqueKey(),
              adPlacementName: "adster_banner_300x250",
              clickCallback: getBannerAdCallback(
                AdsterAdSize.medium.toString(),
              ),
              adSize: AdsterAdSize.medium,
              loadingWidget: SizedBox(
                width: AdsterAdSize.medium.width,
                height: AdsterAdSize.medium.height,
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text("Loading...."),
                    ],
                  ),
                ),
              ),
              onFailure: (AdsterAdsException error) {
                return Text("Banner not loaded: ${error.message}");
              },
            ),
            SizedBox(height: 20),
            Text("Banner (300x50)"),
            AdsterBannerAd(
              key: UniqueKey(),
              adPlacementName: "adster_banner_320x50",
              clickCallback: getBannerAdCallback(AdsterAdSize.small.toString()),
              adSize: AdsterAdSize.small,
              loadingWidget: SizedBox(
                width: AdsterAdSize.small.width,
                height: AdsterAdSize.small.height,
                child: Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 10),
                      Text("Loading...."),
                    ],
                  ),
                ),
              ),
              onFailure: (AdsterAdsException error) {
                return Text("Banner not loaded: ${error.message}");
              },
            ),
          ],
        ),
      ),
    );
  }

  AdsterBannerAdCallback getBannerAdCallback(String bannerSize) {
    return AdsterBannerAdCallback(
      onAdClicked: () {
        controller.notifySuccess(title: "BannerAd($bannerSize):onAdClicked");
      },
      onAdImpression: () {
        controller.notifySuccess(title: "BannerAd($bannerSize):onAdImpression");
      },
    );
  }
}
