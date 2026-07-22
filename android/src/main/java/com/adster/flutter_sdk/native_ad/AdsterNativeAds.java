package com.adster.flutter_sdk.native_ad;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RatingBar;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.adster.flutter_sdk.R;
import com.adster.flutter_sdk.core.AdsterBaseAdBridge;
import com.adster.sdk.mediation.MediationNativeAd;
import com.adster.sdk.mediation.MediationNativeAdView;

import java.util.HashMap;
import java.util.Map;
import java.net.URL;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.plugin.platform.PlatformView;

public class AdsterNativeAds implements PlatformView {
    final Context context;
    private final FrameLayout container;
    final AdsterBaseAdBridge adsterNativeAdBridge;
    private final String widgetId;
    private final ExecutorService imageLoader = Executors.newSingleThreadExecutor();

    public AdsterNativeAds(Context context, String widgetId, AdsterBaseAdBridge adsterNativeAdBridge) {
        this.context = context;
        this.widgetId = widgetId;
        container = new FrameLayout(context);
        container.setLayoutParams(new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));
        this.adsterNativeAdBridge = adsterNativeAdBridge;
        displayNativeAd(adsterNativeAdBridge.getNativeAd(widgetId));
    }

    private void displayNativeAd(MediationNativeAd ad) {
        if (ad == null) {
            return;
        }

        // Create AdSter MediationNativeAdView object
        MediationNativeAdView adView = new MediationNativeAdView(context);
        adView.setLayoutParams(new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));

        // Add this layout as a parent to your native ad layout
        View nativeAdView = LayoutInflater.from(context).inflate(R.layout.native_ad_skeleton_container, adView, true);

        // Set native elements
        TextView title = nativeAdView.findViewById(R.id.titleTextView);
        TextView body = nativeAdView.findViewById(R.id.bodyTextView);
        Button cta = nativeAdView.findViewById(R.id.ctaButton);
        ImageView logo = nativeAdView.findViewById(R.id.iconLogoImageView);
        ImageView choice = nativeAdView.findViewById(R.id.choiceImageview);
        TextView info = nativeAdView.findViewById(R.id.infoTextView);
        RatingBar ratingBar = nativeAdView.findViewById(R.id.ratingBar);
        // MediaView
        FrameLayout mediaView = nativeAdView.findViewById(R.id.mediaView);

        // If MediaView is present add AdSter's MediaView as a child to given MediaView
        if (ad.getMediaView() != null) {
            View sdkMediaView = ad.getMediaView();
            if (sdkMediaView.getParent() instanceof android.view.ViewGroup) {
                ((android.view.ViewGroup) sdkMediaView.getParent()).removeView(sdkMediaView);
            }
            mediaView.addView(sdkMediaView, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));
        }
        adView.setBodyView(body);
        adView.setHeadlineView(title);
        adView.setCtaView(cta);
        adView.setLogoView(logo);
        adView.setAdvertiserView(info);
        adView.setRatingBarView(ratingBar);

        loadLogo(logo, ad.getLogo());

        // Set native ad elements with data
        title.setText(ad.getHeadLine());
        body.setText(ad.getBody());
        if (ad.getStarRating() != null) {
            ratingBar.setRating(ad.getStarRating().floatValue());
        }
        cta.setText(ad.getCallToAction());
        info.setText(ad.getAdvertiser());

        Map<String, View> map = new HashMap<>();
        map.put("headline", title);
        map.put("body", body);
        map.put("cta", cta);
        map.put("advertiser", info);
        // Send views to AdSter sdk for tracking click/impressionn etc.
        ad.trackViews(adView, null, map);
        // Set MediationNativeAd object
        adView.setNativeAd(ad);
        adView.setTag(widgetId);
        adsterNativeAdBridge.setMediationNativeAdView(adView);
        // Ad native ad view to container
        container.removeAllViews();
        container.addView(adView, new FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT));
    }

    private void loadLogo(ImageView logo, String logoUrl) {
        if (TextUtils.isEmpty(logoUrl)) {
            logo.setVisibility(View.GONE);
            return;
        }

        logo.setVisibility(View.VISIBLE);
        imageLoader.execute(() -> {
            try {
                Bitmap bitmap = BitmapFactory.decodeStream(new URL(logoUrl).openStream());
                logo.post(() -> logo.setImageBitmap(bitmap));
            } catch (Exception ignored) {
                logo.post(() -> logo.setVisibility(View.GONE));
            }
        });
    }

    @Nullable
    @Override
    public View getView() {
        return container;
    }

    @Override
    public void dispose() {
        imageLoader.shutdownNow();
        adsterNativeAdBridge.clearWidget(widgetId);
    }
}
