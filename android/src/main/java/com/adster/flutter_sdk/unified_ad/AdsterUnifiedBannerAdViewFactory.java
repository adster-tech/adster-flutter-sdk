package com.adster.flutter_sdk.unified_ad;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.adster.flutter_sdk.banner.AdsterBannerAds;

import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class AdsterUnifiedBannerAdViewFactory extends PlatformViewFactory {
    final AdsterUnifiedAdBridge adsterBannerAdBridge;

    public AdsterUnifiedBannerAdViewFactory(AdsterUnifiedAdBridge adsterBannerAdBridge) {
        super(StandardMessageCodec.INSTANCE);
        this.adsterBannerAdBridge = adsterBannerAdBridge;
    }

    @NonNull
    @Override
    public PlatformView create(Context context, int viewId, @Nullable Object args) {
        Log.d(this.getClass().getName(), "create: " + viewId + " Args: " + (args != null ? args.toString() : ""));
        return new AdsterBannerAds(context, adsterBannerAdBridge);
    }
}
