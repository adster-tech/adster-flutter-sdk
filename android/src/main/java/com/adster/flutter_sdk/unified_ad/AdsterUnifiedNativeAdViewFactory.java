package com.adster.flutter_sdk.unified_ad;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.adster.flutter_sdk.native_ad.AdsterNativeAdBridge;
import com.adster.flutter_sdk.native_ad.AdsterNativeAds;

import java.util.Map;

import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class AdsterUnifiedNativeAdViewFactory extends PlatformViewFactory {
    private final AdsterUnifiedAdBridge adsterNativeAdBridge;

    public AdsterUnifiedNativeAdViewFactory(AdsterUnifiedAdBridge adsterNativeAdBridge) {
        super(StandardMessageCodec.INSTANCE);
        this.adsterNativeAdBridge = adsterNativeAdBridge;
    }

    @NonNull
    @Override
    public PlatformView create(Context context, int viewId, @Nullable Object args) {
        Log.d(this.getClass().getName(), "create: " + viewId + " Args: " + (args != null ? args.toString() : ""));
        String widgetId = "";
        if (args instanceof Map) {
            Map<String, Object> creationParams = (Map<String, Object>) args;
            widgetId = String.valueOf(creationParams.get("widgetId"));
        }
        return new AdsterNativeAds(context, widgetId, adsterNativeAdBridge);
    }
}
