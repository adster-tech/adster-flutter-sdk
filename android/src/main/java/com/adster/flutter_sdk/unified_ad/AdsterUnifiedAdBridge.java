package com.adster.flutter_sdk.unified_ad;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;

import com.adster.flutter_sdk.core.AdsterBaseAdBridge;
import com.adster.flutter_sdk.core.AdsterJSONDataMapper;
import com.adster.sdk.mediation.AdError;
import com.adster.sdk.mediation.AdRequestConfiguration;
import com.adster.sdk.mediation.AdSterAdLoader;
import com.adster.sdk.mediation.MediationBannerAd;
import com.adster.sdk.mediation.MediationNativeAd;
import com.adster.sdk.mediation.MediationNativeAdView;
import com.adster.sdk.mediation.MediationNativeCustomFormatAd;

import org.json.JSONException;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AdsterUnifiedAdBridge extends AdsterBaseAdBridge {

    final private MethodChannel methodChannel;
    final private MethodChannel clickMethodChannel;
    final private Context context;
    private View mediaView = null;
    private final Map<String, MediationNativeAd> nativeAds = new HashMap<>();
    private final Map<String, MediationNativeAdView> mediationNativeAdViews = new HashMap<>();

    public AdsterUnifiedAdBridge(BinaryMessenger messenger, Context context) {
        methodChannel = new MethodChannel(messenger, "adster.channel:adster_unified");
        clickMethodChannel = new MethodChannel(messenger, "adster.channel:adster_unified_ad_click");
        methodChannel.setMethodCallHandler(this);
        this.context = context;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Log.d("AdsterUnifiedAds", "onMethodCall: " + call.method);
        if (call.method.equals("loadUnified")) {
            String placementId = call.argument("adPlacementName");
            String widgetId = call.argument("widgetId");
            Log.d("AdsterUnifiedAds", "loadUnified: " + placementId + " widgetId: " + widgetId);
            if (placementId != null && widgetId != null) {
                AdRequestConfiguration configuration = AdRequestConfiguration.Companion.builder(context, placementId).build();
                AdSterAdLoader.Companion.builder().withAdsListener(new AdsterUnifiedMediationAdListener(widgetId) {
                    @Override
                    public void onBannerAdLoaded(@NonNull MediationBannerAd mediationBannerAd, @NonNull String widgetId) {
                        mediaView = mediationBannerAd.getView();
                        result.success("true");
                    }

                    @Override
                    public void onNativeAdLoaded(@NonNull MediationNativeAd ad, @NonNull String widgetId) {
                        nativeAds.put(widgetId, ad);
                        try {
                            String data = new AdsterJSONDataMapper().toJSONStr(ad);
                            result.success(data);
                        } catch (JSONException e) {
                            result.error("DATA_PARSE_ERROR", e.getMessage(), null);
                        }
                    }

                    @Override
                    public void onNativeCustomFormatAdLoaded(@NonNull MediationNativeCustomFormatAd mediationNativeCustomFormatAd, @NonNull String widgetId) {

                    }

                    @Override
                    public void onFailure(@NonNull String widgetId, @NonNull AdError adError) {
                        result.error(String.valueOf(adError.getErrorCode()), adError.getErrorMessage(), null);
                    }
                }).withAdsEventsListener(new AdsterUnifiedEventAdListener(widgetId) {
                    @Override
                    public void onAdClicked(@NonNull String widgetId) {
                        clickMethodChannel.invokeMethod("onAdClicked", getWidgetIdJSON(widgetId));
                    }

                    @Override
                    public void onAdImpression(@NonNull String widgetId) {
                        clickMethodChannel.invokeMethod("onAdImpression", getWidgetIdJSON(widgetId));
                    }

                    @Override
                    public void onAdRevenuePaid(double v, @NonNull String s, @NonNull String s1, @NonNull String widgetId) {
                        Map<String, Object> data = new HashMap<>();
                        data.put("revenue", v);
                        data.put("adUnitId", s);
                        data.put("network", s1);
                        data.put("widgetId", widgetId);
                        clickMethodChannel.invokeMethod("onAdRevenuePaid", data);
                    }
                }).build().loadAd(configuration);
            } else {
                result.error("EMP_PLACEMENT_ID", "Placement id were not supplied", null);
            }
        } else if (call.method.equals("nativeMediaClick")) {
            String widgetId = call.argument("widgetId");
            String componentName = call.argument("componentName");
            MediationNativeAdView mediationNativeAdView = mediationNativeAdViews.get(widgetId);
            if (componentName != null && widgetId != null && mediationNativeAdView != null) {
                switch (componentName) {
                    case "body":
                        if (clickSense(widgetId)) {
                            mediationNativeAdView.onClick(mediationNativeAdView.getBodyView());
                        }
                        break;
                    case "callToAction":
                        if (clickSense(widgetId)) {
                            mediationNativeAdView.onClick(mediationNativeAdView.getCtaView());
                        }
                        break;
                    case "headline":
                        if (clickSense(widgetId)) {
                            mediationNativeAdView.onClick(mediationNativeAdView.getHeadlineView());
                        }
                        break;
                    case "logo":
                        if (clickSense(widgetId)) {
                            mediationNativeAdView.onClick(mediationNativeAdView.getLogoView());
                        }
                        break;
                    case "ratingBar":
                        if (clickSense(widgetId)) {
                            mediationNativeAdView.onClick(mediationNativeAdView.getRatingBarView());
                        }
                        break;
                }
                result.success("");
            } else {
                result.error("NATIVE_AD_NOT_LOADED", "Native ad not loaded", null);
            }
        } else {
            result.notImplemented();
        }
    }

    private boolean clickSense(String widgetId) {
        MediationNativeAd nativeAd = nativeAds.get(widgetId);
        if (nativeAd != null) {
            if (TextUtils.isEmpty(nativeAd.getLandingUrl())) {
                if (nativeAd.getMediaView() != null) {
                    nativeAd.getMediaView().performClick();
                }
                return false;
            }
        } else {
            return false;
        }
        return true;
    }

    Map<String, String> getWidgetIdJSON(String widgetId) {
        Map<String, String> data = new HashMap<>();
        data.put("widgetId", widgetId);
        return data;
    }

    @Override
    public View getMediaView() {
        return mediaView;
    }

    @Override
    public MediationNativeAd getNativeAd(String widgetId) {
        return nativeAds.get(widgetId);
    }

    @Override
    public void setMediationNativeAdView(MediationNativeAdView mediationNativeAdView) {
        mediationNativeAdViews.put(mediationNativeAdView.getTag().toString(), mediationNativeAdView);
    }

    @Override
    public void clearWidget(String widgetId) {
        nativeAds.remove(widgetId);
        mediationNativeAdViews.remove(widgetId);
    }

    public void dispose() {
        methodChannel.setMethodCallHandler(null);
    }
}
