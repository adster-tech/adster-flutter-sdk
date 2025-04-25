package com.adster.flutter_sdk.native_ad;

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
import com.adster.sdk.mediation.MediationNativeAdView;

import org.json.JSONException;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AdsterNativeAdBridge implements MethodChannel.MethodCallHandler {

    final private MethodChannel methodChannel;
    final private Context context;
    private View mediaView = null;
    final private MethodChannel clickMethodChannel;
    private MediationNativeAd nativeAd;
    private MediationNativeAdView mediationNativeAdView;

    public AdsterNativeAdBridge(BinaryMessenger messenger, Context context) {
        this.methodChannel = new MethodChannel(messenger, "adster.channel:adster_native_ad");
        this.clickMethodChannel = new MethodChannel(messenger, "adster.channel:adster_native_ad_click");
        this.methodChannel.setMethodCallHandler(this);
        this.context = context;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("loadBanner")) {
            String adPlacementName = call.argument("adPlacementName");
            if (!TextUtils.isEmpty(adPlacementName)) {
                AdRequestConfiguration configuration = AdRequestConfiguration.Companion.builder(context, adPlacementName).build();
                AdSterAdLoader.Companion.builder().withAdsListener(new MediationAdListener() {
                    @Override
                    public void onNativeAdLoaded(@NonNull MediationNativeAd ad) {
                        super.onNativeAdLoaded(ad);
                        nativeAd = ad;
                        mediaView = ad.getMediaView();
                        try {
                            String data = new AdsterJSONDataMapper().toJSONStr(ad);
                            result.success(data);
                            clickMethodChannel.invokeMethod("onNativeAdLoaded", null);
                        } catch (JSONException e) {
                            result.error("DATA_PARSE_ERROR", e.getMessage(), null);
                        }
                    }

                    @Override
                    public void onFailure(@NonNull AdError adError) {
                        //Handle failure callback here
                        result.error(String.valueOf(adError.getErrorCode()), adError.getErrorMessage(), null);
                        clickMethodChannel.invokeMethod("onFailure", adError.getErrorMessage());
                    }
                }).withAdsEventsListener(new AdEventsListener() {
                    @Override
                    public void onAdClicked() {
                        clickMethodChannel.invokeMethod("onAdClicked", null);
                    }

                    @Override
                    public void onAdImpression() {
                        clickMethodChannel.invokeMethod("onAdImpression", null);
                    }
                }).build().loadAd(configuration);
            } else {
                result.error("EMP_PLACEMENT_ID", "Placement id were not supplied", null);
            }
        } else if (call.method.equals("nativeMediaClick")) {
            if (mediationNativeAdView != null) {
                if (call.arguments.equals("body")) {
                    mediationNativeAdView.onClick(mediationNativeAdView.getBodyView());
                } else if (call.arguments.equals("callToAction")) {
                    mediationNativeAdView.performClick();
                } else if (call.arguments.equals("headline")) {
                    mediationNativeAdView.onClick(mediationNativeAdView.getHeadlineView());
                } else if (call.arguments.equals("logo")) {
                    mediationNativeAdView.onClick(mediationNativeAdView.getLogoView());
                } else if (call.arguments.equals("ratingBar")) {
                    mediationNativeAdView.onClick(mediationNativeAdView.getRatingBarView());
                }
                result.success("");
            } else {
                result.error("NATIVE_AD_NOT_LOADED", "Native ad not loaded", null);
            }
        } else {
            result.notImplemented();
        }
    }

    View getMediaView() {
        return mediaView;
    }

    public void dispose() {
        methodChannel.setMethodCallHandler(null);
    }

    public MediationNativeAd getNativeAd() {
        return nativeAd;
    }

    public void setMediationNativeAdView(MediationNativeAdView mediationNativeAdView) {
        this.mediationNativeAdView = mediationNativeAdView;
    }
}
