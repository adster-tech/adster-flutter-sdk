import Flutter
import UIKit
import AdsFramework

public class AdsterSDKPlugin: NSObject, FlutterPlugin {
        
    public static func register(with registrar: FlutterPluginRegistrar) {
        
        AdSter.sharedInstance().start(completionHandler: { status in
            print("Ad initialized \(String(describing: status ?? nil))")
        })

        let bannerAdBridge = AdsterBannerAdBridge(messenger: registrar.messenger())

        let bannerAdViewFactory = AdsterBannerAdViewFactory(messenger: registrar.messenger(), adBridge: bannerAdBridge)
        registrar.register(bannerAdViewFactory, withId: "adster_banner")

        let nativeAdBridge = AdsterNativeAdBridge(messenger: registrar.messenger())

        let nativeAdViewFactory = AdsterNativeAdViewFactory(messenger: registrar.messenger(),adBridge: nativeAdBridge)
        registrar.register(nativeAdViewFactory, withId: "adster_native")

        let unifiedAdBridge = AdsterUnifiedAdBridge(messenger: registrar.messenger())

        let unifiedBannerAdFactory = AdsterUnifiedBannerAdViewFactory(messenger: registrar.messenger(), adBridge: unifiedAdBridge)
        registrar.register(unifiedBannerAdFactory, withId: "adster_unified_banner")

        let unifiedNativeAdFactory = AdsterUnifiedNativeAdViewFactory(messenger: registrar.messenger(), adBridge: unifiedAdBridge)
        registrar.register(unifiedNativeAdFactory, withId: "adster_unified_native")

        _ = AdsterInterstitialAdBridge(messenger: registrar.messenger())

        _ = AdsterRewardedAdBridge(messenger: registrar.messenger())

//        let channel = FlutterMethodChannel(name: "flutter_sdk", binaryMessenger: registrar.messenger())
//        let instance = AdsterSDKPlugin()
//        registrar.addMethodCallDelegate(instance, channel: channel)
//        
//        let channel1 = FlutterMethodChannel(name: "native_ios_ad_channel", binaryMessenger: registrar.messenger())
//        channel1.setMethodCallHandler { call, result in
//            if call.method == "loadAd", let args = call.arguments as? [String: Any],
//               let placement = args["placementId"] as? String {
//                print("Received ad load request for placement: \(placement)")
//                // You can interact with the banner view factory here if needed
//                result(nil)
//            } else {
//                result(FlutterMethodNotImplemented)
//            }
//        }
        
    }

}
