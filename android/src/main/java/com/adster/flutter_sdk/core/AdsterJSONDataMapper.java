package com.adster.flutter_sdk.core;

import androidx.annotation.NonNull;

import com.adster.sdk.mediation.MediationNativeAd;
import com.adster.sdk.mediation.adster.DSPBranding;

import org.json.JSONException;
import org.json.JSONObject;

public class AdsterJSONDataMapper {
    public String toJSONStr(MediationNativeAd mediationNativeAd) throws JSONException {
        JSONObject object = new JSONObject();
        object.put("advertiser", mediationNativeAd.getAdvertiser());
        object.put("body", mediationNativeAd.getBody());
        object.put("callToAction", mediationNativeAd.getCallToAction());
        object.put("headLine", mediationNativeAd.getHeadLine());
        object.put("imageURL", mediationNativeAd.getImageURL());
        object.put("landingUrl", mediationNativeAd.getLandingUrl());
        object.put("logo", mediationNativeAd.getLogo());
        object.put("overrideClickHandling", mediationNativeAd.getOverrideClickHandling());
        object.put("overrideImpressionHandling", mediationNativeAd.getOverrideImpressionHandling());
        object.put("starRating", mediationNativeAd.getStarRating());

        if (mediationNativeAd.getDspBranding() != null) {
            JSONObject objectDSPBranding = getDSPBrandingJSONObject(mediationNativeAd.getDspBranding());
            object.put("dspBranding", objectDSPBranding);
        }
        return object.toString();
    }

    @NonNull
    private JSONObject getDSPBrandingJSONObject(DSPBranding dspBranding) throws JSONException {
        JSONObject jsonObjectDSPBranding = new JSONObject();
        jsonObjectDSPBranding.put("component1", dspBranding.component1());
        jsonObjectDSPBranding.put("component2", dspBranding.component2());
        jsonObjectDSPBranding.put("component3", dspBranding.component3());
        jsonObjectDSPBranding.put("component4", dspBranding.component4());
        jsonObjectDSPBranding.put("component5", dspBranding.component5());
        jsonObjectDSPBranding.put("imageUrl", dspBranding.getImageUrl());
        jsonObjectDSPBranding.put("landing", dspBranding.getLanding());
        jsonObjectDSPBranding.put("partner", dspBranding.getPartner());
        jsonObjectDSPBranding.put("position", dspBranding.getPosition());
        return jsonObjectDSPBranding;
    }
}
