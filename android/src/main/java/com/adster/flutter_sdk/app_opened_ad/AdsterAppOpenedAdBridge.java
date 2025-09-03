package com.adster.flutter_sdk.app_opened_ad;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.adster.sdk.mediation.AdError;
import com.adster.sdk.mediation.AdRequestConfiguration;
import com.adster.sdk.mediation.AdSterAdLoader;
import com.adster.sdk.mediation.MediationAdListener;
import com.adster.sdk.mediation.MediationAppOpenAd;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AdsterAppOpenedAdBridge implements MethodChannel.MethodCallHandler {

    final private MethodChannel methodChannel;
    final private MethodChannel clickMethodChannel;
    private Activity activity;
    final private Context context;

    public AdsterAppOpenedAdBridge(BinaryMessenger messenger, Context context) {
        this.methodChannel = new MethodChannel(messenger, "adster.channel:adster_app_opened_ad");
        this.clickMethodChannel = new MethodChannel(messenger, "adster.channel:adster_app_opened_ad_click");
        this.methodChannel.setMethodCallHandler(this);
        this.context = context;
    }

    public void setActivity(Activity activity) {
        this.activity = activity;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("loadAppOpenedAd")) {
            String adPlacementName = call.argument("adPlacementName");
            String widgetId = call.argument("widgetId");
            Log.d("AdsterAppOpenedAd", "loadAppOpenedAd: " + adPlacementName + " widgetId: " + widgetId);
            if (adPlacementName != null && widgetId != null) {
                AdRequestConfiguration configuration = AdRequestConfiguration.Companion.builder(context, adPlacementName).build();
                AdSterAdLoader.Companion.builder().withAdsListener(new MediationAdListener() {

                    @Override
                    public void onAppOpenAdLoaded(@NonNull MediationAppOpenAd ad) {
                        super.onAppOpenAdLoaded(ad);
                        if (activity != null) {
                            ad.showAd(activity);
                            result.success("");
                        } else {
                            result.error("ACTIVITY_NOT_FOUND", "Activity not found", null);
                        }
                    }

                    @Override
                    public void onFailure(@NonNull AdError adError) {
                        //Handle failure callback here
                        result.error(String.valueOf(adError.getErrorCode()), adError.getErrorMessage(), null);
                    }
                }).withAppOpenAdEventsListener(new AdsterAppOpenedEventAdListener(widgetId) {

                    @Override
                    public void onAdRevenuePaid(double revenue, @NonNull String adUnitId, @NonNull String network, @NonNull String widgetId) {
                        Map<String, Object> data = new HashMap<>();
                        data.put("revenue", revenue);
                        data.put("adUnitId", adUnitId);
                        data.put("network", network);
                        data.put("widgetId", widgetId);
                        clickMethodChannel.invokeMethod("onAdRevenuePaid", data);
                    }

                    @Override
                    public void onAdClicked(@NonNull String widgetId) {
                        clickMethodChannel.invokeMethod("onAdClicked", getResponseJson(widgetId));
                    }

                    @Override
                    public void onAdImpression(@NonNull String widgetId) {
                        clickMethodChannel.invokeMethod("onAdImpression", getResponseJson(widgetId));
                    }

                    @Override
                    public void onAdOpened(@NonNull String widgetId) {
                        clickMethodChannel.invokeMethod("onAdOpened", getResponseJson(widgetId));
                    }

                    @Override
                    public void onAdClosed(@NonNull String widgetId) {
                        clickMethodChannel.invokeMethod("onAdClosed", getResponseJson(widgetId));
                    }

                    @Override
                    public void onFailure(@Nullable AdError adError, @NonNull String widgetId) {
                        Map<String, String> widgetIdJSON = getResponseJson(widgetId);
                        Map<String, Object> errorData = new HashMap<>(widgetIdJSON);
                        if (adError != null) {
                            errorData.put("errorCode", adError.getErrorCode());
                            errorData.put("errorMessage", adError.getErrorMessage());
                        }
                        clickMethodChannel.invokeMethod("onFailure", errorData);
                    }

                }).build().loadAd(configuration);
            } else {
                result.error("EMP_PLACEMENT_ID", "Placement id were not supplied", null);
            }
        } else {
            result.notImplemented();
        }
    }

    Map<String, String> getResponseJson(String widgetId) {
        Map<String, String> data = new HashMap<>();
        data.put("widgetId", widgetId);
        return data;
    }

    public void dispose() {
        methodChannel.setMethodCallHandler(null);
    }
}
