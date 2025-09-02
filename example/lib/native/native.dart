import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

import 'native_controller.dart';

class NativeWidget extends GetView<NativeController> {
  const NativeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Native")),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 20),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 15),
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
                                      height: 30,
                                      width: 30,
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
                onFailure: (AdsterAdsException error) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(error.message ?? ""),
                  );
                },
                clickCallback: controller.getNativeAdCallback(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
