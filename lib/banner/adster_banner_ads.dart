import 'dart:async';

import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';
import 'package:adster_flutter_sdk/banner/adster_banner_callback_channel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

class AdsterBannerAd extends StatefulWidget {
  final String adPlacementName;
  final AdsterAdSize adSize;
  final AdsterBannerAdBuilder? onAdLoaded;
  final AdsterAdErrorBuilder onFailure;
  final Widget? loadingWidget;
  final AdsterBannerAdCallback? clickCallback;

  /// Predefined custom targeting values passed with the ad request (GAM only).
  /// Each value must be a `String` or a `List<String>`.
  final Map<String, dynamic>? customTargetArgs;

  /// Publisher provided identifier (PPID) passed with the ad request (GAM only).
  final String? publisherProvidedId;

  const AdsterBannerAd({
    super.key,
    required this.adPlacementName,
    required this.adSize,
    this.onAdLoaded,
    required this.onFailure,
    this.loadingWidget,
    this.clickCallback,
    this.customTargetArgs,
    this.publisherProvidedId,
  });

  @override
  State<StatefulWidget> createState() {
    return _AdsterBannerAdState();
  }
}

class _AdsterBannerAdState extends State<AdsterBannerAd> {
  final MethodChannel _channel = MethodChannel('adster.channel:adster_banner');
  late Future _loadAdFuture;
  late String widgetId;

  @override
  void initState() {
    super.initState();
    widgetId = UniqueKey().toString();
    _loadAdFuture = _loadAd();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      AdsterBannerCallbackChannel.instance.registerWidget(
        widgetId,
        AdsterBannerAdCallback(
          onAdClicked: () {
            widget.clickCallback?.onAdClicked.call();
          },
          onAdImpression: () {
            widget.clickCallback?.onAdImpression.call();
          },
          onAdRevenuePaid:
              (revenue, adUnitId, network, currency, precisionType) {
                widget.clickCallback?.onAdRevenuePaid.call(
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
                return widget.onAdLoaded != null
                    ? widget.onAdLoaded!(_getPlatformWidget())
                    : SizedBox(
                        height: widget.adSize.height,
                        width: widget.adSize.width,
                        child: _getPlatformWidget(),
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
    dynamic data = await _channel.invokeMethod('loadBanner', {
      'adPlacementName': widget.adPlacementName,
      'widgetId': widgetId,
      'customTargetArgs': widget.customTargetArgs,
      'publisherProvidedId': widget.publisherProvidedId,
    });
    return data;
  }

  Widget _getPlatformWidget() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Keep the native ad visible in dialogs and overlapping Flutter routes.
        // Texture composition can leave the ad's WebView blank in these layouts.
        return PlatformViewLink(
          viewType: 'adster_banner',
          surfaceFactory: (context, controller) => AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          ),
          onCreatePlatformView: (params) {
            final controller = PlatformViewsService.initExpensiveAndroidView(
              id: params.id,
              viewType: 'adster_banner',
              layoutDirection: Directionality.of(context),
              creationParams: {
                'adPlacementName': widget.adPlacementName,
                'widgetId': widgetId,
              },
              creationParamsCodec: const StandardMessageCodec(),
              onFocus: () => params.onFocusChanged(true),
            );
            controller.addOnPlatformViewCreatedListener(
              params.onPlatformViewCreated,
            );
            controller.create();
            return controller;
          },
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: 'adster_banner',
          creationParams: {
            'adPlacementName': widget.adPlacementName,
            'widgetId': widgetId,
          },
          creationParamsCodec: StandardMessageCodec(),
        );
      default:
        return Text(
          '$defaultTargetPlatform is not yet supported by the web_view plugin',
        );
    }
  }

  Future<void> _disposeNativeBanner() async {
    try {
      await _channel.invokeMethod<void>('disposeBanner', {
        'widgetId': widgetId,
      });
    } on PlatformException catch (error) {
      debugPrint('Failed to dispose banner $widgetId: $error');
    } on MissingPluginException {
      // The engine may already have detached and released its banners.
    }
  }

  @override
  void dispose() {
    AdsterBannerCallbackChannel.instance.removeWidget(widgetId);
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      unawaited(_disposeNativeBanner());
    }
    super.dispose();
  }
}
