import Flutter
import UIKit
import AdsFramework

class AdsterBannerAdView: NSObject, FlutterPlatformView {
    private var nativeView: UIView
    private var widgetId: String?
    private weak var adBridge: AdsterBannerAdBridge?
    private weak var banner: AdsterBannerAd?

    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, adBridge: AdsterBannerAdBridge) {
        nativeView = UIView(frame: frame)
        self.adBridge = adBridge
        super.init()
        guard let args = args as? [String: Any], let id = args["widgetId"] as? String,
              let banner = adBridge.getBannerAd(widgetId: id), !banner.isDisposed,
              let view = banner.bannerView()?.view, view.superview == nil else { return }
        widgetId = id
        self.banner = banner
        nativeView = view
    }

    func view() -> UIView { nativeView }

    deinit {
        if let widgetId, let banner {
            adBridge?.clearWidget(widgetId, expected: banner)
        }
    }
}
