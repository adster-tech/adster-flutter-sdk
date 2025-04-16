package com.adster.sdk.mediation

import android.app.Application
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.Typeface
import android.net.Uri
import android.util.AttributeSet
import android.util.Log
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import android.widget.TextView
import android.widget.Toast
import androidx.core.view.setPadding
import com.adster.sdk.mediation.util.log


class MediationNativeAdView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
) : FrameLayout(context, attrs, defStyleAttr), View.OnClickListener {

    var headlineView: View? = null
    var bodyView: View? = null
    var ctaView: View? = null
    var logoView: View? = null
    var mediaView: View? = null
    var advertiserView: View? = null
    var ratingBarView: View? = null


    var nativeAd: MediationNativeAd? = null
        set(value) {
            field = value
            if(value?.overrideClickHandling == true) return
            setOnClickListener(this)
            headlineView?.setOnClickListener(this)
            bodyView?.setOnClickListener(this)
            ctaView?.setOnClickListener(this)
            logoView?.setOnClickListener(this)
            mediaView?.setOnClickListener(this)
            advertiserView?.setOnClickListener(this)
            ratingBarView?.setOnClickListener(this)
        }

    private fun recordImpression() {
        if(nativeAd?.overrideImpressionHandling == true) return
        nativeAd?.recordImpression()
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        if (nativeAd?.dspBranding != null) attachAdChoices()
        recordImpression()
    }

    private fun attachAdChoices() {
        val adChoiceTv = TextView(context).apply {
            setBackgroundColor(Color.parseColor("#F1F1F1"))
            text = "Ad"
            setTextColor(Color.BLACK)
            setTypeface(null, Typeface.ITALIC)
            textSize = 12F
            setPadding(6)
            setOnClickListener {
                try {
                    context.startActivity(
                        Intent(
                            Intent.ACTION_VIEW,
                            Uri.parse(nativeAd?.dspBranding?.landing)
                        ).apply {
                            flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        })
                } catch (e: ActivityNotFoundException) {
                    Toast.makeText(context, "Unable to open activity", Toast.LENGTH_SHORT).show()
                }
            }
        }

        val adChoiceParams = LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT)
        positionImageView(adChoiceParams, adChoiceTv, nativeAd?.dspBranding?.position)
    }

    private fun positionImageView(
        layoutParams: LayoutParams,
        textview: TextView,
        position: String?
    ) {
        layoutParams.gravity = when (position) {
            "top-left" -> Gravity.TOP or Gravity.START
            "top-right" -> Gravity.TOP or Gravity.END
            "bottom-left" -> Gravity.BOTTOM or Gravity.START
            "bottom-right" -> Gravity.BOTTOM or Gravity.END
            else -> Gravity.TOP or Gravity.START
        }

        this.addView(textview, layoutParams)
    }

    override fun onClick(v: View?) {
        try {
            nativeAd?.landingUrl?.let {
                if(it.isBlank()) return@let
                val browserIntent = Intent(Intent.ACTION_VIEW, Uri.parse(it))
                if(context is Application) browserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(browserIntent)
                nativeAd?.recordClicks()
            }
        } catch (e:Exception){
            e.message?.log("onClick exception")
        }

    }
}

object NativeAdViewConstants {
    const val WIDGET_HEADLINE = "headline"
    const val WIDGET_BODY = "body"
    const val WIDGET_ICON = "icon"
    const val WIDGET_CTA = "cta"
    const val WIDGET_ADVERTISER = "advertiser"
}