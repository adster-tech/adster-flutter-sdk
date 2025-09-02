import Flutter
import SwiftUICore
import UIKit
import AdsFramework

class AdsterBannerAdView: NSObject, FlutterPlatformView {
    
    private var _view: UIView
    private let label = UILabel()
    private var widgetId: String?
    private var controller: UIViewController
    private var adBridge: AdsterBannerAdBridge
    
    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, adBridge: AdsterBannerAdBridge) {
        let view = UIView(frame: frame)
        view.backgroundColor = .lightGray // placeholder
        self._view = view
        
        label.text = "Natively not loaded"
        label.textAlignment = .center
        label.frame = _view.bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.controller = UIApplication.shared.windows.first!.rootViewController!
        self.adBridge = adBridge
        super.init()
        
        if let argsMap = args as? [String: Any] {
            self.widgetId = argsMap["widgetId"] as? String
            if self.widgetId != nil {
                if let bannerAd =  adBridge.getBannerAd(widgetId: widgetId!){
                    bannerAd.bannerView()?.eventDelegate = self
                    self._view = bannerAd.bannerView()?.view ?? label
                }
            }
        }
    }
    
    func view() -> UIView {
        return _view
    }
}

extension AdsterBannerAdView: MediationBannerAdEventDelegate {
    func recordClick() {
        print("Ad clicked")
        adBridge.adClickChannel.invokeMethod(String("onAdClicked"), arguments: ["widgetId":widgetId])
    }
    
    func recordImpression() {
        print("Ad impression recorded")
        adBridge.adClickChannel.invokeMethod(String("onAdImpression"), arguments: ["widgetId":widgetId])
    }
}
