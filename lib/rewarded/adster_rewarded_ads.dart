import 'dart:developer';

import 'package:flutter/services.dart';

class AdsterRewardedAds {
  final MethodChannel _channel = MethodChannel(
    'adster.channel:adster_rewarded_ad',
  );

  Future<bool> loadRewardedAd({required String adPlacementName}) async {
    var response = await _channel.invokeMethod('loadRewardedAd', {
      'adPlacementName': adPlacementName,
    });
    log(response);
    if (response != null) {
      return true;
    }
    return false;
  }

  Future<void> showRewardedAd() async {
    var response = await _channel.invokeMethod('showAd').onError((
      error,
      stackTrace,
    ) {
      return null;
    });
    log(response);
  }
}
