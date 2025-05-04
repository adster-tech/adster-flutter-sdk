package com.adster.flutter_sdk.app_opened_ad;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.adster.sdk.mediation.AdError;
import com.adster.sdk.mediation.AppOpenAdEventsListener;
import com.adster.sdk.mediation.Reward;
import com.adster.sdk.mediation.RewardedAdEventsListener;

abstract public class AdsterAppOpenedEventAdListener extends AppOpenAdEventsListener {
    final String widgetId;

    public AdsterAppOpenedEventAdListener(String widgetId) {
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
    public void onFailure(@Nullable AdError adError) {
        onFailure(adError, widgetId);
    }

    abstract public void onAdClicked(@NonNull String widgetId);

    abstract public void onAdImpression(@NonNull String widgetId);

    abstract public void onAdOpened(@NonNull String widgetId);

    abstract public void onAdClosed(@NonNull String widgetId);

    abstract public void onFailure(@Nullable AdError adError, @NonNull String widgetId);
}
