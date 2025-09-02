import Flutter
import AdsFramework

class AdsterBannerAdBridge : NSObject{
    
    var adClickChannel: FlutterMethodChannel
    private var adLoadChannel: FlutterMethodChannel
    private var ads: [String:AdsterBannerAd] = [:]
    
    init(messenger : FlutterBinaryMessenger) {
        self.adLoadChannel = FlutterMethodChannel(name: "adster.channel:adster_banner", binaryMessenger: messenger)
        self.adClickChannel = FlutterMethodChannel(name: "adster.channel:adster_banner_ad_click", binaryMessenger: messenger)
        super.init()
        self.adLoadChannel.setMethodCallHandler { call, result in
            if(call.method == "loadBanner"){
                let args = call.arguments as? [String: Any]
                if(args != nil){
                    let widgetId = args?["widgetId"] as? String
                    if(widgetId != nil){
                        let placement = args?["adPlacementName"] as? String
                        if(placement != nil){
                            print("Received ad load request for placement: \(String(describing: placement))")
                            let publisherProvidedId = args?["publisherProvidedId"] as? String
                            let customTargetingParams = args?["customTargetArgs"] as? [String: String]
                            var nativeAd: AdsterBannerAd?
                            if(self.ads.keys.contains(widgetId ?? "")){
                                nativeAd = self.ads[widgetId ?? ""] ?? nil
                            }else{
                                nativeAd = AdsterBannerAd(widgetId: widgetId ?? "", placementId: placement ?? "", adClickChannel: self.adClickChannel, adLoadChannel: self.adLoadChannel, publisherProvidedId: publisherProvidedId, customTargetingParams: customTargetingParams)
                                self.ads[widgetId ?? ""] = nativeAd
                            }
                            nativeAd?.loadAd()
                            nativeAd?.onAdLoadComplete = { widgetId,bannerAdView in
                                print("Banner load completed. Success: \(widgetId) \(bannerAdView)")
                                result("")
                            }
                            nativeAd?.onAdLoadFailed = { error in
                                result(FlutterError(code: "1", message: error, details: nil))
                            }
                            return
                        }else{
                            result(FlutterError(code: "MISSING_ARGS", message: "placementId not sent", details: nil))
                        }
                    }else{
                        result(FlutterError(code: "MISSING_ARGS", message: "widgetId not sent", details: nil))
                    }
                }else{
                    result(FlutterError(code: "EMPTY_ARGS", message: "Args not sent", details: nil))
                }
            }else{
                result(FlutterMethodNotImplemented)
            }
            
        }
    }
    
    func getBannerAd(widgetId: String) -> AdsterBannerAd? {
        return ads[widgetId]
    }
}
