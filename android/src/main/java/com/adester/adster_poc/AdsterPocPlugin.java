package com.adester.adster_poc;

import android.content.Context;
import android.util.Log;

import androidx.annotation.NonNull;

import com.adster.sdk.mediation.AdError;
import com.adster.sdk.mediation.AdEventsListener;
import com.adster.sdk.mediation.AdRequestConfiguration;
import com.adster.sdk.mediation.AdSter;
import com.adster.sdk.mediation.AdSterAdLoader;
import com.adster.sdk.mediation.MediationAdListener;
import com.adster.sdk.mediation.MediationNativeAd;
import com.adster.sdk.mediation.MediationNativeAdView;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.RequestConfiguration;

import java.util.Arrays;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * AdsterPocPlugin
 */
public class AdsterPocPlugin implements FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private Context context;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        Log.d("AdsterPocPlugin", "onAttachedToEngine");
        context = flutterPluginBinding.getApplicationContext();
        AdSter.INSTANCE.initializeSdk(flutterPluginBinding.getApplicationContext(), AdapterStatus -> {
            Log.d("AdsterPocPlugin", "AdapterStatus: " + AdapterStatus);
        });

        List<String> testDeviceIds = Arrays.asList("B483487FE7D832D226373700DF3E654C");
        RequestConfiguration configuration =
                new RequestConfiguration.Builder().setTestDeviceIds(testDeviceIds).build();
        MobileAds.setRequestConfiguration(configuration);

        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "adster_channel");
        channel.setMethodCallHandler(this);
        flutterPluginBinding
                .getPlatformViewRegistry()
                .registerViewFactory("adster_banner", new AdViewFactory(flutterPluginBinding.getBinaryMessenger()));
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android " + android.os.Build.VERSION.RELEASE);
        }
        if (call.method.equals("native_ad_data")) {
            String adPlacementName = call.argument("adPlacementName");
            AdRequestConfiguration configuration = AdRequestConfiguration.Companion.builder(context, "Your_placement_name").build();
            AdSterAdLoader.Companion.builder().withAdsListener(new MediationAdListener() {
                @Override
                public void onNativeAdLoaded(@NonNull MediationNativeAd ad) {
                    super.onNativeAdLoaded(ad);
                    //Show native ad here
                }

                @Override
                public void onFailure(@NonNull AdError adError) {
                    //Handle failure callback here
                }
            }).withAdsEventsListener(new AdEventsListener() {
                @Override
                public void onAdClicked() {
                    //Handle ad click here
                }

                @Override
                public void onAdImpression() {
                    //Handle ad impression here
                }
            }).build().loadAd(configuration);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
