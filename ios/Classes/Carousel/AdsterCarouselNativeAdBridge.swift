import Flutter
import AdsFramework

class AdsterCarouselNativeAdBridge: NSObject {
    private let adLoadChannel: FlutterMethodChannel
    let adClickChannel: FlutterMethodChannel
    private var ads: [String: [MediationNativeAd]] = [:]
    private var loaders: [String: AdsterCarouselNativeLoader] = [:]

    init(messenger: FlutterBinaryMessenger) {
        self.adLoadChannel = FlutterMethodChannel(name: "adster.channel:adster_carousel_native", binaryMessenger: messenger)
        self.adClickChannel = FlutterMethodChannel(name: "adster.channel:adster_native_ad_click", binaryMessenger: messenger)
        super.init()
        self.adLoadChannel.setMethodCallHandler { call, result in
            if call.method == "loadCarouselNative" {
                let args = call.arguments as? [String: Any]
                guard let widgetId = args?["widgetId"] as? String,
                      let placement = args?["adPlacementName"] as? String else {
                    result(FlutterError(code: "MISSING_ARGS", message: "widgetId or placementId not sent", details: nil))
                    return
                }
                let publisherProvidedId = args?["publisherProvidedId"] as? String
                let customTargetingParams = args?["customTargetArgs"] as? [String: String]
                let loader = AdsterCarouselNativeLoader(widgetId: widgetId, placementId: placement, adClickChannel: self.adClickChannel, publisherProvidedId: publisherProvidedId, customTargetingParams: customTargetingParams)
                self.loaders[widgetId] = loader
                loader.onAdLoadComplete = { widgetId, ads in
                    self.ads[widgetId] = ads
                    let payload = ads.map { ad in
                        [
                            "body": ad.body ?? "",
                            "callToAction": ad.callToAction ?? "",
                            "headLine": ad.headline ?? "",
                            "imageUrl": ad.icon ?? "",
                            "logo": ad.icon ?? "",
                            "overrideClickHandling": ad.overrideClickHandling,
                            "overrideImpressionHandling": ad.overrideImpressionHandling
                        ] as [String : Any]
                    }
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
                        result(String(data: jsonData, encoding: .utf8))
                    } catch {
                        result(FlutterError(code: "1", message: "Failed to convert dictionary to JSON", details: nil))
                    }
                }
                loader.onAdLoadFailed = { error in
                    result(FlutterError(code: "1", message: error, details: nil))
                }
                loader.loadAd()
            } else if call.method == "nativeMediaClick" {
                result("")
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }

    func getNativeAd(widgetId: String, index: Int) -> MediationNativeAd? {
        guard let items = ads[widgetId], index >= 0, index < items.count else { return nil }
        return items[index]
    }
}

private class AdsterCarouselNativeLoader: NSObject, MediationAdDelegate {
    let widgetId: String
    let placementId: String
    let adClickChannel: FlutterMethodChannel
    let publisherProvidedId: String?
    let customTargetingParams: [String: String]?
    var onAdLoadComplete: ((String, [MediationNativeAd]) -> Void)?
    var onAdLoadFailed: ((String) -> Void)?

    init(widgetId: String, placementId: String, adClickChannel: FlutterMethodChannel, publisherProvidedId: String?, customTargetingParams: [String: String]?) {
        self.widgetId = widgetId
        self.placementId = placementId
        self.adClickChannel = adClickChannel
        self.publisherProvidedId = publisherProvidedId
        self.customTargetingParams = customTargetingParams
    }

    func loadAd() {
        let loader = AdSterAdLoader()
        loader.delegate = self
        loader.loadAd(adRequestConfiguration: AdRequestConfiguration(placement: placementId, viewController: UIApplication.shared.windows.first!.rootViewController!, publisherProvidedId: publisherProvidedId ?? nil, customTargetingValues: customTargetingParams ?? [:]))
    }

    func onCarouselNativeAdLoaded(carouselNativeAd: any MediationCarouselNativeAd) {
        carouselNativeAd.eventCallbacks = adsterRevenueOnlyCallbacks(widgetId: widgetId, channel: adClickChannel)
        onAdLoadComplete?(widgetId, carouselNativeAd.ads)
    }

    func onBannerAdLoaded(bannerAd: any AdsFramework.MediationBannerAd) {
    }

    func onCarouselBannerAdLoaded(carouselBannerAd: any AdsFramework.MediationCarouselBannerAd) {
    }

    func onInterstitialAdLoaded(interstitialAd: any AdsFramework.MediationInterstitialAd) {
    }

    func onRewardedAdLoaded(rewardedAd: any AdsFramework.MediationRewardedAd) {
    }

    func onRewardedInterstitialAdLoaded(rewardedInterstitialAd: any AdsFramework.MediationRewardedInterstitialAd) {
    }

    func onNativeAdLoaded(nativeAd: any AdsFramework.MediationNativeAd) {
    }

    func onNativeRewardAdLoaded(nativeRewardAd: any AdsFramework.MediationNativeRewardAd) {
    }

    func onCustomNativeAdLoaded(customNativeAd: any AdsFramework.MediationNativeCustomFormatAd) {
    }

    func onAppOpenAdLoaded(appOpenAd: any AdsFramework.MediationAppOpenAd) {
    }

    func onAdRevenuePaid(revenue: Double, adUnitId: String, network: String, currency: String, precisionType: AdsFramework.PrecisionType) {
        adClickChannel.invokeMethod(
            "onAdRevenuePaid",
            arguments: adsterRevenueArguments(
                widgetId: widgetId,
                revenue: revenue,
                adUnitId: adUnitId,
                network: network,
                currency: currency,
                precisionType: precisionType
            )
        )
    }

    func onAdFailedToLoad(error: AdError) {
        onAdLoadFailed?(error.description ?? "UNKNOWN")
    }
}
