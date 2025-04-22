import 'dart:developer';

import 'package:flutter/services.dart';

import 'adster_rewarded_ads_callback.dart';

class AdsterRewardedAds {
  final MethodChannel _channel = MethodChannel(
    'adster.channel:adster_rewarded_ad',
  );
  final MethodChannel _clickChannel = MethodChannel(
    'adster.channel:adster_rewarded_ad_click',
  );
  AdsterRewardedAdCallback? _callback;

  AdsterRewardedAds() {
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
        case 'onUserEarnedReward':
          if (_callback?.onUserEarnedReward != null) {
            _callback?.onUserEarnedReward(call.arguments["amount"]);
          }
          break;
        case 'onVideoComplete':
          if (_callback?.onVideoComplete != null) {
            _callback?.onVideoComplete();
          }
          break;
        case 'onVideoClosed':
          if (_callback?.onVideoClosed != null) {
            _callback?.onVideoClosed();
          }
          break;
        case 'onVideoStart':
          if (_callback?.onVideoStart != null) {
            _callback?.onVideoStart();
          }
          break;
        case 'onRewardedAdLoaded':
          if (_callback?.onRewardedAdLoaded != null) {
            _callback?.onRewardedAdLoaded!();
          }
          break;
        case 'onFailure':
          if (_callback?.onFailure != null) {
            _callback?.onFailure!();
          }
          break;
      }
      return null;
    });
  }

  Future<bool> loadRewardedAd({
    required String adPlacementName,
    AdsterRewardedAdCallback? callback,
  }) async {
    _callback = callback;
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
