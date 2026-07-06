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
  Map<String, String>? _customTargetArgs;
  String? _publisherProvidedId;

  AdsterAppOpenedAds();

  Future<dynamic> loadAd({
    required String adPlacementName,
    AdsterAppOpenedAdCallback? callback,
    Map<String, String>? customTargetArgs,
    String? publisherProvidedId,
  }) async {
    if (callback != null) {
      AdsterAppOpenedAdCallbackChannel.instance.registerWidget(
        key.toString(),
        callback,
      );
    }
    placemenId = adPlacementName;
    _customTargetArgs = customTargetArgs;
    _publisherProvidedId = publisherProvidedId;
    var response = await _channel.invokeMethod('loadAppOpenedAd', {
      'adPlacementName': adPlacementName,
      'widgetId': key.toString(),
      'customTargetArgs': customTargetArgs,
      'publisherProvidedId': publisherProvidedId,
    });
    log(response);
    return response;
  }

  Future<dynamic> reloadAd() async {
    var response = await _channel.invokeMethod('loadAppOpenedAd', {
      'adPlacementName': placemenId,
      'widgetId': key.toString(),
      'customTargetArgs': _customTargetArgs,
      'publisherProvidedId': _publisherProvidedId,
    });
    return response;
  }
}
