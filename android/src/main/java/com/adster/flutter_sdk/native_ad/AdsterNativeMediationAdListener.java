package com.adster.flutter_sdk.native_ad;

import androidx.annotation.NonNull;

import com.adster.flutter_sdk.core.AdsterJSONDataMapper;
import com.adster.sdk.mediation.AdError;
import com.adster.sdk.mediation.AdEventsListener;
import com.adster.sdk.mediation.MediationAdListener;
import com.adster.sdk.mediation.MediationNativeAd;

import org.json.JSONException;

abstract public class AdsterNativeMediationAdListener extends MediationAdListener {
    final String widgetId;

    public AdsterNativeMediationAdListener(String widgetId) {
        this.widgetId = widgetId;
    }

    @Override
    public void onNativeAdLoaded(@NonNull MediationNativeAd ad) {
        super.onNativeAdLoaded(ad);
        onNativeAdLoaded(ad,widgetId);
    }

    @Override
    public void onFailure(@NonNull AdError adError) {
        onFailure(adError,widgetId);
    }

    abstract public void onNativeAdLoaded(@NonNull MediationNativeAd ad, @NonNull String widgetId);

    abstract public void onFailure(@NonNull AdError adError, @NonNull String widgetId);
}
