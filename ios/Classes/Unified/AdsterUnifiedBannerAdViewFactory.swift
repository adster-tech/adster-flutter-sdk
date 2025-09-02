import Flutter
import UIKit

class AdsterUnifiedBannerAdViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private var adBridge: AdsterUnifiedAdBridge
    
    init(messenger: FlutterBinaryMessenger, adBridge: AdsterUnifiedAdBridge) {
        self.messenger = messenger
        self.adBridge = adBridge
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return AdsterUnifiedBannerAdView(
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
