enum AdsterAdSize {
  small(320.0, 50.0),
  medium(300.0, 250.0),
  large(600.0, 600.0);

  final double height;
  final double width;

  const AdsterAdSize(this.width, this.height);

  factory AdsterAdSize.custom(num width, num height) {
    return AdsterAdSize.custom(width, height);
  }
}
