import Flutter
import AdsFramework

func adsterRevenueArguments(
    widgetId: String,
    revenue: Double,
    adUnitId: String,
    network: String,
    currency: String,
    precisionType: PrecisionType
) -> [String: Any] {
    [
        "widgetId": widgetId,
        "revenue": revenue,
        "adUnitId": adUnitId,
        "network": network,
        "currency": currency,
        "precisionType": adsterPrecisionTypeName(precisionType)
    ]
}

func adsterPrecisionTypeName(_ precisionType: PrecisionType) -> String {
    switch precisionType {
    case .estimated:
        return "ESTIMATED"
    case .publisherProvided:
        return "PUBLISHER_PROVIDED"
    case .precise:
        return "PRECISE"
    default:
        return "UNKNOWN"
    }
}

func adsterEventCallbacks(
    widgetId: String,
    channel: FlutterMethodChannel,
    clickMethod: String,
    impressionMethod: String,
    customNativeClickMethod: String? = nil
) -> MediationAdEventCallbacks {
    MediationAdEventCallbacks(
        onClick: {
            channel.invokeMethod(clickMethod, arguments: ["widgetId": widgetId])
        },
        onImpression: {
            channel.invokeMethod(impressionMethod, arguments: ["widgetId": widgetId])
        },
        onRevenuePaid: { revenue, adUnitId, network, currency, precisionType in
            channel.invokeMethod(
                "onAdRevenuePaid",
                arguments: adsterRevenueArguments(
                    widgetId: widgetId,
                    revenue: revenue,
                    adUnitId: adUnitId,
                    network: network,
                    currency: currency,
                    precisionType: precisionType
                )
            )
        },
        onCustomNativeClick: { assetName in
            guard let method = customNativeClickMethod else { return }
            channel.invokeMethod(method, arguments: [
                "widgetId": widgetId,
                "assetName": assetName
            ])
        }
    )
}

func adsterRevenueOnlyCallbacks(
    widgetId: String,
    channel: FlutterMethodChannel
) -> MediationAdEventCallbacks {
    MediationAdEventCallbacks(
        onRevenuePaid: { revenue, adUnitId, network, currency, precisionType in
            channel.invokeMethod(
                "onAdRevenuePaid",
                arguments: adsterRevenueArguments(
                    widgetId: widgetId,
                    revenue: revenue,
                    adUnitId: adUnitId,
                    network: network,
                    currency: currency,
                    precisionType: precisionType
                )
            )
        }
    )
}
