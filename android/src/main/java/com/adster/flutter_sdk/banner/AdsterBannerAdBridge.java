package com.adster.flutter_sdk.banner;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import java.util.ArrayList;

import androidx.annotation.NonNull;

import com.adster.flutter_sdk.core.AdsterBaseAdBridge;
import com.adster.flutter_sdk.core.AdsterRevenueMapper;
import com.adster.flutter_sdk.core.AdsterTargetingUtils;
import com.adster.sdk.mediation.AdError;
import com.adster.sdk.mediation.AdRequestConfiguration;
import com.adster.sdk.mediation.AdSterAdLoader;
import com.adster.sdk.mediation.MediationAdListener;
import com.adster.sdk.mediation.MediationBannerAd;
import com.adster.sdk.mediation.PrecisionType;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AdsterBannerAdBridge extends AdsterBaseAdBridge {

    final private MethodChannel methodChannel;
    final private MethodChannel clickMethodChannel;
    final private Context context;
    // Requests are owned by widget instance, not placement (which can be repeated).
    private final Map<String, BannerRequest> banners = new HashMap<>();

    static final class BannerRequest {
        final String widgetId;
        final MethodChannel.Result result;
        MediationBannerAd ad;
        View view;
        boolean completed;

        BannerRequest(String widgetId, MethodChannel.Result result) {
            this.widgetId = widgetId;
            this.result = result;
        }
    }

    public AdsterBannerAdBridge(BinaryMessenger messenger, Context context) {
        methodChannel = new MethodChannel(messenger, "adster.channel:adster_banner");
        clickMethodChannel = new MethodChannel(messenger, "adster.channel:adster_banner_ad_click");
        methodChannel.setMethodCallHandler(this);
        this.context = context;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Log.d("AdsterBannerAds", "onMethodCall: " + call.method);
        if (call.method.equals("loadBanner")) {
            String placementId = call.argument("adPlacementName");
            String widgetId = call.argument("widgetId");
            Log.d("AdsterBannerAds", "loadBanner: " + placementId + " widgetId: " + widgetId);
            if (placementId != null && !placementId.isEmpty() && widgetId != null && !widgetId.isEmpty()) {
                if (banners.containsKey(widgetId)) {
                    result.error("BANNER_ALREADY_EXISTS", "Banner widget already has an active request", null);
                    return;
                }
                BannerRequest request = new BannerRequest(widgetId, result);
                banners.put(widgetId, request);
                requestBanner(call, new MediationAdListener() {
                    @Override
                    public void onBannerAdLoaded(@NonNull MediationBannerAd ad) {
                        super.onBannerAdLoaded(ad);
                        if (banners.get(widgetId) != request || request.completed) {
                            // A disposed request must never revive or replace another banner.
                            if (request.ad != ad) ad.destroy();
                            return;
                        }
                        request.ad = ad;
                        request.view = ad.getView();
                        request.completed = true;
                        if (request.view == null) {
                            release(request);
                            result.error("BANNER_VIEW_MISSING", "Loaded banner has no native view", null);
                            return;
                        }
                        result.success("true");
                    }

                    @Override
                    public void onFailure(@NonNull AdError adError) {
                        if (banners.get(widgetId) != request || request.completed) return;
                        request.completed = true;
                        release(request);
                        result.error(String.valueOf(adError.getErrorCode()), adError.getErrorMessage(), null);
                    }
                }, new AdsterBannerEventAdListener(widgetId) {
                    @Override
                    public void onAdClicked(@NonNull String widgetId) {
                        if (banners.get(widgetId) != request) return;
                        clickMethodChannel.invokeMethod("onAdClicked", getWidgetIdJSON(widgetId));
                    }

                    @Override
                    public void onAdImpression(@NonNull String widgetId) {
                        if (banners.get(widgetId) != request) return;
                        clickMethodChannel.invokeMethod("onAdImpression", getWidgetIdJSON(widgetId));
                    }

                    @Override
                    public void onAdRevenuePaid(double v, @NonNull String s, @NonNull String s1, @NonNull String currency, @NonNull PrecisionType precisionType, @NonNull String widgetId) {
                        if (banners.get(widgetId) != request) return;
                        clickMethodChannel.invokeMethod("onAdRevenuePaid", AdsterRevenueMapper.toMap(v, s, s1, currency, precisionType, widgetId));
                    }
                });
            } else {
                result.error("EMP_PLACEMENT_ID", "Placement id were not supplied", null);
            }
        } else if (call.method.equals("disposeBanner")) {
            clearWidget(call.argument("widgetId"));
            result.success(null);
        } else {
            result.notImplemented();
        }
    }

    void requestBanner(MethodCall call, MediationAdListener listener, AdsterBannerEventAdListener events) {
        AdRequestConfiguration configuration = AdsterTargetingUtils.buildConfiguration(
                context, call, call.argument("adPlacementName"));
        AdSterAdLoader.Companion.builder().withAdsListener(listener)
                .withAdsEventsListener(events).build().loadAd(configuration);
    }

    Map<String, String> getWidgetIdJSON(String widgetId) {
        Map<String, String> data = new HashMap<>();
        data.put("widgetId", widgetId);
        return data;
    }

    BannerRequest getBanner(String widgetId) {
        BannerRequest request = banners.get(widgetId);
        if (request == null || request.view == null) {
            throw new IllegalStateException("No loaded banner for widget " + widgetId);
        }
        return request;
    }

    @Override
    public void clearWidget(String widgetId) {
        BannerRequest request = banners.get(widgetId);
        if (request != null) release(request);
    }

    void release(BannerRequest request) {
        if (banners.get(request.widgetId) != request) return;
        banners.remove(request.widgetId);
        if (!request.completed) {
            request.completed = true;
            request.result.error("BANNER_DISPOSED", "Banner disposed before loading completed", null);
        }
        if (request.view != null && request.view.getParent() instanceof ViewGroup) {
            ((ViewGroup) request.view.getParent()).removeView(request.view);
        }
        if (request.ad != null) request.ad.destroy();
    }

    public void dispose() {
        methodChannel.setMethodCallHandler(null);
        for (BannerRequest request : new ArrayList<>(banners.values())) release(request);
    }
}
