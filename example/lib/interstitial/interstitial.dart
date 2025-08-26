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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder(
              future: controller.interstitialAdFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ElevatedButton(
                    onPressed: () {
                      controller.interstitialAds.showInterstitialAd();
                      controller.interstitialAds.reloadAd();
                    },
                    child: Text("Show Interstitial Ad 1"),
                  );
                } else if (snapshot.hasError) {
                  if (snapshot.error is Exception) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Interstitial Ad 1 not loaded: ${(snapshot.error as PlatformException).message}",
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
            FutureBuilder(
              future: controller.interstitialAdFuture1,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ElevatedButton(
                    onPressed: () {
                      controller.interstitialAds1.showInterstitialAd();
                      controller.interstitialAds1.reloadAd();
                    },
                    child: Text("Show Interstitial Ad 2"),
                  );
                } else if (snapshot.hasError) {
                  if (snapshot.error is Exception) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Interstitial 2 Ads not loaded: ${(snapshot.error as PlatformException).message}",
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
    );
  }
}
