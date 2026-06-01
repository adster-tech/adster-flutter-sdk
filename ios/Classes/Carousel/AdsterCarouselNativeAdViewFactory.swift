import Flutter
import UIKit

class AdsterCarouselNativeAdViewFactory: NSObject, FlutterPlatformViewFactory {
    private let adBridge: AdsterCarouselNativeAdBridge

    init(adBridge: AdsterCarouselNativeAdBridge) {
        self.adBridge = adBridge
        super.init()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        AdsterCarouselNativeAdView(frame: frame, viewIdentifier: viewId, arguments: args, adBridge: adBridge)
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }
}
