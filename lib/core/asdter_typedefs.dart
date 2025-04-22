import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';
import 'package:flutter/material.dart' show Widget;

import '../native/adster_mediation_native_ad_model.dart';

typedef AdsterNativeAdBuilder =
    Widget Function(AdsterMediationNativeAd value, Widget nativeMediaView);
typedef AdsterBannerAdBuilder = Widget Function(Widget bannerView);
typedef AdsterAdErrorBuilder = Widget Function(AdsterAdsException error);

class AdsterAdsException implements Exception {
  /// An error code.
  final String code;

  /// A human-readable error message, possibly null.
  final String? message;

  /// Error details, possibly null.
  ///
  /// This property is `dynamic`, which means type-checking is skipped when accessing
  /// this property. To minimize the risk of type errors at runtime, the value should
  /// be cast to `Object?` when accessed.
  final dynamic details;

  AdsterAdsException({
    required this.code,
    this.message,
    this.details,
    this.stacktrace,
  });

  final String? stacktrace;

  @override
  String toString() =>
      'AdsterAdsException($code, $message, $details, $stacktrace)';
}
