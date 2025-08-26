import Flutter
import AdsFramework

class AdsterBannerAd : NSObject{
    
    private var widgetId: String
    private var placementId: String
    private var publisherProvidedId: String?
    var isAdLoaded: Bool = false
    private var customTargetingParams: [String:String]?
    private var adClickChannel: FlutterMethodChannel
    private var adLoadChannel: FlutterMethodChannel
    private var bannerAdView: MediationBannerAd?
    var onAdLoadComplete: ((String,MediationBannerAd) -> Void)?
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
    
    func bannerView() -> MediationBannerAd? {
        bannerAdView
    }
}

extension AdsterBannerAd: MediationAdDelegate {
    func onInterstitialAdLoaded(interstitialAd: any AdsFramework.MediationInterstitialAd) {
        
    }
    
    func onRewardedAdLoaded(rewardedAd: any AdsFramework.MediationRewardedAd) {
        
    }
    
    func onNativeAdLoaded(nativeAd: any AdsFramework.MediationNativeAd) {
        
    }
    
    func onCustomNativeAdLoaded(customNativeAd: any AdsFramework.MediationNativeCustomFormatAd) {
        
    }
    
    func onAdFailedToLoad(error: AdError) {
        print("Banner Ad request failed with reason \(String(describing: error.description))")
        self.onAdLoadFailed?(error.description ?? "UNKNOWN")
    }
    
    func onBannerAdLoaded(bannerAd: MediationBannerAd) {
        self.bannerAdView = bannerAd
        self.onAdLoadComplete?(widgetId,bannerAd)
    }
}

