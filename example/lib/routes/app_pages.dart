import 'package:flutter_sdk_example/banner/banner.dart';
import 'package:flutter_sdk_example/banner/banner_controller.dart';
import 'package:flutter_sdk_example/home/home.dart';
import 'package:flutter_sdk_example/home/home_controller.dart';
import 'package:flutter_sdk_example/interstitial/interstitial.dart';
import 'package:flutter_sdk_example/interstitial/interstitial_controller.dart';
import 'package:flutter_sdk_example/native/native.dart';
import 'package:flutter_sdk_example/native/native_controller.dart';
import 'package:flutter_sdk_example/rewarded/rewarded.dart';
import 'package:flutter_sdk_example/rewarded/rewarded_controller.dart';
import 'package:flutter_sdk_example/unified/unified.dart';
import 'package:flutter_sdk_example/unified/unified_controller.dart';
import 'package:get/get.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => HomeWidget(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => HomeController());
      }),
    ),
    GetPage(
      name: AppRoutes.banner,
      page: () => BannerWidget(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => BannerController());
      }),
    ),
    GetPage(
      name: AppRoutes.native,
      page: () => NativeWidget(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => NativeController());
      }),
    ),
    GetPage(
      name: AppRoutes.interstitial,
      page: () => InterstitialWidget(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => InterstitialController());
      }),
    ),
    GetPage(
      name: AppRoutes.rewarded,
      page: () => RewardedWidget(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => RewardedController());
      }),
    ),
    GetPage(
      name: AppRoutes.unified,
      page: () => UnifiedWidget(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => UnifiedController());
      }),
    ),
  ];
}
