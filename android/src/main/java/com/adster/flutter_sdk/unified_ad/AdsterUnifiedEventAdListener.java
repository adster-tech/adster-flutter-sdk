package com.adster.flutter_sdk.unified_ad;

import androidx.annotation.NonNull;

import com.adster.sdk.mediation.AdEventsListener;

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
    public void onAdRevenuePaid(double revenue, @NonNull String adUnitId, @NonNull String network) {
        onAdRevenuePaid(revenue, adUnitId, network, widgetId);
    }

    abstract public void onAdClicked(@NonNull String widgetId);

    abstract public void onAdImpression(@NonNull String widgetId);

    abstract public void onAdRevenuePaid(double v, @NonNull String s, @NonNull String s1, @NonNull String widgetId);
}
