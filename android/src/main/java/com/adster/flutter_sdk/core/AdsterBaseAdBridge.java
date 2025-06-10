package com.adster.flutter_sdk.core;

import android.view.View;

import androidx.annotation.NonNull;

import com.adster.sdk.mediation.MediationNativeAd;
import com.adster.sdk.mediation.MediationNativeAdView;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

abstract public class AdsterBaseAdBridge implements MethodChannel.MethodCallHandler {
    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {

    }

    public View getMediaView() {
        return null;
    }

    public MediationNativeAd getNativeAd(String widgetId) {
        return null;
    }

    public void setMediationNativeAdView(MediationNativeAdView mediationNativeAdView) {

    }

    public void clearWidget(String widgetId) {

    }
}
