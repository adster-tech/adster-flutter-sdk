package com.adster.flutter_sdk.banner;

import android.content.Context;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;

import com.adster.flutter_sdk.core.AdsterBaseAdBridge;
import com.adster.sdk.mediation.AdError;
import com.adster.sdk.mediation.AdRequestConfiguration;
import com.adster.sdk.mediation.AdSterAdLoader;
import com.adster.sdk.mediation.MediationAdListener;
import com.adster.sdk.mediation.MediationBannerAd;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AdsterBannerAdBridge extends AdsterBaseAdBridge {

    final private MethodChannel methodChannel;
    final private MethodChannel clickMethodChannel;
    final private Context context;
    private View mediaView = null;

    public AdsterBannerAdBridge(BinaryMessenger messenger, Context context) {
        methodChannel = new MethodChannel(messenger, "adster.channel:adster_banner");
        clickMethodChannel = new MethodChannel(messenger, "adster.channel:adster_banner_ad_click");
        methodChannel.setMethodCallHandler(this);
        this.context = context;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Log.d("AdsterBannerAds", "onMethodCall: " + call.method);
        if (call.method.equals("loadBanner")) {
            String placementId = call.argument("adPlacementName");
            String widgetId = call.argument("widgetId");
            Log.d("AdsterBannerAds", "loadBanner: " + placementId + " widgetId: " + widgetId);
            if (placementId != null && widgetId != null) {
                AdRequestConfiguration configuration = AdRequestConfiguration.Companion.builder(context, placementId).build();
                AdSterAdLoader.Companion.builder().withAdsListener(new MediationAdListener() {
                    @Override
                    public void onBannerAdLoaded(@NonNull MediationBannerAd ad) {
                        super.onBannerAdLoaded(ad);
                        mediaView = ad.getView();
                        result.success("true");
                    }

                    @Override
                    public void onFailure(@NonNull AdError adError) {
                        result.error(String.valueOf(adError.getErrorCode()), adError.getErrorMessage(), null);
                    }
                }).withAdsEventsListener(new AdsterBannerEventAdListener(widgetId) {
                    @Override
                    public void onAdClicked(@NonNull String widgetId) {
                        clickMethodChannel.invokeMethod("onAdClicked", getWidgetIdJSON(widgetId));
                    }

                    @Override
                    public void onAdImpression(@NonNull String widgetId) {
                        clickMethodChannel.invokeMethod("onAdImpression", getWidgetIdJSON(widgetId));
                    }
                }).build().loadAd(configuration);
            } else {
                result.error("EMP_PLACEMENT_ID", "Placement id were not supplied", null);
            }
        }
    }

    Map<String, String> getWidgetIdJSON(String widgetId) {
        Map<String, String> data = new HashMap<>();
        data.put("widgetId", widgetId);
        return data;
    }

    @Override
    public View getMediaView() {
        return mediaView;
    }

    public void dispose() {
        methodChannel.setMethodCallHandler(null);
    }
}
