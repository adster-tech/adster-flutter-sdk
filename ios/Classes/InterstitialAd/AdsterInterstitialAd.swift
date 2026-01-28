import Flutter
import AdsFramework

class AdsterInterstitialAd : NSObject{
    
    private var widgetId: String
    private var placementId: String
    private var publisherProvidedId: String?
    var isAdLoaded: Bool = false
    private var customTargetingParams: [String:String]?
    private var adClickChannel: FlutterMethodChannel
    private var adLoadChannel: FlutterMethodChannel
    private var interstitialAd: MediationInterstitialAd?
    var onAdLoadComplete: ((String) -> Void)?
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
    
    func showAd() -> Void {
        interstitialAd?.presentInterstitial(from: UIApplication.shared.windows.first!.rootViewController!)
        interstitialAd?.eventDelegate = self
    }
}

extension AdsterInterstitialAd: MediationAdDelegate {
    func onBannerAdLoaded(bannerAd: any AdsFramework.MediationBannerAd) {

    }

    func onRewardedAdLoaded(rewardedAd: any AdsFramework.MediationRewardedAd) {

    }

    func onRewardedInterstitialAdLoaded(rewardedInterstitialAd: any AdsFramework.MediationRewardedInterstitialAd) {

    }

    func onNativeAdLoaded(nativeAd: any AdsFramework.MediationNativeAd) {

    }

    func onCustomNativeAdLoaded(customNativeAd: any AdsFramework.MediationNativeCustomFormatAd) {

    }

    func onInterstitialAdLoaded(interstitialAd: any MediationInterstitialAd) {
        self.interstitialAd = interstitialAd
        self.onAdLoadComplete?(widgetId)
        self.isAdLoaded = true
        print("Interstitial Ad Loaded")
        //interstitialAd.presentInterstitial(from: nil)
        //interstitialAd.eventDelegate = self
    }

    func onAdFailedToLoad(error: AdError) {
        print("Interstitial Ad request failed with reason \(error.description ?? "")")
        self.isAdLoaded = false
        self.onAdLoadFailed?(error.description ?? "UNKNOWN")
    }
}

extension AdsterInterstitialAd: MediationInterstitialAdEventDelegate {
    func ad(didFailToPresentFullScreenContentWithError error: AdError) {
        adClickChannel.invokeMethod(String("onAdFailToPresentFullScreenContentWithError"), arguments: ["widgetId":widgetId,"code":"1","message":error.description])
    }

    func adWillPresentFullScreenContent() {
        adClickChannel.invokeMethod(String("onAdOpened"), arguments:["widgetId":widgetId,])
    }

    func adDidDismissFullScreenContent() {
        adClickChannel.invokeMethod(String("onAdClosed"), arguments: ["widgetId":widgetId,])
    }

    func recordInterstitialClick() {
        adClickChannel.invokeMethod(String("onAdClicked"), arguments: ["widgetId":widgetId,])
    }

    func recordInterstitialImpression() {
        adClickChannel.invokeMethod(String("onAdImpression"), arguments: ["widgetId":widgetId,])
    }
}

