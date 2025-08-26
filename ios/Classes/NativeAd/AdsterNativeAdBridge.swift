import Flutter
import AdsFramework

class AdsterNativeAdBridge : NSObject{
    
    var adClickChannel: FlutterMethodChannel
    private var adLoadChannel: FlutterMethodChannel
    private var ads: [String:AdsterNativeAd] = [:]
    
    init(messenger : FlutterBinaryMessenger) {
        self.adLoadChannel = FlutterMethodChannel(name: "adster.channel:adster_native_ad", binaryMessenger: messenger)
        self.adClickChannel = FlutterMethodChannel(name: "adster.channel:adster_native_ad_click", binaryMessenger: messenger)
        super.init()
        self.adLoadChannel.setMethodCallHandler { call, result in
            if(call.method == "loadNativeAd"){
                let args = call.arguments as? [String: Any]
                if(args != nil){
                    let widgetId = args?["widgetId"] as? String
                    if(widgetId != nil){
                        let placement = args?["adPlacementName"] as? String
                        if(placement != nil){
                            print("Received ad load request for placement: \(String(describing: placement))")
                            let publisherProvidedId = args?["publisherProvidedId"] as? String
                            let customTargetingParams = args?["customTargetArgs"] as? [String: String]
                            var nativeAd: AdsterNativeAd?
                            if(self.ads.keys.contains(widgetId ?? "")){
                                nativeAd = self.ads[widgetId ?? ""] ?? nil
                            }else{
                                nativeAd = AdsterNativeAd(widgetId: widgetId ?? "", placementId: placement ?? "", adClickChannel: self.adClickChannel, adLoadChannel: self.adLoadChannel, publisherProvidedId: publisherProvidedId, customTargetingParams: customTargetingParams)
                                self.ads[widgetId ?? ""] = nativeAd
                            }
                            nativeAd?.loadAd()
                            nativeAd?.onAdLoadComplete = { widgetId,nativeAdView in
                                print("NativeAd load completed. Success: \(widgetId) \(nativeAdView)")
                                let data = ["body":nativeAdView.body ,"callToAction":nativeAdView.callToAction,"headLine":nativeAdView.headline,"imageUrl":nativeAdView.icon,"logo":nativeAdView.icon,"overrideClickHandling":nativeAdView.overrideClickHandling,"overrideImpressionHandling":nativeAdView.overrideImpressionHandling]
                                do {
                                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                                    let jsonString = String(data: jsonData, encoding: .utf8)
                                    print("JSON String: \(jsonString ?? "")")
                                    result(jsonString)
                                } catch {
                                    print("Failed to convert dictionary to JSON: \(error.localizedDescription)")
                                    result(FlutterError(code: "1", message: "Failed to convert dictionary to JSON", details: nil))
                                }
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
            }else if(call.method == "nativeMediaClick"){
                let args = call.arguments as? [String: Any]
                if(args != nil){
                    let widgetId = args?["widgetId"] as? String
                    let componentName = args?["componentName"] as? String
                    if(widgetId != nil){
                        //print("nativeMediaClick: widgetId \(String(describing: widgetId)) componentName \(String(describing: componentName))")
                        result("")
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
    
    func getNativeAd(widgetId: String) -> AdsterNativeAd? {
        return ads[widgetId]
    }
}
