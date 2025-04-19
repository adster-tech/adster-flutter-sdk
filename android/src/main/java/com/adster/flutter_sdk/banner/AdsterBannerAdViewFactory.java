package com.adster.flutter_sdk.banner;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class AdsterBannerAdViewFactory extends PlatformViewFactory {
    final AdsterBannerAdBridge adsterBannerAdBridge;

    public AdsterBannerAdViewFactory(AdsterBannerAdBridge adsterBannerAdBridge) {
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
