import 'dart:async';

import 'package:adster_flutter_sdk/native/adster_native_ad_callback.dart';
import 'package:flutter/services.dart';

class AdsterNativeCallbackChannel {
  static final AdsterNativeCallbackChannel _channel =
      AdsterNativeCallbackChannel._();
  final Map<String, AdsterNativeAdCallback> _widgetMapper = {};
  MethodChannel channel = MethodChannel(
    'adster.channel:adster_native_ad_click',
  );

  AdsterNativeCallbackChannel._();

  static AdsterNativeCallbackChannel get instance => _channel;

  void registerWidget(String widgetId, AdsterNativeAdCallback callback) {
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
          _widgetMapper[widgetId]?.onAdClicked?.call();
        }
        break;
      case 'onAdImpression':
        if ((widgetId ?? "").isNotEmpty &&
            _widgetMapper.containsKey(widgetId)) {
          _widgetMapper[widgetId]?.onAdImpression?.call();
        }
        break;
    }
  }
}
