import 'dart:async';

import 'package:adster_flutter_sdk/app_opened_ad/adster_app_opened_ads_callback.dart';
import 'package:flutter/services.dart';

class AdsterAppOpenedAdCallbackChannel {
  static final AdsterAppOpenedAdCallbackChannel _channel =
      AdsterAppOpenedAdCallbackChannel._();
  final Map<String, AdsterAppOpenedAdCallback> _widgetMapper = {};
  MethodChannel channel = MethodChannel(
    'adster.channel:adster_app_opened_ad_click',
  );

  AdsterAppOpenedAdCallbackChannel._();

  static AdsterAppOpenedAdCallbackChannel get instance => _channel;

  void registerWidget(String widgetId, AdsterAppOpenedAdCallback callback) {
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
      case 'onFailure':
        if ((widgetId ?? "").isNotEmpty &&
            _widgetMapper.containsKey(widgetId)) {
          int errorCode = 0;
          String errorMessage = "";
          if (call.arguments["errorCode"] != null) {
            errorCode = call.arguments["errorCode"];
          }
          if (call.arguments["errorMessage"] != null) {
            errorMessage = call.arguments["errorMessage"];
          }
          _widgetMapper[widgetId]?.onFailure.call(errorCode, errorMessage);
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
    }
  }
}
