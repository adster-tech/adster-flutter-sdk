import Flutter
import AdsFramework

class AdsterRewardedAd : NSObject{
    
    private var widgetId: String
    private var placementId: String
    private var publisherProvidedId: String?
    var isAdLoaded: Bool = false
    private var customTargetingParams: [String:String]?
    private var adClickChannel: FlutterMethodChannel
    private var adLoadChannel: FlutterMethodChannel
    private var rewardedAd: MediationRewardedAd?
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
        rewardedAd?.presentRewarded(from: UIApplication.shared.windows.first!.rootViewController!)
        rewardedAd?.eventDelegate = self
    }
}

extension AdsterRewardedAd: MediationAdDelegate {
    func onBannerAdLoaded(bannerAd: any AdsFramework.MediationBannerAd) {

    }

    func onRewardedAdLoaded(rewardedAd: any AdsFramework.MediationRewardedAd) {
        self.rewardedAd = rewardedAd
        self.onAdLoadComplete?(widgetId)
        self.isAdLoaded = true
        print("Rewarded Ad Loaded \(widgetId)")
    }

    func onRewardedInterstitialAdLoaded(rewardedInterstitialAd: any AdsFramework.MediationRewardedInterstitialAd) {

    }

    func onNativeAdLoaded(nativeAd: any AdsFramework.MediationNativeAd) {

    }

    func onCustomNativeAdLoaded(customNativeAd: any AdsFramework.MediationNativeCustomFormatAd) {

    }

    func onInterstitialAdLoaded(interstitialAd: any MediationInterstitialAd) {

    }

    func onAdFailedToLoad(error: AdError) {
        print("Interstitial Ad request failed with reason \(error.description ?? "")")
        self.isAdLoaded = false
        self.onAdLoadFailed?(error.description ?? "UNKNOWN")
    }
}

extension AdsterRewardedAd: MediationRewardedAdEventDelegate {
    func didRewardUser(reward: AdsFramework.AdReward) {
        adClickChannel.invokeMethod(String("onUserEarnedReward"), arguments:["widgetId":widgetId,])
    }

    func didStartVideo() {
        adClickChannel.invokeMethod(String("onVideoStart"), arguments:["widgetId":widgetId,])
    }

    func didEndVideo() {
        adClickChannel.invokeMethod(String("onVideoComplete"), arguments:["widgetId":widgetId,])
    }

    func ad(didFailToPresentFullScreenContentWithError error: AdError) {
        adClickChannel.invokeMethod(String("onAdFailToPresentFullScreenContentWithError"), arguments: ["widgetId":widgetId,"code":"1","message":error.description])
    }

    func recordRewardedClick() {
        adClickChannel.invokeMethod(String("onAdClicked"), arguments: ["widgetId":widgetId,])
    }

    func recordRewardedImpression() {
        adClickChannel.invokeMethod(String("onAdImpression"), arguments: ["widgetId":widgetId,])
    }
}

