import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'adster_poc_platform_interface.dart';

/// An implementation of [AdsterPocPlatform] that uses method channels.
class MethodChannelAdsterPoc extends AdsterPocPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('adster_poc');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
