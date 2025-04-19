package com.adster.flutter_sdk;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.adster.flutter_sdk.banner.AdsterBannerAdBridge;
import com.adster.flutter_sdk.banner.AdsterBannerAdViewFactory;
import com.adster.flutter_sdk.native_ad.AdsterNativeAdBridge;
import com.adster.flutter_sdk.native_ad.AdsterNativeAdViewFactory;
import com.adster.flutter_sdk.rewarded_ad.AdsterRewardedAdBridge;
import com.adster.sdk.mediation.AdError;
import com.adster.sdk.mediation.AdEventsListener;
import com.adster.sdk.mediation.AdRequestConfiguration;
import com.adster.sdk.mediation.AdSter;
import com.adster.sdk.mediation.AdSterAdLoader;
import com.adster.sdk.mediation.MediationAdListener;
import com.adster.sdk.mediation.MediationNativeAd;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.RequestConfiguration;

import java.util.Arrays;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * AdsterSDKPlugin
 */
public class AdsterSDKPlugin implements FlutterPlugin, ActivityAware {
    private AdsterNativeAdBridge adsterNativeAdBridge;
    private AdsterRewardedAdBridge adsterRewardedAdBridge;
    private AdsterBannerAdBridge adsterBannerAdBridge;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        Log.d("AdsterSDKPlugin", "onAttachedToEngine");
        Context context = flutterPluginBinding.getApplicationContext();

        /*Initialize Adster SDK*/
        AdSter.INSTANCE.initializeSdk(flutterPluginBinding.getApplicationContext(), AdapterStatus -> {
            Log.d("AdsterSDKPlugin", "AdapterStatus: " + AdapterStatus);
        });

        /*For testing purposes only*/
        List<String> testDeviceIds = Arrays.asList("B483487FE7D832D226373700DF3E654C");
        RequestConfiguration configuration =
                new RequestConfiguration.Builder().setTestDeviceIds(testDeviceIds).build();
        MobileAds.setRequestConfiguration(configuration);

        adsterBannerAdBridge = new AdsterBannerAdBridge(flutterPluginBinding.getBinaryMessenger(), context);

        /*Register banner view factory*/
        flutterPluginBinding
                .getPlatformViewRegistry()
                .registerViewFactory("adster_banner", new AdsterBannerAdViewFactory(adsterBannerAdBridge));

        /*Initialize native ad bridge*/
        adsterNativeAdBridge = new AdsterNativeAdBridge(flutterPluginBinding.getBinaryMessenger(), context);

        /*Register native ad view factory*/
        flutterPluginBinding
                .getPlatformViewRegistry()
                .registerViewFactory("adster_native", new AdsterNativeAdViewFactory(adsterNativeAdBridge));

        /*Initialize rewarded ad bridge*/
        adsterRewardedAdBridge = new AdsterRewardedAdBridge(flutterPluginBinding.getBinaryMessenger(), flutterPluginBinding.getApplicationContext());
    }


    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        if (adsterBannerAdBridge != null) {
            adsterBannerAdBridge.dispose();
        }
        if (adsterNativeAdBridge != null) {
            adsterNativeAdBridge.dispose();
        }
        if (adsterRewardedAdBridge != null) {
            adsterRewardedAdBridge.dispose();
        }
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        if (adsterRewardedAdBridge != null) {
            adsterRewardedAdBridge.setActivity(binding.getActivity());
        }
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        if (adsterRewardedAdBridge != null) {
            adsterRewardedAdBridge.setActivity(binding.getActivity());
        }
    }

    @Override
    public void onDetachedFromActivity() {
        adsterRewardedAdBridge.setActivity(null);
    }
}
