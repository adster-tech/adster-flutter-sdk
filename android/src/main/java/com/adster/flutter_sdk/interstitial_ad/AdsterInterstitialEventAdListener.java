package com.adster.flutter_sdk.interstitial_ad;

import androidx.annotation.NonNull;

import com.adster.sdk.mediation.AdEventsListener;
import com.adster.sdk.mediation.InterstitialAdEventsListener;

abstract public class AdsterInterstitialEventAdListener extends InterstitialAdEventsListener {
    final String widgetId;

    public AdsterInterstitialEventAdListener(String widgetId) {
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
    public void onAdOpened() {
        onAdOpened(widgetId);
    }

    @Override
    public void onAdClosed() {
        onAdClosed(widgetId);
    }

    @Override
    public void onAdRevenuePaid(double revenue, @NonNull String adUnitId, @NonNull String network) {
        onAdRevenuePaid(revenue, adUnitId, network, widgetId);
    }

    abstract public void onAdClicked(@NonNull String widgetId);

    abstract public void onAdImpression(@NonNull String widgetId);

    abstract public void onAdOpened(@NonNull String widgetId);

    abstract public void onAdClosed(@NonNull String widgetId);

    abstract public void onAdRevenuePaid(double v, @NonNull String s, @NonNull String s1, @NonNull String widgetId);
}
