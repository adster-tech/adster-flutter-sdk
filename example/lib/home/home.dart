import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_sdk_example/home/home_controller.dart';
import 'package:flutter_sdk_example/routes/app_routes.dart';
import 'package:get/get.dart';

class HomeWidget extends GetView<HomeController> {
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            MaterialButton(
              minWidth: Get.width,
              onPressed: () {
                Get.toNamed(AppRoutes.banner);
              },
              textColor: Colors.white,
              color: Colors.brown,
              child: Text("Banner"),
            ),
            MaterialButton(
              minWidth: Get.width,
              onPressed: () {
                Get.toNamed(AppRoutes.native);
              },
              textColor: Colors.white,
              color: Colors.brown,
              child: Text("Native"),
            ),
            MaterialButton(
              minWidth: Get.width,
              onPressed: () {
                Get.toNamed(AppRoutes.interstitial);
              },
              textColor: Colors.white,
              color: Colors.brown,
              child: Text("Interstitial"),
            ),
            MaterialButton(
              minWidth: Get.width,
              onPressed: () {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  controller.appOpenedAds
                      .loadAd(
                        adPlacementName: "adster_appopen_test",
                        callback: controller.getAppOpenedAdCallback(),
                      )
                      .then((value) {
                        controller.notifySuccess(
                          title: "AppOpenedAd:onAppOpenAdLoaded",
                        );
                      })
                      .onError((error, stackTrace) {
                        controller.notifyError(
                          errorMessage: "AppOpenedAd:onFailure: $error",
                        );
                      });
                });
              },
              textColor: Colors.white,
              color: Colors.brown,
              child: Text("In-App"),
            ),
            MaterialButton(
              minWidth: Get.width,
              onPressed: () {
                Get.toNamed(AppRoutes.rewarded);
              },
              textColor: Colors.white,
              color: Colors.brown,
              child: Text("Rewarded"),
            ),
            MaterialButton(
              minWidth: Get.width,
              onPressed: () {
                Get.toNamed(AppRoutes.unified);
              },
              textColor: Colors.white,
              color: Colors.brown,
              child: Text("Unified"),
            ),
          ],
        ),
      ),
      appBar: AppBar(title: Text("Adster Sample")),
    );
  }
}
