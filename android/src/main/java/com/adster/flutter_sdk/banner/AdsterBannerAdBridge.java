package com.adster.flutter_sdk.banner;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.adster.flutter_sdk.core.AdsterJSONDataMapper;
import com.adster.sdk.mediation.AdError;
import com.adster.sdk.mediation.AdEventsListener;
import com.adster.sdk.mediation.AdRequestConfiguration;
import com.adster.sdk.mediation.AdSterAdLoader;
import com.adster.sdk.mediation.MediationAdListener;
import com.adster.sdk.mediation.MediationBannerAd;
import com.adster.sdk.mediation.MediationNativeAd;

import org.json.JSONException;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AdsterBannerAdBridge implements MethodChannel.MethodCallHandler {

    final private MethodChannel methodChannel;
    final private Context context;
    private View mediaView = null;

    public AdsterBannerAdBridge(BinaryMessenger messenger, Context context) {
        methodChannel = new MethodChannel(messenger, "adster.channel:adster_banner");
        methodChannel.setMethodCallHandler(this);
        this.context = context;
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
                        mediaView = ad.getView();
                        result.success("true");

                    }

                    @Override
                    public void onFailure(@NonNull AdError adError) {
                        result.error(String.valueOf(adError.getErrorCode()), adError.getErrorMessage(), null);
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

    View getMediaView() {
        return mediaView;
    }

    public void dispose() {
        methodChannel.setMethodCallHandler(null);
    }
}
