import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'interstitial_controller.dart';

class InterstitialWidget extends GetView<InterstitialController> {
  const InterstitialWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Interstitial")),
      body: Center(
        child: FutureBuilder(
          future: controller.interstitialAdFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ElevatedButton(
                onPressed: () {
                  controller.interstitialAds.showInterstitialAd();
                  controller.interstitialAds.reloadAd();
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
      ),
    );
  }
}
