import Flutter
import AdsFramework

class AdsterCarouselBannerAdBridge: NSObject {
    private let adLoadChannel: FlutterMethodChannel
    let adClickChannel: FlutterMethodChannel
    private var ads: [String: [MediationBannerAd]] = [:]
    private var loaders: [String: AdsterCarouselBannerLoader] = [:]

    init(messenger: FlutterBinaryMessenger) {
        self.adLoadChannel = FlutterMethodChannel(name: "adster.channel:adster_carousel_banner", binaryMessenger: messenger)
        self.adClickChannel = FlutterMethodChannel(name: "adster.channel:adster_banner_ad_click", binaryMessenger: messenger)
        super.init()
        self.adLoadChannel.setMethodCallHandler { call, result in
            guard call.method == "loadCarouselBanner" else {
                result(FlutterMethodNotImplemented)
                return
            }
            let args = call.arguments as? [String: Any]
            guard let widgetId = args?["widgetId"] as? String,
                  let placement = args?["adPlacementName"] as? String else {
                result(FlutterError(code: "MISSING_ARGS", message: "widgetId or placementId not sent", details: nil))
                return
            }
            let publisherProvidedId = args?["publisherProvidedId"] as? String
            let customTargetingParams = args?["customTargetArgs"] as? [String: String]
            let loader = AdsterCarouselBannerLoader(widgetId: widgetId, placementId: placement, adClickChannel: self.adClickChannel, publisherProvidedId: publisherProvidedId, customTargetingParams: customTargetingParams)
            self.loaders[widgetId] = loader
            loader.onAdLoadComplete = { widgetId, ads in
                self.ads[widgetId] = ads
                result(ads.count)
            }
            loader.onAdLoadFailed = { error in
                result(FlutterError(code: "1", message: error, details: nil))
            }
            loader.loadAd()
        }
    }

    func getBannerAd(widgetId: String, index: Int) -> MediationBannerAd? {
        guard let items = ads[widgetId], index >= 0, index < items.count else { return nil }
        return items[index]
    }
}

private class AdsterCarouselBannerLoader: NSObject, MediationAdDelegate {
    let widgetId: String
    let placementId: String
    let adClickChannel: FlutterMethodChannel
    let publisherProvidedId: String?
    let customTargetingParams: [String: String]?
    var onAdLoadComplete: ((String, [MediationBannerAd]) -> Void)?
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

    func onCarouselBannerAdLoaded(carouselBannerAd: any MediationCarouselBannerAd) {
        carouselBannerAd.eventCallbacks = adsterRevenueOnlyCallbacks(widgetId: widgetId, channel: adClickChannel)
        onAdLoadComplete?(widgetId, carouselBannerAd.ads)
    }

    func onAdFailedToLoad(error: AdError) {
        onAdLoadFailed?(error.description ?? "UNKNOWN")
    }
}
