import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sdk_example/unified/unified_controller.dart';
import 'package:get/get.dart';

class UnifiedWidget extends GetView<UnifiedController> {
  const UnifiedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Unified")),
      body: Center(
        child: AdsterUnifiedAd(
          adPlacementName: "adster_unified_test",
          bannerAdSize: AdsterAdSize.medium,
          bannerClickCallback: controller.getUnifiedBannerAdCallback(
            AdsterAdSize.medium.toString(),
          ),
          nativeClickCallback: controller.getUnifiedNativeAdCallback(),
          onBannerAdLoaded: (bannerView) {
            return bannerView;
          },
          onNativeAdLoaded: (value, nativeMediaView, clickHandler) {
            return SizedBox(
              height: 200,
              child: Row(
                children: [
                  SizedBox(width: 10),
                  Expanded(child: nativeMediaView),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                    (context, url, error) => Icon(Icons.error),
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                child: InkWell(
                                  onTap: () {
                                    clickHandler.call(
                                      AdsterNativeAdClickComponent.headline,
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
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                clickHandler.call(
                                  AdsterNativeAdClickComponent.body,
                                );
                              },
                              child: Text(
                                value.body ?? "",
                                overflow: TextOverflow.clip,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          MaterialButton(
                            onPressed: () {
                              clickHandler.call(
                                AdsterNativeAdClickComponent.callToAction,
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
          onFailure: (error) {
            return Text("Unified not loaded: ${error.message} (${error.code})");
          },
        ),
      ),
    );
  }
}
