import Flutter
import UIKit
import AdsFramework

class AdsterCarouselBannerAdView: NSObject, FlutterPlatformView {
    private var _view: UIView

    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, adBridge: AdsterCarouselBannerAdBridge) {
        let label = UILabel(frame: frame)
        label.text = "Natively not loaded"
        label.textAlignment = .center
        self._view = label
        super.init()
        if let argsMap = args as? [String: Any],
           let widgetId = argsMap["widgetId"] as? String {
            let index = argsMap["index"] as? Int ?? 0
            if let bannerAd = adBridge.getBannerAd(widgetId: widgetId, index: index) {
                bannerAd.eventCallbacks = adsterEventCallbacks(
                    widgetId: widgetId,
                    channel: adBridge.adClickChannel,
                    clickMethod: "onAdClicked",
                    impressionMethod: "onAdImpression"
                )
                self._view = bannerAd.view ?? label
            }
        }
    }

    func view() -> UIView {
        _view
    }
}
