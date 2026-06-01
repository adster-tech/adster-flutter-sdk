import 'dart:convert';

import 'package:adster_flutter_sdk/core/asdter_typedefs.dart';
import 'package:adster_flutter_sdk/native/adster_native_ad_callback.dart';
import 'package:adster_flutter_sdk/native/adster_native_callback_channel.dart';
import 'package:adster_flutter_sdk/native/adster_native_custom_ad_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef AdsterNativeCustomAdBuilder =
    Widget Function(
      AdsterNativeCustomAdData ad,
      Future<String?> Function(String assetName) getText,
      Future<String?> Function(String assetName) getImageUrl,
      Future<void> Function(String assetName) performClick,
      Future<void> Function() recordImpression,
    );

class AdsterNativeCustomAd extends StatefulWidget {
  final String adPlacementName;
  final AdsterNativeCustomAdBuilder onAdLoaded;
  final AdsterAdErrorBuilder onFailure;
  final Widget? loadingWidget;
  final AdsterNativeAdCallback? callback;

  const AdsterNativeCustomAd({
    super.key,
    required this.adPlacementName,
    required this.onAdLoaded,
    required this.onFailure,
    this.loadingWidget,
    this.callback,
  });

  @override
  State<AdsterNativeCustomAd> createState() => _AdsterNativeCustomAdState();
}

class _AdsterNativeCustomAdState extends State<AdsterNativeCustomAd> {
  final MethodChannel _channel = const MethodChannel(
    'adster.channel:adster_native_ad',
  );
  late final String widgetId;
  late final Future<AdsterNativeCustomAdData> _loadAdFuture;

  @override
  void initState() {
    super.initState();
    widgetId = UniqueKey().toString();
    if (widget.callback != null) {
      AdsterNativeCallbackChannel.instance.registerWidget(
        widgetId,
        widget.callback!,
      );
    }
    _loadAdFuture = _loadAd();
  }

  Future<AdsterNativeCustomAdData> _loadAd() async {
    final data = await _channel.invokeMethod('loadCustomNativeAd', {
      'adPlacementName': widget.adPlacementName,
      'widgetId': widgetId,
    });
    final decoded =
        data is String ? jsonDecode(data) as Map<String, dynamic> : data;
    return AdsterNativeCustomAdData.fromJson(
      Map<String, dynamic>.from(decoded as Map),
    );
  }

  Future<String?> _getText(String assetName) {
    return _channel.invokeMethod<String>('customNativeGetText', {
      'widgetId': widgetId,
      'assetName': assetName,
    });
  }

  Future<String?> _getImageUrl(String assetName) {
    return _channel.invokeMethod<String>('customNativeGetImageUrl', {
      'widgetId': widgetId,
      'assetName': assetName,
    });
  }

  Future<void> _performClick(String assetName) {
    return _channel.invokeMethod<void>('customNativePerformClick', {
      'widgetId': widgetId,
      'assetName': assetName,
    });
  }

  Future<void> _recordImpression() {
    return _channel.invokeMethod<void>('customNativeRecordImpression', {
      'widgetId': widgetId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdsterNativeCustomAdData>(
      future: _loadAdFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return widget.loadingWidget ?? const SizedBox.shrink();
        }
        if (snapshot.hasError) {
          final error = snapshot.error;
          if (error is PlatformException) {
            return widget.onFailure(
              AdsterAdsException(code: error.code, message: error.message),
            );
          }
          return widget.onFailure(
            AdsterAdsException(code: 'UNKNOWN', message: error.toString()),
          );
        }
        return widget.onAdLoaded(
          snapshot.data!,
          _getText,
          _getImageUrl,
          _performClick,
          _recordImpression,
        );
      },
    );
  }

  @override
  void dispose() {
    AdsterNativeCallbackChannel.instance.removeWidget(widgetId);
    super.dispose();
  }
}
