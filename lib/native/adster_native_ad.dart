import 'dart:convert';
import 'dart:developer';

import 'package:adster_flutter_sdk/native/adster_mediation_native_ad_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:adster_flutter_sdk/core/asdter_typedefs.dart';

class AdsterNativeAd extends StatelessWidget {
  final String adPlacementName;
  final AdsterNativeAdBuilder onAdLoaded;
  final AdsterAdErrorBuilder onFailure;
  final Widget? loadingWidget;
  final MethodChannel _channel = MethodChannel(
    'adster.channel:adster_native_ad',
  );

  AdsterNativeAd({
    super.key,
    required this.adPlacementName,
    required this.onAdLoaded,
    required this.onFailure,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadAd(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            {
              return loadingWidget ?? Container();
            }
          case ConnectionState.active:
          case ConnectionState.done:
            {
              if (snapshot.hasData) {
                Map<String, dynamic> data = jsonDecode(snapshot.data);
                return onAdLoaded(
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
                );
              } else if (snapshot.hasError) {
                if (snapshot.error is PlatformException) {
                  return onFailure(
                    AdsterAdsException(
                      code: (snapshot.error as PlatformException).code,
                      message: (snapshot.error as PlatformException).message,
                    ),
                  );
                }
                return onFailure(
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
      'adPlacementName': adPlacementName,
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
}
