import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'adster_sdk_platform_interface.dart';



/// An implementation of [AdsterSDKPlatform] that uses method channels.
class MethodChannelAdsterSDK extends AdsterSDKPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('adster_channel');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
