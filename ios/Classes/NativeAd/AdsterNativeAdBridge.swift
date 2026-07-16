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
            }else if(call.method == "loadCustomNativeAd"){
                let args = call.arguments as? [String: Any]
                guard let widgetId = args?["widgetId"] as? String else {
                    result(FlutterError(code: "MISSING_ARGS", message: "widgetId not sent", details: nil))
                    return
                }
                guard let placement = args?["adPlacementName"] as? String else {
                    result(FlutterError(code: "MISSING_ARGS", message: "placementId not sent", details: nil))
                    return
                }
                let publisherProvidedId = args?["publisherProvidedId"] as? String
                let customTargetingParams = args?["customTargetArgs"] as? [String: String]
                let nativeAd = self.ads[widgetId] ?? AdsterNativeAd(widgetId: widgetId, placementId: placement, adClickChannel: self.adClickChannel, adLoadChannel: self.adLoadChannel, publisherProvidedId: publisherProvidedId, customTargetingParams: customTargetingParams)
                self.ads[widgetId] = nativeAd
                nativeAd.onCustomNativeAdLoadComplete = { widgetId, customNativeAd in
                    let data: [String: Any] = [
                        "widgetId": widgetId,
                        "customFormatId": customNativeAd.getCustomFormatId() ?? "",
                        "availableAssetNames": customNativeAd.getAvailableAssetNames() ?? []
                    ]
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                        result(String(data: jsonData, encoding: .utf8))
                    } catch {
                        result(FlutterError(code: "1", message: "Failed to convert dictionary to JSON", details: nil))
                    }
                }
                nativeAd.onAdLoadFailed = { error in
                    result(FlutterError(code: "1", message: error, details: nil))
                }
                nativeAd.loadAd()
            }else if(call.method == "nativeMediaClick"){
                let args = call.arguments as? [String: Any]
                if(args != nil){
                    let widgetId = args?["widgetId"] as? String
                    let componentName = args?["componentName"] as? String
                    if(widgetId != nil && componentName != nil){
                        self.ads[widgetId ?? ""]?.click(compname: componentName ?? "")
                        result("")
                    }else if(widgetId != nil){
                        result(FlutterError(code: "MISSING_ARGS", message: "componentName not sent", details: nil))
                    }else{
                        result(FlutterError(code: "MISSING_ARGS", message: "widgetId not sent", details: nil))
                    }
                }else{
                    result(FlutterError(code: "EMPTY_ARGS", message: "Args not sent", details: nil))
                }
            }else if(call.method == "customNativeGetText"){
                let args = call.arguments as? [String: Any]
                let widgetId = args?["widgetId"] as? String
                let assetName = args?["assetName"] as? String
                result(assetName.flatMap { self.ads[widgetId ?? ""]?.customNativeAd()?.getText(for: $0) })
            }else if(call.method == "customNativeGetImageUrl"){
                let args = call.arguments as? [String: Any]
                let widgetId = args?["widgetId"] as? String
                let assetName = args?["assetName"] as? String
                result(assetName.flatMap { (self.ads[widgetId ?? ""]?.customNativeAd() as? AdsFramework.MediationNativeCustomFormatAdGAM)?.getImage(for: $0)?.imageURL?.absoluteString })
            }else if(call.method == "customNativePerformClick"){
                let args = call.arguments as? [String: Any]
                guard let widgetId = args?["widgetId"] as? String,
                      let assetName = args?["assetName"] as? String,
                      let customNativeAd = self.ads[widgetId]?.customNativeAd() else {
                    result(FlutterError(code: "CUSTOM_NATIVE_AD_NOT_LOADED", message: "Custom native ad not loaded", details: nil))
                    return
                }
                customNativeAd.performClick(on: assetName)
                result(nil)
            }else if(call.method == "customNativeRecordImpression"){
                let args = call.arguments as? [String: Any]
                guard let widgetId = args?["widgetId"] as? String,
                      let customNativeAd = self.ads[widgetId]?.customNativeAd() else {
                    result(FlutterError(code: "CUSTOM_NATIVE_AD_NOT_LOADED", message: "Custom native ad not loaded", details: nil))
                    return
                }
                customNativeAd.recordNativeImpression()
                result(nil)
            }else{
                result(FlutterMethodNotImplemented)
            }
            
        }
    }
    
    func getNativeAd(widgetId: String) -> AdsterNativeAd? {
        return ads[widgetId]
    }
}
