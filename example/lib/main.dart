import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';
import 'package:adster_flutter_sdk/core/adster_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AdsterRewardedAds rewardedAds = AdsterRewardedAds();

  @override
  void initState() {
    super.initState();
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
                adPlacementName: "adster_banner_300x250",
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
                adPlacementName: "adster_banner_320x50",
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
                margin: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: AdsterNativeAd(
                  adPlacementName: "adster_native_test",
                  onAdLoaded: (value, widget) {
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
                                        child: Text(
                                          value.headLine ?? "",
                                          maxLines: 2,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Text(value.body ?? ""),
                                  SizedBox(height: 5),
                                  MaterialButton(
                                    onPressed: () {},
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
                ),
              ),
              FutureBuilder(
                future: rewardedAds.loadRewardedAd(
                  adPlacementName: "adster_rewarded_test",
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (!(snapshot.data ?? true)) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Ads not loaded"),
                      );
                    } else {
                      return ElevatedButton(
                        onPressed: () {
                          rewardedAds.showRewardedAd();
                        },
                        child: Text("Show Rewarded Ad"),
                      );
                    }
                  } else if (snapshot.hasError) {
                    if (snapshot.error is Exception) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Ads not loaded: ${(snapshot.error as PlatformException).message}",
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
}
