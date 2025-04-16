package com.adester.adster_poc;

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

public class AdsterBannerAds implements PlatformView, MethodChannel.MethodCallHandler {
    final Context context;
    final FrameLayout container;

    public AdsterBannerAds(Context context, BinaryMessenger messenger) {
        this.context = context;
        container = new FrameLayout(context);
        MethodChannel channel = new MethodChannel(messenger, "adster_banner");
        channel.setMethodCallHandler(this);
    }

    @Nullable
    @Override
    public View getView() {
        Log.d("AdsterBannerAds", "getView");
        container.setLayoutParams(new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.WRAP_CONTENT));
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

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Log.d("AdsterBannerAds", "onMethodCall: " + call.method);
        if (call.method.equals("loadBanner")) {
            String placementId = call.argument("adPlacementName");
            Log.d("AdsterBannerAds", "loadBanner: " + placementId);
            if (placementId != null) {
                AdRequestConfiguration configuration = AdRequestConfiguration.Companion.builder(context, placementId).build();
                AdSterAdLoader.Companion.builder().withAdsListener(new MediationAdListener() {
                    @Override
                    public void onBannerAdLoaded(@NonNull MediationBannerAd ad) {
                        super.onBannerAdLoaded(ad);
                        container.addView(ad.getView());
                        result.success("true");
                    }

                    @Override
                    public void onFailure(@NonNull AdError adError) {
                        // Handle failure here
                        result.error(String.valueOf(adError.getErrorCode()), adError.getErrorMessage(), null);
                        container.setBackgroundColor(context.getResources().getColor(android.R.color.holo_blue_bright));
                        TextView textView = new TextView(context);
                        textView.setText(adError.getErrorMessage());
                        container.setLayoutParams(new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, 100));
                        container.addView(textView);
                    }
                }).withAdsEventsListener(new AdEventsListener() {
                    @Override
                    public void onAdClicked() {
                        //Handle ad click here
                    }

                    @Override
                    public void onAdImpression() {
                        //Handle ad impression here
                    }
                }).build().loadAd(configuration);
            } else {
                result.error("EMP_PLACEMENT_ID", "Placement id were not supplied", null);
            }
        }
    }
}
