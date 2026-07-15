import Flutter
import AdsFramework

class AdsterNativeAd : NSObject{
    
    private var widgetId: String
    private var placementId: String
    private var publisherProvidedId: String?
    var isAdLoaded: Bool = false
    private var customTargetingParams: [String:String]?
    private var adClickChannel: FlutterMethodChannel
    private var adLoadChannel: FlutterMethodChannel
    private var nativeAdView: AdsFramework.MediationNativeAd?
    private var customNativeAdView: AdsFramework.MediationNativeCustomFormatAd?
    let headline = UIView()
    let body = UIView()
    let cta = UIView()
    let logo = UIView()
    var mediaViewByAd: UIView?
    var onAdLoadComplete: ((String,AdsFramework.MediationNativeAd) -> Void)?
    var onCustomNativeAdLoadComplete: ((String, AdsFramework.MediationNativeCustomFormatAd) -> Void)?
    var onAdLoadFailed: ((String) -> Void)?
    
    init(widgetId: String,placementId: String, adClickChannel: FlutterMethodChannel, adLoadChannel: FlutterMethodChannel,publisherProvidedId: String?,customTargetingParams: [String:String]?) {
        self.widgetId = widgetId
        self.adClickChannel = adClickChannel
        self.adLoadChannel = adLoadChannel
        self.placementId = placementId
        self.publisherProvidedId = publisherProvidedId
        self.customTargetingParams = customTargetingParams
        super.init()
    }
    
    func loadAd() -> Void {
        let loader = AdSterAdLoader()
        loader.delegate = self
        
        loader.loadAd(adRequestConfiguration: AdRequestConfiguration(placement: placementId, viewController: UIApplication.shared.windows.first!.rootViewController!, publisherProvidedId: publisherProvidedId ?? nil, customTargetingValues: customTargetingParams ?? [:]))
    }
    
    func mediaView() -> AdsFramework.MediationNativeAd? {
        nativeAdView
    }

    func customNativeAd() -> AdsFramework.MediationNativeCustomFormatAd? {
        customNativeAdView
    }
    
    func setMediaViewByAd(mediaView: UIView) {
        self.mediaViewByAd = mediaView
    }
    
    func click(compname: String) {
        self.mediaViewByAd?.gestureRecognizers?.first?.state = .ended
    }
}

extension AdsterNativeAd: MediationAdDelegate {
    func onCarouselBannerAdLoaded(carouselBannerAd: any AdsFramework.MediationCarouselBannerAd) {
    }

    func onNativeRewardAdLoaded(nativeRewardAd: any AdsFramework.MediationNativeRewardAd) {
    }

    func onCarouselNativeAdLoaded(carouselNativeAd: any AdsFramework.MediationCarouselNativeAd) {
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

    func onInterstitialAdLoaded(interstitialAd: any AdsFramework.MediationInterstitialAd) {

    }

    func onRewardedAdLoaded(rewardedAd: any AdsFramework.MediationRewardedAd) {

    }

    func onRewardedInterstitialAdLoaded(rewardedInterstitialAd: any AdsFramework.MediationRewardedInterstitialAd) {

    }

    func onNativeAdLoaded(nativeAd: any AdsFramework.MediationNativeAd) {
        self.nativeAdView = nativeAd
        self.nativeAdView?.eventCallbacks = adsterRevenueOnlyCallbacks(
            widgetId: widgetId,
            channel: adClickChannel
        )
        self.onAdLoadComplete?(widgetId,nativeAd)
    }

    func onCustomNativeAdLoaded(customNativeAd: any AdsFramework.MediationNativeCustomFormatAd) {
        self.customNativeAdView = customNativeAd
        self.customNativeAdView?.eventCallbacks = adsterRevenueOnlyCallbacks(
            widgetId: widgetId,
            channel: adClickChannel
        )
        self.onCustomNativeAdLoadComplete?(widgetId, customNativeAd)
    }

    func onAdFailedToLoad(error: AdError) {
        print("Banner Ad request failed with reason \(String(describing: error.description))")
        self.onAdLoadFailed?(error.description ?? "UNKNOWN")
    }

    func onBannerAdLoaded(bannerAd: MediationBannerAd) {

    }
}

extension AdsterNativeAd: MediationNativeAdEventDelegate {
    func recordNativeClick() {
        print("Ad clicked")
        adClickChannel.invokeMethod(String("onAdClicked"), arguments: ["widgetId":widgetId])
    }

    func recordNativeImpression() {
        print("Ad impression recorded")
        adClickChannel.invokeMethod(String("onAdImpression"), arguments: ["widgetId":widgetId])
    }
}
