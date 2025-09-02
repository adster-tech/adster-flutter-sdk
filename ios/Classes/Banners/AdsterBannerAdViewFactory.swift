import Flutter
import UIKit

class AdsterBannerAdViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private var adBridge: AdsterBannerAdBridge
    
    init(messenger: FlutterBinaryMessenger, adBridge: AdsterBannerAdBridge) {
        self.messenger = messenger
        self.adBridge = adBridge
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return AdsterBannerAdView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            adBridge: adBridge
        )
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
