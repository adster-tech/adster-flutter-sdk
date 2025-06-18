import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sdk_example/rewarded/rewarded_controller.dart';
import 'package:get/get.dart';

class RewardedWidget extends GetView<RewardedController> {
  const RewardedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rewarded Ad")),
      body: Center(
        child: FutureBuilder(
          future: controller.rewardAdFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ElevatedButton(
                onPressed: () {
                  controller.rewardedAds.showRewardedAd();
                  controller.rewardedAds.reloadAd();
                },
                child: Text("Show Rewarded Ad"),
              );
            } else if (snapshot.hasError) {
              if (snapshot.error is Exception) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Rewarded Ad not loaded: ${(snapshot.error as PlatformException).message}",
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
