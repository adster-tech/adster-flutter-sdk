import 'package:adster_flutter_sdk/core/adster_constants.dart';

typedef AdsterRevenueCallback =
    void Function(
      double? revenue,
      String? adUnitId,
      String? network,
      String? currency,
      AdsterPrecisionType? precisionType,
    );

class AdsterRevenuePayload {
  final double? revenue;
  final String? adUnitId;
  final String? network;
  final String? currency;
  final AdsterPrecisionType? precisionType;

  const AdsterRevenuePayload({
    this.revenue,
    this.adUnitId,
    this.network,
    this.currency,
    this.precisionType,
  });

  factory AdsterRevenuePayload.fromMap(Map<dynamic, dynamic> map) {
    return AdsterRevenuePayload(
      revenue: (map['revenue'] as num?)?.toDouble(),
      adUnitId: map['adUnitId'] as String?,
      network: map['network'] as String?,
      currency: map['currency'] as String?,
      precisionType: AdsterPrecisionType.fromName(
        map['precisionType'] as String?,
      ),
    );
  }
}
