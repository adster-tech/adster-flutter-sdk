package com.adster.flutter_sdk.unified_ad;

import androidx.annotation.NonNull;

import com.adster.sdk.mediation.AdError;
import com.adster.sdk.mediation.MediationAdListener;
import com.adster.sdk.mediation.MediationBannerAd;
import com.adster.sdk.mediation.MediationNativeAd;
import com.adster.sdk.mediation.MediationNativeCustomFormatAd;

abstract public class AdsterUnifiedMediationAdListener extends MediationAdListener {
    final String widgetId;

    public AdsterUnifiedMediationAdListener(String widgetId) {
        this.widgetId = widgetId;
    }

    abstract public void onBannerAdLoaded(@NonNull MediationBannerAd mediationBannerAd, @NonNull String widgetId);

    abstract public void onNativeAdLoaded(@NonNull MediationNativeAd mediationNativeAd, @NonNull String widgetId);

    abstract public void onNativeCustomFormatAdLoaded(@NonNull MediationNativeCustomFormatAd mediationNativeCustomFormatAd, @NonNull String widgetId);

    abstract public void onFailure(@NonNull String widgetId, @NonNull AdError adError);

    @Override
    public void onBannerAdLoaded(@NonNull MediationBannerAd mediationBannerAd) {
        super.onBannerAdLoaded(mediationBannerAd);
        onBannerAdLoaded(mediationBannerAd, widgetId);
    }

    @Override
    public void onNativeAdLoaded(@NonNull MediationNativeAd mediationNativeAd) {
        onNativeAdLoaded(mediationNativeAd, widgetId);
    }

    @Override
    public void onNativeCustomFormatAdLoaded(@NonNull MediationNativeCustomFormatAd mediationNativeCustomFormatAd) {
        onNativeCustomFormatAdLoaded(mediationNativeCustomFormatAd, widgetId);
    }

    @Override
    public void onFailure(@NonNull AdError adError) {
        onFailure(widgetId, adError);
    }
}
