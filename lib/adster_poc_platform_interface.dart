import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'adster_poc_method_channel.dart';

abstract class AdsterPocPlatform extends PlatformInterface {
  /// Constructs a AdsterPocPlatform.
  AdsterPocPlatform() : super(token: _token);

  static final Object _token = Object();

  static AdsterPocPlatform _instance = MethodChannelAdsterPoc();

  /// The default instance of [AdsterPocPlatform] to use.
  ///
  /// Defaults to [MethodChannelAdsterPoc].
  static AdsterPocPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AdsterPocPlatform] when
  /// they register themselves.
  static set instance(AdsterPocPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
