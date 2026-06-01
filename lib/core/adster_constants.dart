class AdsterAdSize {
  final double width;
  final double height;

  const AdsterAdSize(this.width, this.height);

  static const small = AdsterAdSize(320.0, 50.0);
  static const medium = AdsterAdSize(300.0, 250.0);
  static const large = AdsterAdSize(600.0, 600.0);

  factory AdsterAdSize.custom(double width, double height) {
    return AdsterAdSize(width, height);
  }

  @override
  String toString() => "${width}x$height";
}

enum AdsterNativeAdClickComponent {
  body("body"),
  callToAction("callToAction"),
  headline("headline"),
  logo("logo"),
  ratingBar("ratingBar");

  final String name;

  const AdsterNativeAdClickComponent(this.name);

  factory AdsterNativeAdClickComponent.custom(String name) {
    return AdsterNativeAdClickComponent.custom(name);
  }
}

enum AdsterPrecisionType {
  unknown,
  estimated,
  publisherProvided,
  precise;

  static AdsterPrecisionType? fromName(String? name) {
    if (name == null || name.isEmpty) {
      return null;
    }
    final normalized = name.replaceAll('_', '').toLowerCase();
    for (final value in AdsterPrecisionType.values) {
      if (value.name.toLowerCase() == normalized) {
        return value;
      }
    }
    return AdsterPrecisionType.unknown;
  }
}
