import 'package:flutter_sdk/adster_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class AdsterSDKPlatform extends PlatformInterface {
  /// Constructs a AdsterPocPlatform.
  AdsterSDKPlatform() : super(token: _token);

  static final Object _token = Object();

  static AdsterSDKPlatform _instance = MethodChannelAdsterSDK();

  /// The default instance of [AdsterSDKPlatform] to use.
  ///
  /// Defaults to [MethodChannelAdsterPoc].
  static AdsterSDKPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AdsterSDKPlatform] when
  /// they register themselves.
  static set instance(AdsterSDKPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
