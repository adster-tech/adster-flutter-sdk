package com.adster.flutter_sdk.banner;

import android.content.Context;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import com.adster.flutter_sdk.core.AdsterBaseAdBridge;

import io.flutter.plugin.platform.PlatformView;

public class AdsterBannerAds implements PlatformView {
    private final FrameLayout container;
    private final AdsterBannerAdBridge bridge;
    private final AdsterBannerAdBridge.BannerRequest request;

    // Retain the existing constructor used by the separate unified-ad bridge.
    public AdsterBannerAds(Context context, AdsterBaseAdBridge bridge) {
        this.bridge = null;
        request = null;
        container = new FrameLayout(context);
        container.addView(bridge.getMediaView());
    }

    public AdsterBannerAds(Context context, String widgetId, AdsterBannerAdBridge bridge) {
        this.bridge = bridge;
        request = bridge.getBanner(widgetId);
        // Never steal a view from another active slot to hide an ownership error.
        if (request.view.getParent() != null) {
            throw new IllegalStateException("Banner already attached for widget " + widgetId);
        }
        container = new FrameLayout(context);
        container.addView(request.view);
    }

    @NonNull
    @Override
    public View getView() {
        return container;
    }

    @Override
    public void dispose() {
        container.removeAllViews();
        if (bridge != null) bridge.release(request);
    }
}
