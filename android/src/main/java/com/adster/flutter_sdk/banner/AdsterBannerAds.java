package com.adster.flutter_sdk.banner;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.adster.sdk.mediation.AdError;
import com.adster.sdk.mediation.AdEventsListener;
import com.adster.sdk.mediation.AdRequestConfiguration;
import com.adster.sdk.mediation.AdSterAdLoader;
import com.adster.sdk.mediation.MediationAdListener;
import com.adster.sdk.mediation.MediationBannerAd;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class AdsterBannerAds implements PlatformView {
    final Context context;
    final FrameLayout container;

    public AdsterBannerAds(Context context, AdsterBannerAdBridge adsterBannerAdBridge) {
        this.context = context;
        container = new FrameLayout(context);
        container.addView(adsterBannerAdBridge.getMediaView());
    }

    @Nullable
    @Override
    public View getView() {
        Log.d("AdsterBannerAds", "getView");
        return container;
    }

    @Override
    public void dispose() {
        Log.d("AdsterBannerAds", "dispose");
        //channel.setMethodCallHandler(null);
    }
}
