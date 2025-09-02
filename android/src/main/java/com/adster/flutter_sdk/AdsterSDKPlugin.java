package com.adster.flutter_sdk;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.adster.flutter_sdk.app_opened_ad.AdsterAppOpenedAdBridge;
import com.adster.flutter_sdk.banner.AdsterBannerAdBridge;
import com.adster.flutter_sdk.banner.AdsterBannerAdViewFactory;
import com.adster.flutter_sdk.interstitial_ad.AdsterInterstitialAdBridge;
import com.adster.flutter_sdk.native_ad.AdsterNativeAdBridge;
import com.adster.flutter_sdk.native_ad.AdsterNativeAdViewFactory;
import com.adster.flutter_sdk.rewarded_ad.AdsterRewardedAdBridge;
import com.adster.flutter_sdk.unified_ad.AdsterUnifiedAdBridge;
import com.adster.flutter_sdk.unified_ad.AdsterUnifiedBannerAdViewFactory;
import com.adster.flutter_sdk.unified_ad.AdsterUnifiedNativeAdViewFactory;
import com.adster.sdk.mediation.AdError;
import com.adster.sdk.mediation.AdEventsListener;
import com.adster.sdk.mediation.AdRequestConfiguration;
import com.adster.sdk.mediation.AdSter;
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
    private AdsterInterstitialAdBridge adsterInterstitialAdBridge;
    private AdsterBannerAdBridge adsterBannerAdBridge;
    private AdsterAppOpenedAdBridge adsterAppOpenedAdBridge;
    private AdsterUnifiedAdBridge adsterUnifiedAdBridge;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        Log.d("AdsterSDKPlugin", "onAttachedToEngine");
        Context context = flutterPluginBinding.getApplicationContext();

        /*Initialize Adster SDK*/
        AdSter.INSTANCE.initializeSdk(flutterPluginBinding.getApplicationContext(), AdapterStatus -> {
            Log.d("AdsterSDKPlugin", "AdapterStatus: " + AdapterStatus);
        });

        //For testing purposes only
        List<String> testDeviceIds = List.of("B483487FE7D832D226373700DF3E654C");
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

        /*Initialize interstitial ad bridge*/
        adsterInterstitialAdBridge = new AdsterInterstitialAdBridge(flutterPluginBinding.getBinaryMessenger(), flutterPluginBinding.getApplicationContext());

        /*Initialize app opened ad bridge*/
        adsterAppOpenedAdBridge = new AdsterAppOpenedAdBridge(flutterPluginBinding.getBinaryMessenger(), flutterPluginBinding.getApplicationContext());

        /*Initialize unified ad bridge*/
        adsterUnifiedAdBridge = new AdsterUnifiedAdBridge(flutterPluginBinding.getBinaryMessenger(), context);

        flutterPluginBinding.getPlatformViewRegistry().registerViewFactory("adster_unified_banner", new AdsterUnifiedBannerAdViewFactory(adsterUnifiedAdBridge));

        flutterPluginBinding.getPlatformViewRegistry().registerViewFactory("adster_unified_native", new AdsterUnifiedNativeAdViewFactory(adsterUnifiedAdBridge));
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
        if (adsterInterstitialAdBridge != null) {
            adsterInterstitialAdBridge.dispose();
        }
        if (adsterAppOpenedAdBridge != null) {
            adsterAppOpenedAdBridge.dispose();
        }

        if (adsterUnifiedAdBridge != null) {
            adsterUnifiedAdBridge.dispose();
        }
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        if (adsterRewardedAdBridge != null) {
            adsterRewardedAdBridge.setActivity(binding.getActivity());
        }
        if (adsterInterstitialAdBridge != null) {
            adsterInterstitialAdBridge.setActivity(binding.getActivity());
        }
        if (adsterAppOpenedAdBridge != null) {
            adsterAppOpenedAdBridge.setActivity(binding.getActivity());
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
        if (adsterInterstitialAdBridge != null) {
            adsterInterstitialAdBridge.setActivity(binding.getActivity());
        }
        if (adsterAppOpenedAdBridge != null) {
            adsterAppOpenedAdBridge.setActivity(binding.getActivity());
        }
    }

    @Override
    public void onDetachedFromActivity() {
        if (adsterRewardedAdBridge != null) {
            adsterRewardedAdBridge.setActivity(null);
        }
        if (adsterInterstitialAdBridge != null) {
            adsterInterstitialAdBridge.setActivity(null);
        }
        if (adsterAppOpenedAdBridge != null) {
            adsterAppOpenedAdBridge.setActivity(null);
        }
    }
}
