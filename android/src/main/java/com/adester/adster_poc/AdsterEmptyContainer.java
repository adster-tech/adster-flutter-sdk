package com.adester.adster_poc;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.adster.sdk.mediation.AdError;
import com.adster.sdk.mediation.AdEventsListener;
import com.adster.sdk.mediation.AdRequestConfiguration;
import com.adster.sdk.mediation.AdSterAdLoader;
import com.adster.sdk.mediation.MediationAdListener;
import com.adster.sdk.mediation.MediationBannerAd;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

public class AdsterEmptyContainer implements PlatformView {
    Context context;
    FrameLayout container;

    public AdsterEmptyContainer(Context context) {
        this.context = context;
        container = new FrameLayout(context);
    }

    @Nullable
    @Override
    public View getView() {
        Log.d("AdsterBannerAds", "getView");
        return container;
    }

    @Override
    public void onFlutterViewAttached(@NonNull View flutterView) {
        Log.d("AdsterBannerAds", "onFlutterViewAttached");
        PlatformView.super.onFlutterViewAttached(flutterView);
    }

    @Override
    public void onFlutterViewDetached() {
        Log.d("AdsterBannerAds", "onFlutterViewDetached");
        PlatformView.super.onFlutterViewDetached();
    }

    @Override
    public void dispose() {
        Log.d("AdsterBannerAds", "dispose");
    }

    @Override
    public void onInputConnectionLocked() {
        PlatformView.super.onInputConnectionLocked();
        Log.d("AdsterBannerAds", "onInputConnectionLocked");
    }

    @Override
    public void onInputConnectionUnlocked() {
        PlatformView.super.onInputConnectionUnlocked();
        Log.d("AdsterBannerAds", "onInputConnectionUnlocked");
    }
}
