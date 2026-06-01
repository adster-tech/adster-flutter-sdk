package com.adster.flutter_sdk.carousel;

import android.content.Context;
import android.view.View;

import androidx.annotation.NonNull;

import com.adster.flutter_sdk.core.AdsterBaseAdBridge;
import com.adster.flutter_sdk.core.AdsterRevenueMapper;
import com.adster.sdk.mediation.AdError;
import com.adster.sdk.mediation.AdRequestConfiguration;
import com.adster.sdk.mediation.AdSterAdLoader;
import com.adster.sdk.mediation.MediationAdListener;
import com.adster.sdk.mediation.MediationBannerAd;
import com.adster.sdk.mediation.MediationCarouselBannerAd;
import com.adster.sdk.mediation.PrecisionType;
import com.adster.flutter_sdk.banner.AdsterBannerEventAdListener;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AdsterCarouselBannerAdBridge extends AdsterBaseAdBridge {
    private final MethodChannel methodChannel;
    private final MethodChannel clickMethodChannel;
    private final Context context;
    private final Map<String, List<MediationBannerAd>> ads = new HashMap<>();

    public AdsterCarouselBannerAdBridge(BinaryMessenger messenger, Context context) {
        methodChannel = new MethodChannel(messenger, "adster.channel:adster_carousel_banner");
        clickMethodChannel = new MethodChannel(messenger, "adster.channel:adster_banner_ad_click");
        methodChannel.setMethodCallHandler(this);
        this.context = context;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("loadCarouselBanner")) {
            String placementId = call.argument("adPlacementName");
            String widgetId = call.argument("widgetId");
            if (placementId != null && widgetId != null) {
                AdRequestConfiguration configuration = AdRequestConfiguration.Companion.builder(context, placementId).build();
                AdSterAdLoader.Companion.builder().withAdsListener(new MediationAdListener() {
                    @Override
                    public void onCarouselBannerAdLoaded(@NonNull MediationCarouselBannerAd ad) {
                        ads.put(widgetId, ad.getAds());
                        result.success(ad.getAds().size());
                    }

                    @Override
                    public void onFailure(@NonNull AdError adError) {
                        result.error(String.valueOf(adError.getErrorCode()), adError.getErrorMessage(), null);
                    }
                }).withAdsEventsListener(new AdsterBannerEventAdListener(widgetId) {
                    @Override
                    public void onAdClicked(@NonNull String widgetId) {
                        clickMethodChannel.invokeMethod("onAdClicked", getWidgetIdJSON(widgetId));
                    }

                    @Override
                    public void onAdImpression(@NonNull String widgetId) {
                        clickMethodChannel.invokeMethod("onAdImpression", getWidgetIdJSON(widgetId));
                    }

                    @Override
                    public void onAdRevenuePaid(double v, @NonNull String s, @NonNull String s1, @NonNull String currency, @NonNull PrecisionType precisionType, @NonNull String widgetId) {
                        clickMethodChannel.invokeMethod("onAdRevenuePaid", AdsterRevenueMapper.toMap(v, s, s1, currency, precisionType, widgetId));
                    }
                }).build().loadAd(configuration);
            } else {
                result.error("EMP_PLACEMENT_ID", "Placement id were not supplied", null);
            }
        } else {
            result.notImplemented();
        }
    }

    View getView(String widgetId, int index) {
        List<MediationBannerAd> items = ads.get(widgetId);
        if (items == null || index < 0 || index >= items.size()) {
            return null;
        }
        return items.get(index).getView();
    }

    Map<String, String> getWidgetIdJSON(String widgetId) {
        Map<String, String> data = new HashMap<>();
        data.put("widgetId", widgetId);
        return data;
    }

    public void dispose() {
        methodChannel.setMethodCallHandler(null);
    }
}
