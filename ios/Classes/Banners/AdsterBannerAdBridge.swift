import Flutter
import AdsFramework

class AdsterBannerAdBridge: NSObject {
    let adClickChannel: FlutterMethodChannel
    private let adLoadChannel: FlutterMethodChannel
    private var ads: [String: AdsterBannerAd] = [:]

    init(messenger: FlutterBinaryMessenger) {
        adLoadChannel = FlutterMethodChannel(name: "adster.channel:adster_banner", binaryMessenger: messenger)
        adClickChannel = FlutterMethodChannel(name: "adster.channel:adster_banner_ad_click", binaryMessenger: messenger)
        super.init()
        adLoadChannel.setMethodCallHandler { [weak self] call, result in
            guard let self else {
                result(FlutterError(code: "BANNER_DISPOSED", message: "Banner bridge detached", details: nil))
                return
            }
            self.handle(call, result: result)
        }
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]
        switch call.method {
        case "loadBanner":
            guard let widgetId = args?["widgetId"] as? String, !widgetId.isEmpty,
                  let placement = args?["adPlacementName"] as? String, !placement.isEmpty else {
                result(FlutterError(code: "MISSING_ARGS", message: "widgetId and placementId are required", details: nil))
                return
            }
            guard ads[widgetId] == nil else {
                result(FlutterError(code: "BANNER_ALREADY_EXISTS", message: "Banner widget already has an active request", details: nil))
                return
            }
            let banner = makeBanner(widgetId: widgetId, placement: placement, args: args ?? [:])
            ads[widgetId] = banner
            // Register the result before starting a potentially immediate load.
            banner.loadAd { [weak self, weak banner] value in
                if value is FlutterError, let banner {
                    self?.clearWidget(widgetId, expected: banner)
                }
                result(value)
            }
        case "disposeBanner":
            if let widgetId = args?["widgetId"] as? String {
                clearWidget(widgetId)
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func makeBanner(widgetId: String, placement: String, args: [String: Any]) -> AdsterBannerAd {
        AdsterBannerAd(widgetId: widgetId, placementId: placement,
                       adClickChannel: adClickChannel,
                       publisherProvidedId: args["publisherProvidedId"] as? String,
                       customTargetingParams: AdsterTargetingUtils.customTargetingValues(from: args["customTargetArgs"]))
    }

    func getBannerAd(widgetId: String) -> AdsterBannerAd? { ads[widgetId] }

    // Identity checking prevents a retiring platform view from disposing a replacement.
    func clearWidget(_ widgetId: String, expected: AdsterBannerAd? = nil) {
        guard let banner = ads[widgetId], expected == nil || banner === expected else { return }
        ads.removeValue(forKey: widgetId)
        banner.dispose()
    }

    func dispose() {
        adLoadChannel.setMethodCallHandler(nil)
        for widgetId in Array(ads.keys) { clearWidget(widgetId) }
    }
}
