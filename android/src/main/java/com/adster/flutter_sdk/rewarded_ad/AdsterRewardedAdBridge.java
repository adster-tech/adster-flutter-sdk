package com.adster.flutter_sdk.rewarded_ad;

import android.app.Activity;
import android.content.Context;
import android.text.TextUtils;
import android.view.View;

import androidx.annotation.NonNull;

import com.adster.flutter_sdk.core.AdsterJSONDataMapper;
import com.adster.sdk.mediation.AdError;
import com.adster.sdk.mediation.AdEventsListener;
import com.adster.sdk.mediation.AdRequestConfiguration;
import com.adster.sdk.mediation.AdSterAdLoader;
import com.adster.sdk.mediation.MediationAdListener;
import com.adster.sdk.mediation.MediationNativeAd;
import com.adster.sdk.mediation.MediationRewardedAd;
import com.adster.sdk.mediation.Reward;
import com.adster.sdk.mediation.RewardedAdEventsListener;

import org.json.JSONException;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AdsterRewardedAdBridge implements MethodChannel.MethodCallHandler {

    final private MethodChannel methodChannel;
    private Activity activity;
    final private Context context;
    private MediationRewardedAd mediationRewardedAd;

    public AdsterRewardedAdBridge(BinaryMessenger messenger, Context context) {
        this.methodChannel = new MethodChannel(messenger, "adster.channel:adster_rewarded_ad");
        this.methodChannel.setMethodCallHandler(this);
        this.context = context;
    }

    public void setActivity(Activity activity) {
        this.activity = activity;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("loadRewardedAd")) {
            String adPlacementName = call.argument("adPlacementName");
            if (!TextUtils.isEmpty(adPlacementName)) {
                AdRequestConfiguration configuration = AdRequestConfiguration.Companion.builder(context, adPlacementName).build();
                AdSterAdLoader.Companion.builder().withAdsListener(new MediationAdListener() {
                    @Override
                    public void onRewardedAdLoaded(@NonNull MediationRewardedAd ad) {
                        super.onRewardedAdLoaded(ad);
                        mediationRewardedAd = ad;
                        result.success("");
                    }

                    @Override
                    public void onFailure(@NonNull AdError adError) {
                        //Handle failure callback here
                        result.error(String.valueOf(adError.getErrorCode()), adError.getErrorMessage(), null);
                    }
                }).withRewardedAdEventsListener(new RewardedAdEventsListener() {
                    @Override
                    public void onAdClicked() {
                        //Handle ad click here
                    }

                    @Override
                    public void onAdImpression() {
                        //Handle ad click here
                    }

                    @Override
                    public void onUserEarnedReward(@NonNull Reward reward) {
                        //Handle ad click here
                    }

                    @Override
                    public void onVideoComplete() {
                        //Handle ad click here
                    }

                    @Override
                    public void onVideoClosed() {
                        //Handle ad click here
                    }

                    @Override
                    public void onVideoStart() {
                        //Handle ad click here
                    }
                }).build().loadAd(configuration);
            } else {
                result.error("EMP_PLACEMENT_ID", "Placement id were not supplied", null);
            }
        } else if (call.method.equals("showAd")) {
            if (mediationRewardedAd != null && activity != null) {
                mediationRewardedAd.showAd(activity);
                result.success("");
            } else {
                result.error("REWARDED_AD_NOT_LOADED", "Rewarded ad not loaded: mediationRewardedAd=" + mediationRewardedAd + " activity:" + activity, null);
            }
        } else {
            result.notImplemented();
        }
    }

    public void dispose() {
        methodChannel.setMethodCallHandler(null);
    }
}
