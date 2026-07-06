package com.adster.flutter_sdk.core;

import android.content.Context;

import com.adster.sdk.mediation.AdRequestConfiguration;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;

/**
 * Builds an {@link AdRequestConfiguration} for a placement and applies the optional
 * predefined custom targeting values and publisher provided id (PPID) that were
 * supplied from the Flutter layer via the method channel arguments.
 *
 * Supported arguments:
 * - "customTargetArgs": Map where each value is either a String (single value) or a
 *   List of Strings (multiple values for the same key).
 * - "publisherProvidedId": String PPID.
 */
public final class AdsterTargetingUtils {

    private AdsterTargetingUtils() {
    }

    public static AdRequestConfiguration buildConfiguration(Context context, MethodCall call, String placementId) {
        AdRequestConfiguration.Builder builder = AdRequestConfiguration.Companion.builder(context, placementId);

        Object targeting = call.argument("customTargetArgs");
        if (targeting instanceof Map) {
            for (Map.Entry<?, ?> entry : ((Map<?, ?>) targeting).entrySet()) {
                if (entry.getKey() == null || entry.getValue() == null) {
                    continue;
                }
                String key = entry.getKey().toString();
                Object value = entry.getValue();
                if (value instanceof List) {
                    List<String> values = new ArrayList<>();
                    for (Object item : (List<?>) value) {
                        if (item != null) {
                            values.add(item.toString());
                        }
                    }
                    builder.addCustomTargetingValue(key, values);
                } else {
                    builder.addCustomTargetingValue(key, value.toString());
                }
            }
        }

        String publisherProvidedId = call.argument("publisherProvidedId");
        if (publisherProvidedId != null && !publisherProvidedId.isEmpty()) {
            builder.publisherProvidedId(publisherProvidedId);
        }

        return builder.build();
    }
}
