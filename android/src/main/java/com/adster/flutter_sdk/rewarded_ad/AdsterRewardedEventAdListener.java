package com.adster.flutter_sdk.rewarded_ad;

import androidx.annotation.NonNull;

import com.adster.sdk.mediation.InterstitialAdEventsListener;
import com.adster.sdk.mediation.Reward;
import com.adster.sdk.mediation.RewardedAdEventsListener;

import java.util.Map;

abstract public class AdsterRewardedEventAdListener extends RewardedAdEventsListener {
    final String widgetId;

    public AdsterRewardedEventAdListener(String widgetId) {
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
    public void onUserEarnedReward(@NonNull Reward reward) {
        onUserEarnedReward(widgetId, reward);
    }

    @Override
    public void onVideoComplete() {
        onVideoComplete(widgetId);
    }

    @Override
    public void onVideoClosed() {
        onVideoClosed(widgetId);
    }

    @Override
    public void onVideoStart() {
        onVideoStart(widgetId);
    }

    @Override
    public void onAdRevenuePaid(double revenue, @NonNull String adUnitId, @NonNull String network) {
        onAdRevenuePaid(revenue, adUnitId, network, widgetId);
    }

    abstract public void onAdClicked(@NonNull String widgetId);

    abstract public void onAdImpression(@NonNull String widgetId);

    abstract public void onUserEarnedReward(@NonNull String widgetId, @NonNull Reward reward);

    abstract public void onVideoComplete(@NonNull String widgetId);

    abstract public void onVideoClosed(@NonNull String widgetId);

    abstract public void onVideoStart(@NonNull String widgetId);

    abstract public void onAdRevenuePaid(double v, @NonNull String s, @NonNull String s1, @NonNull String widgetId);
}
