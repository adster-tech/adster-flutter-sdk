import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());

  ///ToastificationWrapper (optional)
  ///Just to toast the callback events
  runApp(ToastificationWrapper(child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ///keeping it global to prevent it from reload again & again
  AdsterRewardedAds rewardedAds = AdsterRewardedAds();
  late Future rewardAdFuture;

  ///keeping it global to prevent it from reload again & again
  AdsterInterstitialAds interstitialAds = AdsterInterstitialAds();
  late Future interstitialAdFuture;

  AdsterAppOpenedAds appOpenedAds = AdsterAppOpenedAds();

  @override
  void initState() {
    super.initState();

    rewardAdFuture = rewardedAds.loadAd(
      adPlacementName: "adster_rewarded_test",
      callback: getRewardedAdCallback(),
    );

    interstitialAdFuture = interstitialAds.loadAd(
      adPlacementName: "adster_interstitial_test",
      callback: getInterstitialAdCallback(),
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      appOpenedAds
          .loadAd(
            adPlacementName: "adster_appopen_test",
            callback: getAppOpenedAdCallback(),
          )
          .then((value) {
            toastification.show(
              type: ToastificationType.success,
              alignment: Alignment.bottomCenter,
              style: ToastificationStyle.fillColored,
              title: Text("AppOpenedAd:onAppOpenAdLoaded"),
            );
          })
          .onError((error, stackTrace) {
            toastification.show(
              type: ToastificationType.error,
              alignment: Alignment.bottomCenter,
              style: ToastificationStyle.fillColored,
              title: Text("AppOpenedAd:onFailure: $error"),
            );
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
              SizedBox(height: 10),
              AdsterBannerAd(
                key: UniqueKey(),
                adPlacementName: "adster_banner_320x50",
                clickCallback: getBannerAdCallback(
                  AdsterAdSize.small.toString(),
                ),
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
              Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: AdsterNativeAd(
                  adPlacementName: "adster_native_test",
                  onAdLoaded: (value, widget, clickHandler) {
                    return SizedBox(
                      height: 200,
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Expanded(child: widget),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: value.imageUrl ?? "",
                                        placeholder:
                                            (context, url) =>
                                                CircularProgressIndicator(),
                                        errorWidget:
                                            (context, url, error) =>
                                                Icon(Icons.error),
                                      ),
                                      SizedBox(width: 10),
                                      Flexible(
                                        child: InkWell(
                                          onTap: () {
                                            clickHandler.call(
                                              AdsterNativeAdClickComponent
                                                  .headline,
                                            );
                                          },
                                          child: Text(
                                            value.headLine ?? "",
                                            maxLines: 2,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  InkWell(
                                    onTap: () {
                                      clickHandler.call(
                                        AdsterNativeAdClickComponent.body,
                                      );
                                    },
                                    child: Text(value.body ?? ""),
                                  ),
                                  SizedBox(height: 5),
                                  MaterialButton(
                                    onPressed: () {
                                      clickHandler.call(
                                        AdsterNativeAdClickComponent
                                            .callToAction,
                                      );
                                    },
                                    color: Colors.grey,
                                    child: Text(value.callToAction ?? ""),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onFailure: (AdsterAdsException error) {
                    return Text(error.message ?? "");
                  },
                  clickCallback: getNativeAdCallback(),
                ),
              ),
              FutureBuilder(
                future: rewardAdFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ElevatedButton(
                      onPressed: () {
                        rewardedAds.showRewardedAd();
                        rewardedAds.reloadAd();
                      },
                      child: Text("Show Rewarded Ad"),
                    );
                  } else if (snapshot.hasError) {
                    if (snapshot.error is Exception) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Rewarded Ads not loaded: ${(snapshot.error as PlatformException).message}",
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("${snapshot.error}"),
                    );
                  }
                  return CircularProgressIndicator();
                },
              ),
              SizedBox(height: 5),
              FutureBuilder(
                future: interstitialAdFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ElevatedButton(
                      onPressed: () {
                        interstitialAds.showInterstitialAd();
                        interstitialAds.reloadAd();
                      },
                      child: Text("Show Interstitial Ad"),
                    );
                  } else if (snapshot.hasError) {
                    if (snapshot.error is Exception) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Interstitial Ads not loaded: ${(snapshot.error as PlatformException).message}",
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("${snapshot.error}"),
                    );
                  }
                  return CircularProgressIndicator();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  AdsterBannerAdCallback getBannerAdCallback(String bannerSize) {
    return AdsterBannerAdCallback(
      onAdClicked: () {
        notifySuccess(title: "BannerAd($bannerSize):onAdClicked");
      },
      onAdImpression: () {
        notifySuccess(title: "BannerAd($bannerSize):onAdImpression");
      },
    );
  }

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
    );
  }

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

  void notifySuccess({required String title}) {
    toastification.show(
      type: ToastificationType.success,
      alignment: Alignment.bottomCenter,
      style: ToastificationStyle.fillColored,
      title: Text(title),
    );
  }

  void notifyError({required String errorMessage}) {
    toastification.show(
      type: ToastificationType.error,
      alignment: Alignment.bottomCenter,
      style: ToastificationStyle.fillColored,
      title: Text(errorMessage),
    );
  }
}
