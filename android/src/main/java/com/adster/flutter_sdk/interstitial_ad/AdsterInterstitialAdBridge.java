package com.adster.flutter_sdk.interstitial_ad;

import android.app.Activity;
import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import androidx.annotation.NonNull;

import com.adster.sdk.mediation.AdError;
import com.adster.sdk.mediation.AdRequestConfiguration;
import com.adster.sdk.mediation.AdSterAdLoader;
import com.adster.sdk.mediation.InterstitialAdEventsListener;
import com.adster.sdk.mediation.MediationAdListener;
import com.adster.sdk.mediation.MediationInterstitialAd;
import com.adster.sdk.mediation.MediationRewardedAd;
import com.adster.sdk.mediation.Reward;
import com.adster.sdk.mediation.RewardedAdEventsListener;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AdsterInterstitialAdBridge implements MethodChannel.MethodCallHandler {

    final private MethodChannel methodChannel;
    private Activity activity;
    final private Context context;
    private MediationInterstitialAd mediationInterstitialAd;
    final private MethodChannel clickMethodChannel;

    public AdsterInterstitialAdBridge(BinaryMessenger messenger, Context context) {
        this.methodChannel = new MethodChannel(messenger, "adster.channel:adster_interstitial_ad");
        this.clickMethodChannel = new MethodChannel(messenger, "adster.channel:adster_interstitial_ad_click");
        this.methodChannel.setMethodCallHandler(this);
        this.context = context;
    }

    public void setActivity(Activity activity) {
        this.activity = activity;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("loadInterstitialAd")) {
            String adPlacementName = call.argument("adPlacementName");
            String widgetId = call.argument("widgetId");
            Log.d("AdsterInterstitialAd", "loadInterstitialAd: " + adPlacementName + " widgetId: " + widgetId);
            if (adPlacementName != null && widgetId != null) {
                AdRequestConfiguration configuration = AdRequestConfiguration.Companion.builder(context, adPlacementName).build();

                AdSterAdLoader.Companion.builder().withAdsListener(new MediationAdListener() {
                    @Override
                    public void onInterstitialAdLoaded(@NonNull MediationInterstitialAd ad) {
                        super.onInterstitialAdLoaded(ad);
                        mediationInterstitialAd = ad;
                        result.success("");
                    }

                    @Override
                    public void onFailure(@NonNull AdError adError) {
                        result.error(String.valueOf(adError.getErrorCode()), adError.getErrorMessage(), null);
                    }
                }).withInterstitialAdEventsListener(new AdsterInterstitialEventAdListener(widgetId) {
                    @Override
                    public void onAdClicked(@NonNull String widgetId) {
                        clickMethodChannel.invokeMethod("onAdClicked", getWidgetIdJSON(widgetId));
                    }

                    @Override
                    public void onAdImpression(@NonNull String widgetId) {
                        clickMethodChannel.invokeMethod("onAdImpression", getWidgetIdJSON(widgetId));
                    }

                    @Override
                    public void onAdOpened(@NonNull String widgetId) {
                        clickMethodChannel.invokeMethod("onAdOpened", getWidgetIdJSON(widgetId));
                    }

                    @Override
                    public void onAdClosed(@NonNull String widgetId) {
                        clickMethodChannel.invokeMethod("onAdClosed", getWidgetIdJSON(widgetId));
                    }

                    @Override
                    public void onAdRevenuePaid(double v, @NonNull String s, @NonNull String s1, @NonNull String widgetId) {
                        Map<String, Object> data = new HashMap<>();
                        data.put("revenue", v);
                        data.put("adUnitId", s);
                        data.put("network", s1);
                        data.put("widgetId", widgetId);
                        clickMethodChannel.invokeMethod("onAdRevenuePaid", data);
                    }
                }).build().loadAd(configuration);
            } else {
                result.error("EMP_PLACEMENT_ID", "Placement id were not supplied", null);
            }
        } else if (call.method.equals("showAd")) {
            if (mediationInterstitialAd != null && activity != null) {
                mediationInterstitialAd.showAd(activity);
                result.success("");
            } else {
                result.error("REWARDED_AD_NOT_LOADED", "Rewarded ad not loaded: mediationInterstitialAd=" + mediationInterstitialAd + " activity:" + activity, null);
            }
        } else {
            result.notImplemented();
        }
    }

    Map<String, String> getWidgetIdJSON(String widgetId) {
        Map<String, String> data = new HashMap<>();
        data.put("widgetId", widgetId);
        return data;
    }

    public void dispose() {
        methodChannel.setMethodCallHandler(null);
    }
}
