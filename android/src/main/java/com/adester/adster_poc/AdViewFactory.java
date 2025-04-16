package com.adester.adster_poc;

import android.content.Context;
import android.util.Log;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MessageCodec;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class AdViewFactory extends PlatformViewFactory {
    private final BinaryMessenger messenger;

    public AdViewFactory(BinaryMessenger messenger) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
    }

    @NonNull
    @Override
    public PlatformView create(Context context, int viewId, @Nullable Object args) {
        Log.d("AdViewFactory", "create: " + viewId + " Args: " + (args != null ? args.toString() : ""));
        if (viewId == 101) {
        }
        return new AdsterBannerAds(context, messenger);
        //return new AdsterEmptyContainer(context);
    }
}
