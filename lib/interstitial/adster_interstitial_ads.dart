import 'dart:developer';

import 'package:flutter/services.dart';

import 'adster_interstitial_ads_callback.dart';

class AdsterInterstitialAds {
  final MethodChannel _channel = MethodChannel(
    'adster.channel:adster_interstitial_ad',
  );
  final MethodChannel _clickChannel = MethodChannel(
    'adster.channel:adster_interstitial_ad_click',
  );

  AdsterInterstitialAdsCallback? _callback;

  AdsterInterstitialAds() {
    _clickChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onAdClicked':
          if (_callback?.onAdClicked != null) {
            _callback?.onAdClicked();
          }
          break;
        case 'onAdImpression':
          if (_callback?.onAdImpression != null) {
            _callback?.onAdImpression();
          }
          break;
        case 'onAdOpened':
          if (_callback?.onAdOpened != null) {
            _callback?.onAdOpened();
          }
          break;
        case 'onAdClosed':
          if (_callback?.onAdClosed != null) {
            _callback?.onAdClosed();
          }
          break;
        case 'onInterstitialAdLoaded':
          if (_callback?.onInterstitialAdLoaded != null) {
            _callback?.onInterstitialAdLoaded!();
          }
          break;
        case 'onFailure':
          if (_callback?.onFailure != null) {
            _callback?.onFailure!();
          }
          break;
      }
    });
  }

  Future<bool> loadInterstitialAd({
    required String adPlacementName,
    AdsterInterstitialAdsCallback? callback,
  }) async {
    _callback = callback;
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
