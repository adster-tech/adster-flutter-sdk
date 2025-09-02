import 'dart:developer';

import 'package:adster_flutter_sdk/rewarded/adster_rewarded_callback_channel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'adster_rewarded_ads_callback.dart';

class AdsterRewardedAds {
  final MethodChannel _channel = MethodChannel(
    'adster.channel:adster_rewarded_ad',
  );

  var key = UniqueKey();
  String? placemenId;

  AdsterRewardedAds();

  Future<dynamic> loadAd({
    required String adPlacementName,
    AdsterRewardedAdCallback? callback,
  }) async {
    if (callback != null) {
      AdsterRewardedAdCallbackChannel.instance.registerWidget(
        key.toString(),
        callback,
      );
    }
    placemenId = adPlacementName;
    var response = await _channel.invokeMethod('loadRewardedAd', {
      'adPlacementName': adPlacementName,
      'widgetId': key.toString(),
    });
    log(response);
    return response;
  }

  Future<dynamic> reloadAd() async {
    var response = await _channel.invokeMethod('loadRewardedAd', {
      'adPlacementName': placemenId,
      'widgetId': key.toString(),
    });
    return response;
  }

  Future<void> showRewardedAd() async {
    var response = await _channel
        .invokeMethod('showAd', {'widgetId': key.toString()})
        .onError((error, stackTrace) {
          return null;
        });
    log(response);
  }
}
