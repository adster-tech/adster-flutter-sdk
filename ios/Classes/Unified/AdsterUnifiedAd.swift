import Flutter
import AdsFramework

class AdsterUnifiedAd : NSObject{
    
    private var widgetId: String
    private var placementId: String
    private var publisherProvidedId: String?
    var isAdLoaded: Bool = false
    private var customTargetingParams: [String:String]?
    private var adClickChannel: FlutterMethodChannel
    private var adLoadChannel: FlutterMethodChannel
    private var nativeAdView: AdsFramework.MediationNativeAd?
    private var bannerAdView: MediationBannerAd?
    let headline = UIView()
    let body = UIView()
    let cta = UIView()
    let logo = UIView()
    var mediaViewByAd: UIView?
    var onNativeAdLoadComplete: ((String,AdsFramework.MediationNativeAd) -> Void)?
    var onBannerAdLoadComplete: ((String, MediationBannerAd) -> Void)?
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
    
    func nativeAd() -> AdsFramework.MediationNativeAd? {
        return self.nativeAdView
    }
    
    func bannerAd() -> MediationBannerAd?{
        return self.bannerAdView
    }
    
    func setMediaViewByAd(mediaView: UIView) {
        self.mediaViewByAd = mediaView
    }
    
    func click(compname: String) {
        self.mediaViewByAd?.gestureRecognizers?.first?.state = .ended
    }
}

extension AdsterUnifiedAd: MediationAdDelegate {
    func onInterstitialAdLoaded(interstitialAd: any AdsFramework.MediationInterstitialAd) {
        
    }
    
    func onRewardedAdLoaded(rewardedAd: any AdsFramework.MediationRewardedAd) {
        
    }
    
    func onNativeAdLoaded(nativeAd: any AdsFramework.MediationNativeAd) {
        self.nativeAdView = nativeAd
        self.onNativeAdLoadComplete?(widgetId,nativeAd)
    }
    
    func onCustomNativeAdLoaded(customNativeAd: any AdsFramework.MediationNativeCustomFormatAd) {
        
    }
    
    func onAdFailedToLoad(error: AdError) {
        print("Banner Ad request failed with reason \(String(describing: error.description))")
        self.onAdLoadFailed?(error.description ?? "UNKNOWN")
    }
    
    func onBannerAdLoaded(bannerAd: MediationBannerAd) {
        self.bannerAdView = bannerAd
        self.onBannerAdLoadComplete?(widgetId,bannerAd)
    }
}

extension AdsterUnifiedAd: MediationNativeAdEventDelegate {
    func recordClick() {
        print("Ad clicked")
        adClickChannel.invokeMethod(String("onAdClicked"), arguments: ["widgetId":widgetId])
    }
    
    func recordImpression() {
        print("Ad impression recorded")
        adClickChannel.invokeMethod(String("onAdImpression"), arguments: ["widgetId":widgetId])
    }
}


