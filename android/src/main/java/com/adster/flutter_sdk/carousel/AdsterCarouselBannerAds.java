package com.adster.flutter_sdk.carousel;

import android.content.Context;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.Nullable;

import io.flutter.plugin.platform.PlatformView;

public class AdsterCarouselBannerAds implements PlatformView {
    private final FrameLayout container;

    public AdsterCarouselBannerAds(Context context, String widgetId, int index, AdsterCarouselBannerAdBridge bridge) {
        container = new FrameLayout(context);
        View view = bridge.getView(widgetId, index);
        if (view != null) {
            container.addView(view);
        }
    }

    @Nullable
    @Override
    public View getView() {
        return container;
    }

    @Override
    public void dispose() {
    }
}
