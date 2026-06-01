import Flutter
import UIKit
import AdsFramework

class AdsterCarouselNativeAdView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private let headline = UIView()
    private let body = UIView()
    private let cta = UIView()
    private let logo = UIView()

    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, adBridge: AdsterCarouselNativeAdBridge) {
        let label = UILabel(frame: frame)
        label.text = "Natively not loaded"
        label.textAlignment = .center
        self._view = label
        super.init()
        if let argsMap = args as? [String: Any],
           let widgetId = argsMap["widgetId"] as? String {
            let index = argsMap["index"] as? Int ?? 0
            if let nativeAd = adBridge.getNativeAd(widgetId: widgetId, index: index) {
                nativeAd.eventCallbacks = adsterEventCallbacks(
                    widgetId: widgetId,
                    channel: adBridge.adClickChannel,
                    clickMethod: "onAdClicked",
                    impressionMethod: "onAdImpression"
                )
                self._view = nativeAd.mediaView ?? label
                cta.frame = _view.bounds
                self._view.addSubview(cta)
                nativeAd.registerAdView(_view, clickableAssetViews: [
                    "mediaView": nativeAd.mediaView,
                    "headline": headline,
                    "body": body,
                    "cta": cta,
                    "logo": logo
                ])
            }
        }
    }

    func view() -> UIView {
        _view
    }
}
