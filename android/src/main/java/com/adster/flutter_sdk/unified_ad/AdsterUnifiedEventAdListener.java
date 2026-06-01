package com.adster.flutter_sdk.unified_ad;

import androidx.annotation.NonNull;

import com.adster.sdk.mediation.AdEventsListener;
import com.adster.sdk.mediation.MediationNativeCustomFormatAd;
import com.adster.sdk.mediation.PrecisionType;

abstract public class AdsterUnifiedEventAdListener extends AdEventsListener {
    final String widgetId;

    public AdsterUnifiedEventAdListener(String widgetId) {
        this.widgetId = widgetId;
    }

    @Override
    public void onAdClicked() {
        onAdClicked(widgetId);
    }

    @Override
    public void onAdImpression() {
        onAdImpression(widgetId);
    }

    @Override
    public void onAdRevenuePaid(double revenue, @NonNull String adUnitId, @NonNull String network, @NonNull String currency, @NonNull PrecisionType precisionType) {
        onAdRevenuePaid(revenue, adUnitId, network, currency, precisionType, widgetId);
    }

    @Override
    public void onCustomNativeAdClicked(@NonNull MediationNativeCustomFormatAd ad, @NonNull String assetName) {
        onCustomNativeAdClicked(assetName, widgetId);
    }

    abstract public void onAdClicked(@NonNull String widgetId);

    abstract public void onAdImpression(@NonNull String widgetId);

    abstract public void onAdRevenuePaid(double v, @NonNull String s, @NonNull String s1, @NonNull String currency, @NonNull PrecisionType precisionType, @NonNull String widgetId);

    public void onCustomNativeAdClicked(@NonNull String assetName, @NonNull String widgetId) {
    }
}
