import 'dart:developer';

import 'package:adster_flutter_sdk/app_opened_ad/adster_app_opened_callback_channel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'adster_app_opened_ads_callback.dart';

class AdsterAppOpenedAds {
  final MethodChannel _channel = MethodChannel(
    'adster.channel:adster_app_opened_ad',
  );

  var key = UniqueKey();
  String? placemenId;

  AdsterAppOpenedAds();

  Future<dynamic> loadAd({
    required String adPlacementName,
    AdsterAppOpenedAdCallback? callback,
  }) async {
    if (callback != null) {
      AdsterAppOpenedAdCallbackChannel.instance.registerWidget(
        key.toString(),
        callback,
      );
    }
    placemenId = adPlacementName;
    var response = await _channel.invokeMethod('loadAppOpenedAd', {
      'adPlacementName': adPlacementName,
      'widgetId': key.toString(),
    });
    log(response);
    return response;
  }

  Future<dynamic> reloadAd() async {
    var response = await _channel.invokeMethod('loadAppOpenedAd', {
      'adPlacementName': placemenId,
      'widgetId': key.toString(),
    });
    return response;
  }
}
