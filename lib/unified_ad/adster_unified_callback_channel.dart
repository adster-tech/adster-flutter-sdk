import 'dart:async';

import 'package:adster_flutter_sdk/banner/adster_banner_ads_callback.dart';
import 'package:flutter/services.dart';

import 'adster_unified_ads_callback.dart';

class AdsterUnifiedCallbackChannel {
  static final AdsterUnifiedCallbackChannel _channel =
      AdsterUnifiedCallbackChannel._();
  final Map<String, AdsterUnifiedCallback> _widgetMapper = {};
  MethodChannel channel = MethodChannel(
    'adster.channel:adster_unified_ad_click',
  );

  AdsterUnifiedCallbackChannel._();

  static AdsterUnifiedCallbackChannel get instance => _channel;

  void registerWidget(String widgetId, AdsterUnifiedCallback callback) {
    channel.setMethodCallHandler(setMethodCallHandler);
    _widgetMapper[widgetId] = callback;
  }

  void removeWidget(String widgetId) {
    _widgetMapper.remove(widgetId);
  }

  Future<void> setMethodCallHandler(MethodCall call) async {
    String? widgetId = call.arguments["widgetId"];
    String? type = call.arguments["type"];
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
    }
  }
}
