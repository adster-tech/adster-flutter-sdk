package com.adster.flutter_sdk.rewarded_ad;

import android.app.Activity;
import android.content.Context;
import android.text.TextUtils;
import android.util.Log;
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

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AdsterRewardedAdBridge implements MethodChannel.MethodCallHandler {

    final private MethodChannel methodChannel;
    final private MethodChannel clickMethodChannel;
    private Activity activity;
    final private Context context;
    private MediationRewardedAd mediationRewardedAd;

    public AdsterRewardedAdBridge(BinaryMessenger messenger, Context context) {
        this.methodChannel = new MethodChannel(messenger, "adster.channel:adster_rewarded_ad");
        this.clickMethodChannel = new MethodChannel(messenger, "adster.channel:adster_rewarded_ad_click");
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
            String widgetId = call.argument("widgetId");
            Log.d("AdsterRewardedAd", "loadRewardedAd: " + adPlacementName + " widgetId: " + widgetId);
            if (adPlacementName != null && widgetId != null) {
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
                }).withRewardedAdEventsListener(new AdsterRewardedEventAdListener(widgetId) {

                    @Override
                    public void onAdClicked(@NonNull String widgetId) {
                        clickMethodChannel.invokeMethod("onAdClicked", getWidgetIdJSON(widgetId));
                    }

                    @Override
                    public void onAdImpression(@NonNull String widgetId) {
                        clickMethodChannel.invokeMethod("onAdImpression", getWidgetIdJSON(widgetId));
                    }

                    @Override
                    public void onUserEarnedReward(@NonNull String widgetId, @NonNull Reward reward) {
                        clickMethodChannel.invokeMethod("onUserEarnedReward", getWidgetIdWithRewardJSON(widgetId, reward.getAmount()));
                    }

                    @Override
                    public void onVideoComplete(@NonNull String widgetId) {
                        clickMethodChannel.invokeMethod("onVideoComplete", getWidgetIdJSON(widgetId));
                    }

                    @Override
                    public void onVideoClosed(@NonNull String widgetId) {
                        clickMethodChannel.invokeMethod("onVideoClosed", getWidgetIdJSON(widgetId));
                    }

                    @Override
                    public void onVideoStart(@NonNull String widgetId) {
                        clickMethodChannel.invokeMethod("onVideoStart", getWidgetIdJSON(widgetId));
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

    Map<String, String> getWidgetIdJSON(String widgetId) {
        Map<String, String> data = new HashMap<>();
        data.put("widgetId", widgetId);
        return data;
    }

    Map<String, Object> getWidgetIdWithRewardJSON(String widgetId, int amount) {
        Map<String, Object> data = new HashMap<>();
        data.put("widgetId", widgetId);
        data.put("amount", String.valueOf(amount));
        return data;
    }

    public void dispose() {
        methodChannel.setMethodCallHandler(null);
    }
}
