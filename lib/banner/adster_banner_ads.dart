import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';
import 'package:adster_flutter_sdk/banner/adster_banner_callback_channel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AdsterBannerAd extends StatefulWidget {
  final String adPlacementName;
  final AdsterAdSize adSize;
  final AdsterBannerAdBuilder? onAdLoaded;
  final AdsterAdErrorBuilder onFailure;
  final Widget? loadingWidget;
  final AdsterBannerAdCallback? clickCallback;

  const AdsterBannerAd({
    super.key,
    required this.adPlacementName,
    required this.adSize,
    this.onAdLoaded,
    required this.onFailure,
    this.loadingWidget,
    this.clickCallback,
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
      AdsterBannerCallbackChannel.instance.registerWidget(
        widgetId,
        AdsterBannerAdCallback(
          onAdClicked: () {
            widget.clickCallback?.onAdClicked.call();
          },
          onAdImpression: () {
            widget.clickCallback?.onAdImpression.call();
          },
          onAdRevenuePaid: (revenue, adUnitId, network) {
            widget.clickCallback?.onAdRevenuePaid.call(
              revenue,
              adUnitId,
              network,
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
    });
    return data;
  }

  Widget _getPlatformWidget() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: 'adster_banner',
          creationParams: {
            'adPlacementName': widget.adPlacementName,
            'widgetId': widgetId,
          },
          creationParamsCodec: StandardMessageCodec(),
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

  @override
  void dispose() {
    AdsterBannerCallbackChannel.instance.removeWidget(widgetId);
    super.dispose();
  }
}
