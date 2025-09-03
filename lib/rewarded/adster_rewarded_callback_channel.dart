import 'dart:async';

import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';
import 'package:flutter/services.dart';

class AdsterRewardedAdCallbackChannel {
  static final AdsterRewardedAdCallbackChannel _channel =
      AdsterRewardedAdCallbackChannel._();
  final Map<String, AdsterRewardedAdCallback> _widgetMapper = {};
  MethodChannel channel = MethodChannel(
    'adster.channel:adster_rewarded_ad_click',
  );

  AdsterRewardedAdCallbackChannel._();

  static AdsterRewardedAdCallbackChannel get instance => _channel;

  void registerWidget(String widgetId, AdsterRewardedAdCallback callback) {
    channel.setMethodCallHandler(setMethodCallHandler);
    _widgetMapper[widgetId] = callback;
  }

  void removeWidget(String widgetId) {
    _widgetMapper.remove(widgetId);
  }

  Future<void> setMethodCallHandler(MethodCall call) async {
    String? widgetId = call.arguments["widgetId"];
    double? revenue = call.arguments["revenue"];
    String? adUnitId = call.arguments["adUnitId"];
    String? network = call.arguments["network"];

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
      case 'onUserEarnedReward':
        if ((widgetId ?? "").isNotEmpty &&
            _widgetMapper.containsKey(widgetId)) {
          _widgetMapper[widgetId]?.onUserEarnedReward.call(
            call.arguments["amount"],
          );
        }
        break;
      case 'onVideoComplete':
        if ((widgetId ?? "").isNotEmpty &&
            _widgetMapper.containsKey(widgetId)) {
          _widgetMapper[widgetId]?.onVideoComplete.call();
        }
        break;
      case 'onVideoClosed':
        if ((widgetId ?? "").isNotEmpty &&
            _widgetMapper.containsKey(widgetId)) {
          _widgetMapper[widgetId]?.onVideoClosed.call();
        }
        break;
      case 'onVideoStart':
        if ((widgetId ?? "").isNotEmpty &&
            _widgetMapper.containsKey(widgetId)) {
          _widgetMapper[widgetId]?.onVideoStart.call();
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
      case 'onAdRevenuePaid':
        if ((widgetId ?? "").isNotEmpty &&
            _widgetMapper.containsKey(widgetId)) {
          _widgetMapper[widgetId]?.onAdRevenuePaid?.call(
            revenue,
            adUnitId,
            network,
          );
        }
        break;
    }
  }
}
