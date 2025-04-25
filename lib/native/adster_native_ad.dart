import 'dart:convert';
import 'dart:developer';
import 'package:adster_flutter_sdk/native/adster_mediation_native_ad_model.dart';
import 'package:adster_flutter_sdk/native/adster_native_ad_callback.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:adster_flutter_sdk/core/asdter_typedefs.dart';

class AdsterNativeAd extends StatefulWidget {
  final String adPlacementName;
  final AdsterNativeAdBuilder onAdLoaded;
  final AdsterAdErrorBuilder onFailure;
  final Widget? loadingWidget;
  final AdsterNativeAdCallback? clickCallback;

  const AdsterNativeAd({
    super.key,
    required this.adPlacementName,
    required this.onAdLoaded,
    required this.onFailure,
    this.loadingWidget,
    this.clickCallback,
  });

  @override
  State<StatefulWidget> createState() {
    return _AdsterNativeAdState();
  }
}

class _AdsterNativeAdState extends State<AdsterNativeAd> {
  late Future _loadAdFuture;
  final MethodChannel _channel = MethodChannel(
    'adster.channel:adster_native_ad',
  );
  final MethodChannel _clickChannel = MethodChannel(
    'adster.channel:adster_native_ad_click',
  );

  _AdsterNativeAdState();

  @override
  void initState() {
    super.initState();
    _loadAdFuture = _loadAd();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _clickChannel.setMethodCallHandler((call) async {
        switch (call.method) {
          case 'onAdClicked':
            widget.clickCallback?.onAdClicked?.call();
            break;
          case 'onAdImpression':
            widget.clickCallback?.onAdImpression?.call();
            break;
          case 'onFailure':
            widget.clickCallback?.onFailure?.call();
            break;
          case 'onNativeAdLoaded':
            widget.clickCallback?.onNativeAdLoaded?.call();
            break;
        }
        return null;
      });
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
                Map<String, dynamic> data = jsonDecode(snapshot.data);
                return widget.onAdLoaded(
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
                  _getPlatformWidget(),
                  (clickComponentType) {
                    _channel
                        .invokeMethod(
                          "nativeMediaClick",
                          clickComponentType.name.toString(),
                        )
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
    dynamic data = await _channel.invokeMethod('loadBanner', {
      'adPlacementName': widget.adPlacementName,
    });
    log(data);
    return data;
  }

  Widget _getPlatformWidget() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: 'adster_native',
          onPlatformViewCreated: (id) {
            log("onPlatformViewCreated: adster_native");
          },
        );
      case TargetPlatform.iOS:
        return UiKitView(viewType: 'adster_native');
      default:
        return Text(
          '$defaultTargetPlatform is not yet supported by the web_view plugin',
        );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _clickChannel.setMethodCallHandler(null);
  }
}
