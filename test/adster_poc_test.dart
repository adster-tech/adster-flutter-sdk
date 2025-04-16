import 'package:flutter_sdk/adster_sdk.dart';
import 'package:flutter_sdk/adster_sdk_method_channel.dart';
import 'package:flutter_sdk/adster_sdk_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAdsterPocPlatform
    with MockPlatformInterfaceMixin
    implements AdsterSDKPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AdsterSDKPlatform initialPlatform = AdsterSDKPlatform.instance;

  test('$MethodChannelAdsterSDK is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAdsterSDK>());
  });

  test('getPlatformVersion', () async {
    AdsterSDK adsterPocPlugin = AdsterSDK();
    MockAdsterPocPlatform fakePlatform = MockAdsterPocPlatform();
    AdsterSDKPlatform.instance = fakePlatform;

    expect(await adsterPocPlugin.getPlatformVersion(), '42');
  });
}
