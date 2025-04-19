import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';
import 'package:adster_flutter_sdk/core/adster_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AdsterBannerAd extends StatelessWidget {
  final String adPlacementName;
  final AdsterAdSize adSize;
  final AdsterBannerAdBuilder? onAdLoaded;
  final AdsterAdErrorBuilder onFailure;
  final Widget? loadingWidget;
  final MethodChannel _channel = MethodChannel('adster.channel:adster_banner');

  AdsterBannerAd({
    super.key,
    required this.adPlacementName,
    required this.adSize,
    this.onAdLoaded,
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
                return onAdLoaded != null
                    ? onAdLoaded!(_getPlatformWidget())
                    : SizedBox(
                      height: adSize.height,
                      width: adSize.width,
                      child: _getPlatformWidget(),
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
    return data;
  }

  Widget _getPlatformWidget() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(viewType: 'adster_banner');
      case TargetPlatform.iOS:
        return UiKitView(viewType: 'adster_banner');
      default:
        return Text(
          '$defaultTargetPlatform is not yet supported by the web_view plugin',
        );
    }
  }
}
