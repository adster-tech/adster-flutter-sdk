package com.adster.flutter_sdk.carousel;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.adster.flutter_sdk.native_ad.AdsterNativeAds;

import java.util.Map;

import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class AdsterCarouselNativeAdViewFactory extends PlatformViewFactory {
    private final AdsterCarouselNativeAdBridge bridge;

    public AdsterCarouselNativeAdViewFactory(AdsterCarouselNativeAdBridge bridge) {
        super(StandardMessageCodec.INSTANCE);
        this.bridge = bridge;
    }

    @NonNull
    @Override
    public PlatformView create(Context context, int viewId, @Nullable Object args) {
        String widgetId = "";
        int index = 0;
        if (args instanceof Map) {
            Map<String, Object> creationParams = (Map<String, Object>) args;
            widgetId = String.valueOf(creationParams.get("widgetId"));
            Object indexValue = creationParams.get("index");
            if (indexValue instanceof Number) {
                index = ((Number) indexValue).intValue();
            }
        }
        return new AdsterNativeAds(context, widgetId + ":" + index, bridge);
    }
}
