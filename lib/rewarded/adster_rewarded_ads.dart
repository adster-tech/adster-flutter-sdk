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
  Map<String, String>? _customTargetArgs;
  String? _publisherProvidedId;

  AdsterRewardedAds();

  Future<dynamic> loadAd({
    required String adPlacementName,
    AdsterRewardedAdCallback? callback,
    Map<String, String>? customTargetArgs,
    String? publisherProvidedId,
  }) async {
    if (callback != null) {
      AdsterRewardedAdCallbackChannel.instance.registerWidget(
        key.toString(),
        callback,
      );
    }
    placemenId = adPlacementName;
    _customTargetArgs = customTargetArgs;
    _publisherProvidedId = publisherProvidedId;
    var response = await _channel.invokeMethod('loadRewardedAd', {
      'adPlacementName': adPlacementName,
      'widgetId': key.toString(),
      'customTargetArgs': customTargetArgs,
      'publisherProvidedId': publisherProvidedId,
    });
    log(response);
    return response;
  }

  Future<dynamic> reloadAd() async {
    var response = await _channel.invokeMethod('loadRewardedAd', {
      'adPlacementName': placemenId,
      'widgetId': key.toString(),
      'customTargetArgs': _customTargetArgs,
      'publisherProvidedId': _publisherProvidedId,
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
