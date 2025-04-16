import 'adster_sdk_platform_interface.dart';

class AdsterSDK {
  Future<String?> getPlatformVersion() {
    return AdsterSDKPlatform.instance.getPlatformVersion();
  }
}
