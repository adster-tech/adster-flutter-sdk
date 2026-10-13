import Flutter
import AdsFramework

class AdsterUnifiedNativeAdView: NSObject, FlutterPlatformView{
    
    private var _view: UIView
    private let label = UILabel()
    
    private var widgetId: String?
    private var controller: UIViewController
    private var adBridge: AdsterUnifiedAdBridge
    
    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, adBridge: AdsterUnifiedAdBridge) {
        let view = UIView(frame: frame)
        view.backgroundColor = .lightGray // placeholder
        self._view = view
        self.adBridge = adBridge
        label.text = "Natively not loaded"
        label.textAlignment = .center
        label.frame = _view.bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.controller = UIApplication.shared.windows.first!.rootViewController!
        super.init()
        if let argsMap = args as? [String: Any] {
            self.widgetId = argsMap["widgetId"] as? String
            if self.widgetId != nil {
                if let nativeAd =  adBridge.getUnifiedAd(widgetId: widgetId!){
                    print("LandingURL: \(nativeAd.nativeAd()?.landingUrl ?? "nil")")
                    nativeAd.nativeAd()?.eventDelegate = self
                    if let mediationNativeAd = nativeAd.nativeAd() {
                        self._view = createNativeAdView(nativeAd: mediationNativeAd)
                        nativeAd.setMediaViewByAd(mediaView: self._view)
                    }
                }
            }
        }
    }

    private func createNativeAdView(nativeAd: AdsFramework.MediationNativeAd) -> UIView {
        return AdsterNativeMediaView.make(nativeAd: nativeAd, frame: _view.frame)
    }

    func view() -> UIView {
        return _view
    }
}

extension AdsterUnifiedNativeAdView: MediationNativeAdEventDelegate {
    func recordNativeClick() {
        print("Ad clicked")
        adBridge.adClickChannel.invokeMethod(String("onAdClicked"), arguments: ["widgetId":widgetId])
    }

    func recordNativeImpression() {
        print("Ad impression recorded")
        adBridge.adClickChannel.invokeMethod(String("onAdImpression"), arguments: ["widgetId":widgetId])
    }
}
