import 'dart:developer';

import 'package:flutter/services.dart';

class AdsterInterstitialAds {
  final MethodChannel _channel = MethodChannel(
    'adster.channel:adster_interstitial_ad',
  );

  Future<bool> loadInterstitialAd({required String adPlacementName}) async {
    var response = await _channel.invokeMethod('loadInterstitialAd', {
      'adPlacementName': adPlacementName,
    });
    log(response);
    if (response != null) {
      return true;
    }
    return false;
  }

  Future<void> showInterstitialAd() async {
    var response = await _channel.invokeMethod('showAd').onError((
      error,
      stackTrace,
    ) {
      return null;
    });
    log(response);
  }
}
