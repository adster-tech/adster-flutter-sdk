import 'dart:async';

import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';
import 'package:flutter/services.dart';

class AdsterInterstitialAdCallbackChannel {
  static final AdsterInterstitialAdCallbackChannel _channel =
      AdsterInterstitialAdCallbackChannel._();
  final Map<String, AdsterInterstitialAdsCallback> _widgetMapper = {};
  MethodChannel channel = MethodChannel(
    'adster.channel:adster_interstitial_ad_click',
  );

  AdsterInterstitialAdCallbackChannel._();

  static AdsterInterstitialAdCallbackChannel get instance => _channel;

  void registerWidget(String widgetId, AdsterInterstitialAdsCallback callback) {
    channel.setMethodCallHandler(setMethodCallHandler);
    _widgetMapper[widgetId] = callback;
  }

  void removeWidget(String widgetId) {
    _widgetMapper.remove(widgetId);
  }

  Future<void> setMethodCallHandler(MethodCall call) async {
    String? widgetId = call.arguments["widgetId"];
    switch (call.method) {
      case 'onAdClicked':
        if ((widgetId ?? "").isNotEmpty &&
            _widgetMapper.containsKey(widgetId)) {
          _widgetMapper[widgetId]?.onAdClicked.call();
        }
        break;
      case 'onAdImpression':
        if ((widgetId ?? "").isNotEmpty &&
            _widgetMapper.containsKey(widgetId)) {
          _widgetMapper[widgetId]?.onAdImpression.call();
        }
        break;
      case 'onAdOpened':
        if ((widgetId ?? "").isNotEmpty &&
            _widgetMapper.containsKey(widgetId)) {
          _widgetMapper[widgetId]?.onAdOpened.call();
        }
        break;
      case 'onAdClosed':
        if ((widgetId ?? "").isNotEmpty &&
            _widgetMapper.containsKey(widgetId)) {
          _widgetMapper[widgetId]?.onAdClosed.call();
        }
        break;
      case 'onAdFailToPresentFullScreenContentWithError':
        if ((widgetId ?? "").isNotEmpty &&
            _widgetMapper.containsKey(widgetId)) {
          _widgetMapper[widgetId]?.onAdFailToPresentFullScreenContentWithError
              ?.call(
                AdsterAdsException(
                  code: call.arguments["code"] ?? "UNKNOWN",
                  message: call.arguments["message"],
                ),
              );
        }
        break;
    }
  }
}
