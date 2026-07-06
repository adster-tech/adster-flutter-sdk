import 'dart:convert';

import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';
import 'package:adster_flutter_sdk/native/adster_native_callback_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef AdsterCarouselNativeAdBuilder =
    Widget Function(List<AdsterCarouselNativeAdItem> items);

class AdsterCarouselNativeAdItem {
  final AdsterMediationNativeAd ad;
  final Widget mediaView;
  final AdsterClickHandler clickHandler;

  const AdsterCarouselNativeAdItem({
    required this.ad,
    required this.mediaView,
    required this.clickHandler,
  });
}

class AdsterCarouselNativeAd extends StatefulWidget {
  final String adPlacementName;
  final AdsterCarouselNativeAdBuilder onAdLoaded;
  final AdsterAdErrorBuilder onFailure;
  final Widget? loadingWidget;
  final AdsterNativeAdCallback? callback;

  /// Predefined custom targeting values passed with the ad request (GAM only).
  final Map<String, String>? customTargetArgs;

  /// Publisher provided identifier (PPID) passed with the ad request (GAM only).
  final String? publisherProvidedId;

  const AdsterCarouselNativeAd({
    super.key,
    required this.adPlacementName,
    required this.onAdLoaded,
    required this.onFailure,
    this.loadingWidget,
    this.callback,
    this.customTargetArgs,
    this.publisherProvidedId,
  });

  @override
  State<AdsterCarouselNativeAd> createState() => _AdsterCarouselNativeAdState();
}

class _AdsterCarouselNativeAdState extends State<AdsterCarouselNativeAd> {
  final MethodChannel _channel = const MethodChannel(
    'adster.channel:adster_carousel_native',
  );
  late final String widgetId;
  late final Future<List<AdsterMediationNativeAd>> _loadAdFuture;

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

  Future<List<AdsterMediationNativeAd>> _loadAd() async {
    final data = await _channel.invokeMethod('loadCarouselNative', {
      'adPlacementName': widget.adPlacementName,
      'widgetId': widgetId,
      'customTargetArgs': widget.customTargetArgs,
      'publisherProvidedId': widget.publisherProvidedId,
    });
    final decoded = data is String ? jsonDecode(data) : data;
    return (decoded as List<dynamic>).map((value) {
      final item = Map<String, dynamic>.from(value as Map);
      return AdsterMediationNativeAd(
        body: item['body'],
        callToAction: item['callToAction'],
        headLine: item['headLine'],
        imageUrl: item['imageUrl'],
        logo: item['logo'],
        overrideClickHandling: item['overrideClickHandling'],
        overrideImpressionHandling: item['overrideImpressionHandling'],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AdsterMediationNativeAd>>(
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
        final items = List.generate(snapshot.data!.length, (index) {
          return AdsterCarouselNativeAdItem(
            ad: snapshot.data![index],
            mediaView: _platformView(index),
            clickHandler: (component) {
              _channel.invokeMethod('nativeMediaClick', {
                'widgetId': widgetId,
                'index': index,
                'componentName': component.name,
              });
            },
          );
        });
        return widget.onAdLoaded(items);
      },
    );
  }

  Widget _platformView(int index) {
    final params = {'widgetId': widgetId, 'index': index};
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: 'adster_carousel_native',
          creationParams: params,
          creationParamsCodec: const StandardMessageCodec(),
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: 'adster_carousel_native',
          creationParams: params,
          creationParamsCodec: const StandardMessageCodec(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  void dispose() {
    AdsterNativeCallbackChannel.instance.removeWidget(widgetId);
    super.dispose();
  }
}
