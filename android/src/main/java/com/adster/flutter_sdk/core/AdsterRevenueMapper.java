package com.adster.flutter_sdk.core;

import androidx.annotation.NonNull;

import com.adster.sdk.mediation.PrecisionType;

import java.util.HashMap;
import java.util.Map;

public final class AdsterRevenueMapper {
    private AdsterRevenueMapper() {
    }

    public static Map<String, Object> toMap(
            double revenue,
            @NonNull String adUnitId,
            @NonNull String network,
            @NonNull String currency,
            @NonNull PrecisionType precisionType,
            @NonNull String widgetId
    ) {
        Map<String, Object> data = new HashMap<>();
        data.put("revenue", revenue);
        data.put("adUnitId", adUnitId);
        data.put("network", network);
        data.put("currency", currency);
        data.put("precisionType", precisionType.name());
        data.put("widgetId", widgetId);
        return data;
    }
}
