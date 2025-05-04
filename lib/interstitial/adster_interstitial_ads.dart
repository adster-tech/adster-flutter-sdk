import 'dart:developer';

import 'package:adster_flutter_sdk/interstitial/adster_interstitial_callback_channel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'adster_interstitial_ads_callback.dart';

class AdsterInterstitialAds {
  final MethodChannel _channel = MethodChannel(
    'adster.channel:adster_interstitial_ad',
  );
  var key = UniqueKey();
  String? placemenId;

  AdsterInterstitialAds();

  Future<dynamic> loadAd({
    required String adPlacementName,
    AdsterInterstitialAdsCallback? callback,
  }) async {
    if (callback != null) {
      AdsterInterstitialAdCallbackChannel.instance.registerWidget(
        key.toString(),
        callback,
      );
    }
    placemenId = adPlacementName;
    var response = await _channel.invokeMethod('loadInterstitialAd', {
      'adPlacementName': adPlacementName,
      'widgetId': key.toString(),
    });
    return response;
  }

  Future<dynamic> reloadAd() async {
    var response = await _channel.invokeMethod('loadInterstitialAd', {
      'adPlacementName': placemenId,
      'widgetId': key.toString(),
    });
    return response;
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
