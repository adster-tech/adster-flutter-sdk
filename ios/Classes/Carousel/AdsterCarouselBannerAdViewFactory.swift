import Flutter
import UIKit

class AdsterCarouselBannerAdViewFactory: NSObject, FlutterPlatformViewFactory {
    private let adBridge: AdsterCarouselBannerAdBridge

    init(adBridge: AdsterCarouselBannerAdBridge) {
        self.adBridge = adBridge
        super.init()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        AdsterCarouselBannerAdView(frame: frame, viewIdentifier: viewId, arguments: args, adBridge: adBridge)
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }
}
