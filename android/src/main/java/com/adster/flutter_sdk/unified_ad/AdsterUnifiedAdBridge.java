package com.adster.flutter_sdk.unified_ad;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;

import com.adster.flutter_sdk.core.AdsterBaseAdBridge;
import com.adster.flutter_sdk.core.AdsterJSONDataMapper;
import com.adster.flutter_sdk.core.AdsterRevenueMapper;
import com.adster.flutter_sdk.core.AdsterTargetingUtils;
import com.adster.sdk.mediation.AdError;
import com.adster.sdk.mediation.AdRequestConfiguration;
import com.adster.sdk.mediation.AdSterAdLoader;
import com.adster.sdk.mediation.MediationBannerAd;
import com.adster.sdk.mediation.MediationNativeAd;
import com.adster.sdk.mediation.MediationNativeAdView;
import com.adster.sdk.mediation.MediationNativeCustomFormatAd;
import com.adster.sdk.mediation.PrecisionType;

import org.json.JSONException;
import org.json.JSONArray;
import org.json.JSONObject;

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
    private final Map<String, MediationNativeCustomFormatAd> customNativeAds = new HashMap<>();
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
                AdRequestConfiguration configuration = AdsterTargetingUtils.buildConfiguration(context, call, placementId);
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
                        customNativeAds.put(widgetId, mediationNativeCustomFormatAd);
                        try {
                            result.success(customNativeToJSON(widgetId, mediationNativeCustomFormatAd));
                        } catch (JSONException e) {
                            result.error("DATA_PARSE_ERROR", e.getMessage(), null);
                        }
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
                    public void onAdRevenuePaid(double v, @NonNull String s, @NonNull String s1, @NonNull String currency, @NonNull PrecisionType precisionType, @NonNull String widgetId) {
                        clickMethodChannel.invokeMethod("onAdRevenuePaid", AdsterRevenueMapper.toMap(v, s, s1, currency, precisionType, widgetId));
                    }

                    @Override
                    public void onCustomNativeAdClicked(@NonNull String assetName, @NonNull String widgetId) {
                        Map<String, String> data = getWidgetIdJSON(widgetId);
                        data.put("assetName", assetName);
                        clickMethodChannel.invokeMethod("onCustomNativeAdClicked", data);
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
        } else if (call.method.equals("customNativeGetText")) {
            MediationNativeCustomFormatAd ad = customNativeAds.get(call.argument("widgetId"));
            String assetName = call.argument("assetName");
            CharSequence text = ad != null && assetName != null ? ad.getText(assetName) : null;
            result.success(text != null ? text.toString() : null);
        } else if (call.method.equals("customNativeGetImageUrl")) {
            MediationNativeCustomFormatAd ad = customNativeAds.get(call.argument("widgetId"));
            String assetName = call.argument("assetName");
            if (ad != null && assetName != null && ad.getImage(assetName) != null && ad.getImage(assetName).getUri() != null) {
                result.success(ad.getImage(assetName).getUri().toString());
            } else {
                result.success(null);
            }
        } else if (call.method.equals("customNativePerformClick")) {
            MediationNativeCustomFormatAd ad = customNativeAds.get(call.argument("widgetId"));
            String assetName = call.argument("assetName");
            if (ad != null && assetName != null) {
                ad.performClick(assetName);
                result.success(null);
            } else {
                result.error("CUSTOM_NATIVE_AD_NOT_LOADED", "Custom native ad not loaded", null);
            }
        } else if (call.method.equals("customNativeRecordImpression")) {
            MediationNativeCustomFormatAd ad = customNativeAds.get(call.argument("widgetId"));
            if (ad != null) {
                ad.recordImpression();
                result.success(null);
            } else {
                result.error("CUSTOM_NATIVE_AD_NOT_LOADED", "Custom native ad not loaded", null);
            }
        } else {
            result.notImplemented();
        }
    }

    String customNativeToJSON(String widgetId, MediationNativeCustomFormatAd ad) throws JSONException {
        JSONObject data = new JSONObject();
        data.put("adType", "customNative");
        data.put("widgetId", widgetId);
        data.put("customFormatId", ad.getCustomFormatId());
        JSONArray assetNames = new JSONArray();
        if (ad.getAvailableAssetNames() != null) {
            for (String assetName : ad.getAvailableAssetNames()) {
                assetNames.put(assetName);
            }
        }
        data.put("availableAssetNames", assetNames);
        return data.toString();
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
        customNativeAds.remove(widgetId);
        mediationNativeAdViews.remove(widgetId);
    }

    public void dispose() {
        methodChannel.setMethodCallHandler(null);
    }
}
