import Flutter
import AdsFramework

class AdsterBannerAd : NSObject{
    
    private var widgetId: String
    private var placementId: String
    private var publisherProvidedId: String?
    var isAdLoaded: Bool = false
    private var customTargetingParams: [String: [String]]?
    private var adClickChannel: FlutterMethodChannel
    private var bannerAdView: MediationBannerAd?
    private var loadResult: FlutterResult?
    private(set) var isDisposed = false
    
    init(widgetId: String,placementId: String, adClickChannel: FlutterMethodChannel, publisherProvidedId: String?,customTargetingParams: [String: [String]]?) {
        self.widgetId = widgetId
        self.adClickChannel = adClickChannel
        self.placementId = placementId
        self.publisherProvidedId = publisherProvidedId
        self.customTargetingParams = customTargetingParams
        super.init()
    }
    
    func loadAd(result: @escaping FlutterResult) {
        guard !isDisposed, loadResult == nil, !isAdLoaded else {
            result(FlutterError(code: "BANNER_UNAVAILABLE", message: "Banner already loaded or disposed", details: nil))
            return
        }
        loadResult = result
        startLoading()
    }

    func startLoading() {
        guard let controller = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
                ?? UIApplication.shared.windows.first?.rootViewController else {
            finish(FlutterError(code: "NO_VIEW_CONTROLLER", message: "No root view controller", details: nil))
            return
        }
        let loader = AdSterAdLoader()
        loader.delegate = self
        loader.loadAd(adRequestConfiguration: AdRequestConfiguration(
            placement: placementId, viewController: controller,
            publisherProvidedId: publisherProvidedId, customTargetingValues: customTargetingParams ?? [:]))
    }

    private func finish(_ value: Any?) {
        let result = loadResult
        loadResult = nil
        result?(value)
    }

    func dispose() {
        guard !isDisposed else { return }
        isDisposed = true
        isAdLoaded = false
        let ad = bannerAdView
        bannerAdView = nil
        ad?.eventDelegate = nil
        ad?.eventCallbacks = nil
        ad?.view?.removeFromSuperview()
        ad?.destroy()
        finish(FlutterError(code: "BANNER_DISPOSED", message: "Banner disposed before loading completed", details: nil))
    }

    private func onMain(_ action: @escaping () -> Void) {
        if Thread.isMainThread { action() }
        else { DispatchQueue.main.async(execute: action) }
    }

    private func emit(_ method: String) {
        guard !isDisposed else { return }
        adClickChannel.invokeMethod(method, arguments: ["widgetId": widgetId])
    }

    func bannerView() -> MediationBannerAd? {
        bannerAdView
    }
}

extension AdsterBannerAd: MediationAdDelegate {
    func onCarouselBannerAdLoaded(carouselBannerAd: any AdsFramework.MediationCarouselBannerAd) {
    }

    func onNativeRewardAdLoaded(nativeRewardAd: any AdsFramework.MediationNativeRewardAd) {
    }

    func onCarouselNativeAdLoaded(carouselNativeAd: any AdsFramework.MediationCarouselNativeAd) {
    }

    func onAppOpenAdLoaded(appOpenAd: any AdsFramework.MediationAppOpenAd) {
    }

    func onAdRevenuePaid(revenue: Double, adUnitId: String, network: String, currency: String, precisionType: AdsFramework.PrecisionType) {
        onMain { [self] in
            guard !isDisposed else { return }
            adClickChannel.invokeMethod("onAdRevenuePaid", arguments: adsterRevenueArguments(
                widgetId: widgetId, revenue: revenue, adUnitId: adUnitId,
                network: network, currency: currency, precisionType: precisionType))
        }
    }

    func onInterstitialAdLoaded(interstitialAd: any AdsFramework.MediationInterstitialAd) {

    }

    func onRewardedAdLoaded(rewardedAd: any AdsFramework.MediationRewardedAd) {

    }

    func onRewardedInterstitialAdLoaded(rewardedInterstitialAd: any AdsFramework.MediationRewardedInterstitialAd) {

    }

    func onNativeAdLoaded(nativeAd: any AdsFramework.MediationNativeAd) {

    }

    func onCustomNativeAdLoaded(customNativeAd: any AdsFramework.MediationNativeCustomFormatAd) {

    }

    func onAdFailedToLoad(error: AdError) {
        onMain { [self] in
            guard !isDisposed, loadResult != nil else { return }
            finish(FlutterError(code: "1", message: error.description ?? "UNKNOWN", details: nil))
        }
    }

    func onBannerAdLoaded(bannerAd: MediationBannerAd) {
        onMain { [self] in
            guard !isDisposed, loadResult != nil else {
                // An old load must never revive a disposed slot.
                if bannerAdView !== bannerAd { bannerAd.destroy() }
                return
            }
            guard bannerAd.view != nil else {
                bannerAd.destroy()
                finish(FlutterError(code: "BANNER_VIEW_MISSING", message: "Loaded banner has no native view", details: nil))
                return
            }
            bannerAdView = bannerAd
            isAdLoaded = true
            // Weak callbacks avoid ad -> platform view -> bridge -> ad retain cycles.
            bannerAd.eventCallbacks = MediationAdEventCallbacks(
                onClick: { [weak self] in self?.onMain { [weak self] in self?.emit("onAdClicked") } },
                onImpression: { [weak self] in self?.onMain { [weak self] in self?.emit("onAdImpression") } },
                onRevenuePaid: { [weak self] revenue, unit, network, currency, precision in
                    self?.onAdRevenuePaid(revenue: revenue, adUnitId: unit, network: network,
                                          currency: currency, precisionType: precision)
                })
            finish("")
        }
    }
}
