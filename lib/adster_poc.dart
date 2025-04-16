
import 'adster_poc_platform_interface.dart';

class AdsterPoc {
  Future<String?> getPlatformVersion() {
    return AdsterPocPlatform.instance.getPlatformVersion();
  }
}
