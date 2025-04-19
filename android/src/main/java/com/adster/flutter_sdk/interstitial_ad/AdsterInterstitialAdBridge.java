package com.adster.flutter_sdk.interstitial_ad;

import android.app.Activity;
import android.content.Context;
import android.text.TextUtils;

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

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AdsterInterstitialAdBridge implements MethodChannel.MethodCallHandler {

    final private MethodChannel methodChannel;
    private Activity activity;
    final private Context context;
    private MediationInterstitialAd mediationInterstitialAd;

    public AdsterInterstitialAdBridge(BinaryMessenger messenger, Context context) {
        this.methodChannel = new MethodChannel(messenger, "adster.channel:adster_interstitial_ad");
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
            if (!TextUtils.isEmpty(adPlacementName)) {
                AdRequestConfiguration configuration = AdRequestConfiguration.Companion.builder(context, adPlacementName).build();

                AdSterAdLoader.Companion.builder().withAdsListener(new MediationAdListener() {
                    @Override
                    public void onInterstitialAdLoaded(@NonNull MediationInterstitialAd ad) {
                        super.onInterstitialAdLoaded(ad);
                        mediationInterstitialAd = ad;
                        result.success("");
                        //Show interstitial ad here
                    }

                    @Override
                    public void onFailure(@NonNull AdError adError) {
                        result.error(String.valueOf(adError.getErrorCode()), adError.getErrorMessage(), null);
                    }
                }).withInterstitialAdEventsListener(new InterstitialAdEventsListener() {
                    @Override
                    public void onAdClicked() {
                        //Handle ad click here
                    }

                    @Override
                    public void onAdImpression() {
                        //Handle ad impression here
                    }

                    @Override
                    public void onAdOpened() {
                        //Handle ad open here
                    }

                    @Override
                    public void onAdClosed() {
                        //Handle ad closed here
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

    public void dispose() {
        methodChannel.setMethodCallHandler(null);
    }
}
