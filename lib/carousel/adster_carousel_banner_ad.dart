import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';
import 'package:adster_flutter_sdk/banner/adster_banner_callback_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef AdsterCarouselBannerAdBuilder =
    Widget Function(List<Widget> bannerViews);

class AdsterCarouselBannerAd extends StatefulWidget {
  final String adPlacementName;
  final AdsterAdSize adSize;
  final AdsterCarouselBannerAdBuilder? onAdLoaded;
  final AdsterAdErrorBuilder onFailure;
  final Widget? loadingWidget;
  final AdsterBannerAdCallback? callback;

  const AdsterCarouselBannerAd({
    super.key,
    required this.adPlacementName,
    required this.adSize,
    required this.onFailure,
    this.onAdLoaded,
    this.loadingWidget,
    this.callback,
  });

  @override
  State<AdsterCarouselBannerAd> createState() =>
      _AdsterCarouselBannerAdState();
}

class _AdsterCarouselBannerAdState extends State<AdsterCarouselBannerAd> {
  final MethodChannel _channel = const MethodChannel(
    'adster.channel:adster_carousel_banner',
  );
  late final String widgetId;
  late final Future<int> _loadAdFuture;

  @override
  void initState() {
    super.initState();
    widgetId = UniqueKey().toString();
    if (widget.callback != null) {
      AdsterBannerCallbackChannel.instance.registerWidget(
        widgetId,
        widget.callback!,
      );
    }
    _loadAdFuture = _loadAd();
  }

  Future<int> _loadAd() async {
    final count = await _channel.invokeMethod<int>('loadCarouselBanner', {
      'adPlacementName': widget.adPlacementName,
      'widgetId': widgetId,
    });
    return count ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
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
        final views = List.generate(snapshot.data ?? 0, _platformView);
        if (widget.onAdLoaded != null) {
          return widget.onAdLoaded!(views);
        }
        return SizedBox(
          width: widget.adSize.width,
          height: widget.adSize.height,
          child: PageView(children: views),
        );
      },
    );
  }

  Widget _platformView(int index) {
    final params = {'widgetId': widgetId, 'index': index};
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: 'adster_carousel_banner',
          creationParams: params,
          creationParamsCodec: const StandardMessageCodec(),
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: 'adster_carousel_banner',
          creationParams: params,
          creationParamsCodec: const StandardMessageCodec(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  void dispose() {
    AdsterBannerCallbackChannel.instance.removeWidget(widgetId);
    super.dispose();
  }
}
