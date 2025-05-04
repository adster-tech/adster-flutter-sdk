package com.adster.flutter_sdk.native_ad;

import androidx.annotation.NonNull;

import com.adster.sdk.mediation.AdEventsListener;

abstract public class AdsterNativeEventAdListener extends AdEventsListener {
    final String widgetId;

    public AdsterNativeEventAdListener(String widgetId) {
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

    abstract public void onAdClicked(@NonNull String widgetId);

    abstract public void onAdImpression(@NonNull String widgetId);
}
