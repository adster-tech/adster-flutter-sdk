class AdsterNativeCustomAdData {
  final String widgetId;
  final String? customFormatId;
  final List<String> availableAssetNames;

  const AdsterNativeCustomAdData({
    required this.widgetId,
    this.customFormatId,
    this.availableAssetNames = const [],
  });

  factory AdsterNativeCustomAdData.fromJson(Map<String, dynamic> json) {
    return AdsterNativeCustomAdData(
      widgetId: json['widgetId'] as String,
      customFormatId: json['customFormatId'] as String?,
      availableAssetNames:
          (json['availableAssetNames'] as List<dynamic>? ?? const [])
              .map((value) => value.toString())
              .toList(),
    );
  }
}
