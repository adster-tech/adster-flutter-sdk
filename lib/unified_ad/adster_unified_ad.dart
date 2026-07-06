import 'dart:convert';
import 'dart:developer';

import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'adster_unified_ads_callback.dart';
import 'adster_unified_callback_channel.dart';

class AdsterUnifiedAd extends StatefulWidget {
  final String adPlacementName;
  final AdsterAdSize bannerAdSize;
  final AdsterBannerAdBuilder onBannerAdLoaded;
  final AdsterNativeAdBuilder onNativeAdLoaded;
  final AdsterNativeCustomAdBuilder? onCustomNativeAdLoaded;
  final AdsterAdErrorBuilder onFailure;
  final Widget? loadingWidget;
  final AdsterBannerAdCallback? unifiedAdClickCallback;

  /// Predefined custom targeting values passed with the ad request (GAM only).
  final Map<String, String>? customTargetArgs;

  /// Publisher provided identifier (PPID) passed with the ad request (GAM only).
  final String? publisherProvidedId;

  const AdsterUnifiedAd({
    super.key,
    required this.adPlacementName,
    required this.bannerAdSize,
    required this.onBannerAdLoaded,
    required this.onNativeAdLoaded,
    required this.onFailure,
    this.onCustomNativeAdLoaded,
    this.loadingWidget,
    this.unifiedAdClickCallback,
    this.customTargetArgs,
    this.publisherProvidedId,
  });

  @override
  State<StatefulWidget> createState() {
    return _AdsterUnifiedAdState();
  }
}

class _AdsterUnifiedAdState extends State<AdsterUnifiedAd> {
  final MethodChannel _channel = MethodChannel('adster.channel:adster_unified');
  late Future _loadAdFuture;
  late String widgetId;

  @override
  void initState() {
    super.initState();
    widgetId = UniqueKey().toString();
    _loadAdFuture = _loadAd();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      AdsterUnifiedCallbackChannel.instance.registerWidget(
        widgetId,
        AdsterUnifiedCallback(
          onAdClicked: () {
            widget.unifiedAdClickCallback?.onAdClicked.call();
          },
          onAdImpression: () {
            widget.unifiedAdClickCallback?.onAdImpression.call();
          },
          onAdRevenuePaid: (revenue, adUnitId, network, currency, precisionType) {
            widget.unifiedAdClickCallback?.onAdRevenuePaid.call(
              revenue,
              adUnitId,
              network,
              currency,
              precisionType,
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadAdFuture,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            {
              return widget.loadingWidget ?? Container();
            }
          case ConnectionState.active:
          case ConnectionState.done:
            {
              if (snapshot.hasData) {
                if (snapshot.data is String && snapshot.data == "true") {
                  return widget.onBannerAdLoaded(
                    SizedBox(
                      height: widget.bannerAdSize.height,
                      width: widget.bannerAdSize.width,
                      child: _getBannerPlatformWidget(),
                    ),
                  );
                }
                Map<String, dynamic> data = jsonDecode(snapshot.data);
                if (data['adType'] == 'customNative') {
                  if (widget.onCustomNativeAdLoaded == null) {
                    return widget.onFailure(
                      AdsterAdsException(
                        code: 'CUSTOM_NATIVE_BUILDER_MISSING',
                        message: 'Custom native ad loaded but no builder was supplied.',
                      ),
                    );
                  }
                  final customAd = AdsterNativeCustomAdData.fromJson(data);
                  return widget.onCustomNativeAdLoaded!(
                    customAd,
                    _getCustomNativeText,
                    _getCustomNativeImageUrl,
                    _performCustomNativeClick,
                    _recordCustomNativeImpression,
                  );
                }
                return widget.onNativeAdLoaded(
                  AdsterMediationNativeAd(
                    body: data['body'],
                    callToAction: data['callToAction'],
                    headLine: data['headLine'],
                    imageUrl: data['imageUrl'],
                    logo: data['logo'],
                    overrideClickHandling: data['overrideClickHandling'],
                    overrideImpressionHandling:
                        data['overrideImpressionHandling'],
                  ),
                  _getNativePlatformWidget(),
                  (clickComponentType) {
                    _channel
                        .invokeMethod("nativeMediaClick", {
                          "componentName": clickComponentType.name.toString(),
                          "widgetId": widgetId,
                        })
                        .then((value) {
                          log(value);
                        });
                  },
                );
              } else if (snapshot.hasError) {
                if (snapshot.error is PlatformException) {
                  return widget.onFailure(
                    AdsterAdsException(
                      code: (snapshot.error as PlatformException).code,
                      message: (snapshot.error as PlatformException).message,
                    ),
                  );
                }
                return widget.onFailure(
                  AdsterAdsException(
                    code: 'UNKNOWN',
                    message: snapshot.error.toString(),
                  ),
                );
              } else {
                return Container();
              }
            }
        }
      },
    );
  }

  Future<dynamic> _loadAd() async {
    dynamic data = await _channel.invokeMethod('loadUnified', {
      'adPlacementName': widget.adPlacementName,
      'widgetId': widgetId,
      'customTargetArgs': widget.customTargetArgs,
      'publisherProvidedId': widget.publisherProvidedId,
    });
    return data;
  }

  Future<String?> _getCustomNativeText(String assetName) {
    return _channel.invokeMethod<String>('customNativeGetText', {
      'widgetId': widgetId,
      'assetName': assetName,
    });
  }

  Future<String?> _getCustomNativeImageUrl(String assetName) {
    return _channel.invokeMethod<String>('customNativeGetImageUrl', {
      'widgetId': widgetId,
      'assetName': assetName,
    });
  }

  Future<void> _performCustomNativeClick(String assetName) {
    return _channel.invokeMethod<void>('customNativePerformClick', {
      'widgetId': widgetId,
      'assetName': assetName,
    });
  }

  Future<void> _recordCustomNativeImpression() {
    return _channel.invokeMethod<void>('customNativeRecordImpression', {
      'widgetId': widgetId,
    });
  }

  Widget _getBannerPlatformWidget() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: 'adster_unified_banner',
          creationParams: {"widgetId": widgetId},
          creationParamsCodec: StandardMessageCodec(),
          onPlatformViewCreated: (id) {
            log("onPlatformViewCreated: adster_unified_native");
          },
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: 'adster_unified_banner',
          creationParams: {"widgetId": widgetId},
          creationParamsCodec: StandardMessageCodec(),
          onPlatformViewCreated: (id) {
            log("onPlatformViewCreated: adster_unified_native");
          },
        );
      default:
        return Text(
          '$defaultTargetPlatform is not yet supported by the web_view plugin',
        );
    }
  }

  Widget _getNativePlatformWidget() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: 'adster_unified_native',
          creationParams: {"widgetId": widgetId},
          creationParamsCodec: StandardMessageCodec(),
          onPlatformViewCreated: (id) {
            log("onPlatformViewCreated: adster_unified_native");
          },
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: 'adster_unified_native',
          creationParams: {"widgetId": widgetId},
          creationParamsCodec: StandardMessageCodec(),
          onPlatformViewCreated: (id) {
            log("onPlatformViewCreated: adster_unified_native");
          },
        );
      default:
        return Text(
          '$defaultTargetPlatform is not yet supported by the web_view plugin',
        );
    }
  }

  @override
  void dispose() {
    AdsterUnifiedCallbackChannel.instance.removeWidget(widgetId);
    super.dispose();
  }
}
