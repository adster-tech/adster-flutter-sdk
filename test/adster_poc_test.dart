import 'package:flutter_test/flutter_test.dart';
import 'package:adster_poc/adster_poc.dart';
import 'package:adster_poc/adster_poc_platform_interface.dart';
import 'package:adster_poc/adster_poc_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAdsterPocPlatform
    with MockPlatformInterfaceMixin
    implements AdsterPocPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AdsterPocPlatform initialPlatform = AdsterPocPlatform.instance;

  test('$MethodChannelAdsterPoc is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAdsterPoc>());
  });

  test('getPlatformVersion', () async {
    AdsterPoc adsterPocPlugin = AdsterPoc();
    MockAdsterPocPlatform fakePlatform = MockAdsterPocPlatform();
    AdsterPocPlatform.instance = fakePlatform;

    expect(await adsterPocPlugin.getPlatformVersion(), '42');
  });
}
