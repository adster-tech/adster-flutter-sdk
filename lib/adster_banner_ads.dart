import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AdsterBannerAds extends StatelessWidget {
  final String adPlacementName;
  final MethodChannel _channel = MethodChannel('adster_banner');

  AdsterBannerAds({super.key, required this.adPlacementName});

  @override
  Widget build(BuildContext context) {
    /*const String viewType = 'my_plugin_view';
    if(TargetPlatform.android){
    return AndroidView(viewType: viewType, layoutDirection: TextDirection.ltr);*/

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: 'adster_banner',
          onPlatformViewCreated: (id) {
            _channel
                .invokeMethod('loadBanner', {
                  'adPlacementName': adPlacementName,
                })
                .onError((error, stackTrace) {
                  log(error.toString());
                })
                .then((value) {
                  log(value.toString());
                });
          },
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: 'adster_banner',
          onPlatformViewCreated: (id) {
            _channel.invokeMethod('loadBanner', {
              'adPlacementName': adPlacementName,
            });
          },
        );
      default:
        return Text(
          '$defaultTargetPlatform is not yet supported by the web_view plugin',
        );
    }
  }
}
