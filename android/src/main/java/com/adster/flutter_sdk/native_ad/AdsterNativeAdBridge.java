package com.adster.flutter_sdk.native_ad;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;

import androidx.annotation.NonNull;

import com.adster.flutter_sdk.core.AdsterBaseAdBridge;
import com.adster.flutter_sdk.core.AdsterJSONDataMapper;
import com.adster.flutter_sdk.core.AdsterRevenueMapper;
import com.adster.sdk.mediation.AdError;
import com.adster.sdk.mediation.AdEventsListener;
import com.adster.sdk.mediation.AdRequestConfiguration;
import com.adster.sdk.mediation.AdSterAdLoader;
import com.adster.sdk.mediation.MediationAdListener;
import com.adster.sdk.mediation.MediationNativeAd;
import com.adster.sdk.mediation.MediationNativeAdView;
import com.adster.sdk.mediation.MediationNativeCustomFormatAd;
import com.adster.sdk.mediation.PrecisionType;
import com.google.android.gms.ads.nativead.NativeAdView;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class AdsterNativeAdBridge extends AdsterBaseAdBridge {

    final private MethodChannel methodChannel;
    final private Context context;
    final private MethodChannel clickMethodChannel;
    private final Map<String, MediationNativeAd> nativeAds = new HashMap<>();
    private final Map<String, MediationNativeCustomFormatAd> customNativeAds = new HashMap<>();
    private final Map<String, MediationNativeAdView> mediationNativeAdViews = new HashMap<>();

    public AdsterNativeAdBridge(BinaryMessenger messenger, Context context) {
        this.methodChannel = new MethodChannel(messenger, "adster.channel:adster_native_ad");
        this.clickMethodChannel = new MethodChannel(messenger, "adster.channel:adster_native_ad_click");
        this.methodChannel.setMethodCallHandler(this);
        this.context = context;
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("loadNativeAd")) {
            String adPlacementName = call.argument("adPlacementName");
            String widgetId = call.argument("widgetId");
            if (adPlacementName != null && widgetId != null) {
                AdRequestConfiguration configuration = AdRequestConfiguration.Companion.builder(context, adPlacementName).build();
                AdSterAdLoader.Companion.builder().withAdsListener(new AdsterNativeMediationAdListener(widgetId) {
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
                    public void onFailure(@NonNull AdError adError, @NonNull String widgetId) {
                        //Handle failure callback here
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
        } else if (call.method.equals("loadCustomNativeAd")) {
            String adPlacementName = call.argument("adPlacementName");
            String widgetId = call.argument("widgetId");
            if (adPlacementName != null && widgetId != null) {
                AdRequestConfiguration configuration = AdRequestConfiguration.Companion.builder(context, adPlacementName).build();
                AdSterAdLoader.Companion.builder().withAdsListener(new MediationAdListener() {
                    @Override
                    public void onNativeCustomFormatAdLoaded(@NonNull MediationNativeCustomFormatAd ad) {
                        customNativeAds.put(widgetId, ad);
                        try {
                            result.success(customNativeToJSON(widgetId, ad));
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

    Map<String, String> getWidgetIdJSON(String widgetId) {
        Map<String, String> data = new HashMap<>();
        data.put("widgetId", widgetId);
        return data;
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

    public void dispose() {
        methodChannel.setMethodCallHandler(null);
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
}
