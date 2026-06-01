package com.adster.flutter_sdk.carousel;

import android.content.Context;

import androidx.annotation.NonNull;

import com.adster.flutter_sdk.core.AdsterBaseAdBridge;
import com.adster.flutter_sdk.core.AdsterJSONDataMapper;
import com.adster.flutter_sdk.core.AdsterRevenueMapper;
import com.adster.flutter_sdk.native_ad.AdsterNativeEventAdListener;
import com.adster.sdk.mediation.AdError;
import com.adster.sdk.mediation.AdRequestConfiguration;
import com.adster.sdk.mediation.AdSterAdLoader;
import com.adster.sdk.mediation.MediationAdListener;
import com.adster.sdk.mediation.MediationCarouselNativeAd;
import com.adster.sdk.mediation.MediationNativeAd;
import com.adster.sdk.mediation.MediationNativeAdView;
import com.adster.sdk.mediation.PrecisionType;

import org.json.JSONArray;
import org.json.JSONException;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AdsterCarouselNativeAdBridge extends AdsterBaseAdBridge {
    private final MethodChannel methodChannel;
    private final MethodChannel clickMethodChannel;
    private final Context context;
    private final Map<String, List<MediationNativeAd>> ads = new HashMap<>();
    private final Map<String, MediationNativeAdView> mediationNativeAdViews = new HashMap<>();

    public AdsterCarouselNativeAdBridge(BinaryMessenger messenger, Context context) {
        methodChannel = new MethodChannel(messenger, "adster.channel:adster_carousel_native");
        clickMethodChannel = new MethodChannel(messenger, "adster.channel:adster_native_ad_click");
        methodChannel.setMethodCallHandler(this);
        this.context = context;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("loadCarouselNative")) {
            String placementId = call.argument("adPlacementName");
            String widgetId = call.argument("widgetId");
            if (placementId != null && widgetId != null) {
                AdRequestConfiguration configuration = AdRequestConfiguration.Companion.builder(context, placementId).build();
                AdSterAdLoader.Companion.builder().withAdsListener(new MediationAdListener() {
                    @Override
                    public void onCarouselNativeAdLoaded(@NonNull MediationCarouselNativeAd ad) {
                        ads.put(widgetId, ad.getAds());
                        try {
                            JSONArray data = new JSONArray();
                            AdsterJSONDataMapper mapper = new AdsterJSONDataMapper();
                            for (MediationNativeAd nativeAd : ad.getAds()) {
                                data.put(new org.json.JSONObject(mapper.toJSONStr(nativeAd)));
                            }
                            result.success(data.toString());
                        } catch (JSONException e) {
                            result.error("DATA_PARSE_ERROR", e.getMessage(), null);
                        }
                    }

                    @Override
                    public void onFailure(@NonNull AdError adError) {
                        result.error(String.valueOf(adError.getErrorCode()), adError.getErrorMessage(), null);
                    }
                }).withAdsEventsListener(new AdsterNativeEventAdListener(widgetId) {
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
        } else if (call.method.equals("nativeMediaClick")) {
            String widgetId = call.argument("widgetId");
            Number index = call.argument("index");
            String key = itemKey(widgetId, index == null ? 0 : index.intValue());
            MediationNativeAdView view = mediationNativeAdViews.get(key);
            if (view != null) {
                view.onClick(view.getHeadlineView());
                result.success("");
            } else {
                result.error("NATIVE_AD_NOT_LOADED", "Native ad not loaded", null);
            }
        } else {
            result.notImplemented();
        }
    }

    @Override
    public MediationNativeAd getNativeAd(String widgetId) {
        String[] parts = widgetId.split(":");
        List<MediationNativeAd> items = ads.get(parts[0]);
        int index = parts.length > 1 ? Integer.parseInt(parts[1]) : 0;
        return items != null && index >= 0 && index < items.size() ? items.get(index) : null;
    }

    @Override
    public void setMediationNativeAdView(MediationNativeAdView mediationNativeAdView) {
        mediationNativeAdViews.put(mediationNativeAdView.getTag().toString(), mediationNativeAdView);
    }

    String itemKey(String widgetId, int index) {
        return widgetId + ":" + index;
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
