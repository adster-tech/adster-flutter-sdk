import Flutter
import UIKit

class AdsterNativeAdViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger
    private var adBridge: AdsterNativeAdBridge

    init(messenger: FlutterBinaryMessenger, adBridge: AdsterNativeAdBridge) {
        self.messenger = messenger
        self.adBridge = adBridge
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return AdsterNativeAdView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            adBridge: self.adBridge
        )
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
