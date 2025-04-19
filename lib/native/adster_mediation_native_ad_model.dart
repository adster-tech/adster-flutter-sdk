class AdsterMediationNativeAd {
  final String? body;
  final String? callToAction;
  final String? headLine;
  final String? imageUrl;
  final String? logo;
  final bool? overrideClickHandling;
  final bool? overrideImpressionHandling;

  AdsterMediationNativeAd({
    this.body,
    this.callToAction,
    this.headLine,
    this.imageUrl,
    this.logo,
    this.overrideClickHandling,
    this.overrideImpressionHandling,
  });

  @override
  String toString() {
    return 'AdsterMediationNativeAd{body: $body, callToAction: $callToAction, headLine: $headLine, imageUrl: $imageUrl, logo: $logo, overrideClickHandling: $overrideClickHandling, overrideImpressionHandling: $overrideImpressionHandling}';
  }
}
