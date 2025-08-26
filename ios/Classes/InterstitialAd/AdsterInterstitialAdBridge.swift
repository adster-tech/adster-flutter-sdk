import Flutter
import AdsFramework

class AdsterInterstitialAdBridge : NSObject{
    
    private var adClickChannel: FlutterMethodChannel
    private var adLoadChannel: FlutterMethodChannel
    private var ads: [String:AdsterInterstitialAd] = [:]
    
    init(messenger : FlutterBinaryMessenger) {
        self.adLoadChannel = FlutterMethodChannel(name: "adster.channel:adster_interstitial_ad", binaryMessenger: messenger)
        self.adClickChannel = FlutterMethodChannel(name: "adster.channel:adster_interstitial_ad_click", binaryMessenger: messenger)
        super.init()
        self.adLoadChannel.setMethodCallHandler { call, result in
            if(call.method == "loadInterstitialAd"){
                let args = call.arguments as? [String: Any]
                if(args != nil){
                    let widgetId = args?["widgetId"] as? String
                    if(widgetId != nil){
                        let placement = args?["adPlacementName"] as? String
                        if(placement != nil){
                            print("Received ad load request for placement: \(String(describing: placement))")
                            let publisherProvidedId = args?["publisherProvidedId"] as? String
                            let customTargetingParams = args?["customTargetArgs"] as? [String: String]
                            var interstitialAd: AdsterInterstitialAd?
                            if(self.ads.keys.contains(widgetId ?? "")){
                                interstitialAd = self.ads[widgetId ?? ""] ?? nil
                            }else{
                                interstitialAd = AdsterInterstitialAd(widgetId: widgetId ?? "", placementId: placement ?? "", adClickChannel: self.adClickChannel, adLoadChannel: self.adLoadChannel, publisherProvidedId: publisherProvidedId, customTargetingParams: customTargetingParams)
                                self.ads[widgetId ?? ""] = interstitialAd
                            }
                            interstitialAd?.loadAd()
                            interstitialAd?.onAdLoadComplete = { widgetId in
                                print("Ad load completed. Success: \(widgetId)")
                                result("true")
                            }
                            interstitialAd?.onAdLoadFailed = { error in
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
            }else if(call.method == "showAd"){
                let args = call.arguments as? [String: Any]
                if(args != nil){
                    let widgetId = args?["widgetId"] as? String
                    if(widgetId != nil){
                        if(self.ads.keys.contains(widgetId ?? "")){
                            let interstitialAd = self.ads[widgetId ?? ""] ?? nil
                            if(interstitialAd != nil && (interstitialAd?.isAdLoaded ?? false)){
                                interstitialAd?.showAd()
                                result("true")
                            }else{
                                result(FlutterError(code: "2", message: "Ad not loaded", details: nil))
                            }
                            return
                        }
                        result(FlutterError(code: "3", message: "Ad not initialized", details: nil))
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
        //        self.adLoadChannel.invokeMethod(String(""), arguments: nil, result: { (flutterResult: Any?) in
        //            if let dict = flutterResult as? [String: Any] {
        //                print("Received data from Flutter: \(dict)")
        //            } else if let error = flutterResult as? FlutterError {
        //                print("Flutter error: \(error.message ?? "Unknown error")")
        //            } else if FlutterMethodNotImplemented.isEqual(flutterResult) {
        //                print("Method not implemented on Flutter side.")
        //            } else {
        //                print("Result: \(flutterResult ?? "nil")")
        //            }
        //        })
    }
}
