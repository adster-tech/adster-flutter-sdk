import Flutter
import AdsFramework

class AdsterNativeAdView: NSObject, FlutterPlatformView{
    
    private var _view: UIView
    private let label = UILabel()
    
    private var widgetId: String?
    private var controller: UIViewController
    private var adBridge: AdsterNativeAdBridge
    
    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, adBridge: AdsterNativeAdBridge) {
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
                if let nativeAd =  adBridge.getNativeAd(widgetId: widgetId!){
                    print("LandingURL: \(nativeAd.mediaView()?.landingUrl ?? "nil")")
                    //_view.addSubview(nativeAd.mediaView()?.mediaView ?? label)
                    nativeAd.mediaView()?.eventDelegate = self
                    self._view = nativeAd.mediaView()?.mediaView ?? label
                    nativeAd.cta.frame = _view.bounds
                    self._view.addSubview(nativeAd.cta)
                    nativeAd.mediaView()?.registerAdView(_view, clickableAssetViews: ["mediaView":nativeAd.mediaView()?.mediaView, "headline":nativeAd.headline,"body":nativeAd.body,"cta":nativeAd.cta,"logo":nativeAd.logo])
                    nativeAd.setMediaViewByAd(mediaView: _view)
                }
            }
        }
    }
    
    func addMediaViewToParentView(childView: UIView, parentView: UIView) {
        childView.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(childView)
        
        NSLayoutConstraint.activate([
            childView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            childView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            childView.topAnchor.constraint(equalTo: parentView.topAnchor),
            childView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ])
    }
    
    func view() -> UIView {
        return _view
    }
}

extension AdsterNativeAdView: MediationNativeAdEventDelegate {
    func recordNativeClick() {
        print("Ad clicked")
        adBridge.adClickChannel.invokeMethod(String("onAdClicked"), arguments: ["widgetId":widgetId])
    }

    func recordNativeImpression() {
        print("Ad impression recorded")
        adBridge.adClickChannel.invokeMethod(String("onAdImpression"), arguments: ["widgetId":widgetId])
    }
}
