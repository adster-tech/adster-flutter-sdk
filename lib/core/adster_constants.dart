enum AdsterAdSize {
  small(320.0, 50.0),
  medium(300.0, 250.0),
  large(600.0, 600.0);

  final double height;
  final double width;

  const AdsterAdSize(this.width, this.height);

  factory AdsterAdSize.custom(double width, double height) {
    return AdsterAdSize.custom(width, height);
  }
}

enum AdsterNativeAdClickComponent {
  body("body"),
  callToAction("callToAction"),
  headLine("headLine"),
  logo("logo"),
  ratingBar("ratingBar");

  final String name;

  const AdsterNativeAdClickComponent(this.name);

  factory AdsterNativeAdClickComponent.custom(String name) {
    return AdsterNativeAdClickComponent.custom(name);
  }
}
