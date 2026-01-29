# 🚀 Adster Flutter SDK Example

This Flutter project demonstrates the integration of the `adster_flutter_sdk` for showing various ad formats including:

- Banner Ads
- Native Ads
- Interstitial Ads
- Rewarded Ads
- App open (Beta)

---

## 📱 Android Setup

### 🔐 Make sure `mavenCentral()` is enabled

Most Flutter Android projects already include this, but if your project is older, ensure your repositories include **mavenCentral**.

**Gradle (recommended, `android/settings.gradle`)**
```
dependencyResolutionManagement {
  repositories {
    google()
    mavenCentral()
  }
}
```

**OR android/build.gradle**

```
allprojects {
  repositories {
    google()
    mavenCentral()
  }
}
```

#### ✅ That's It!

If you face any issues, feel free to contact [support@adster.tech](mailto:support@adster.tech).

---

### ✅ Manifest Changes Required for SDK

Please add the following permissions to your Android `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="com.google.android.gms.permission.AD_ID"/>
```

If you don’t have an AdMob account and want to test SDK initialization, also add:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-7640426597645136~3443205346" />
```



---

## 🍏 iOS Setup

### ✅ Info.plist Changes Required for SDK

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~3347511713</string>
```

Run the following command in the terminal:
```shell
pod install
```

---


## 📐 Banner Ads

### 📏 Banner Ad Sizes

| Adster Ad Size       | Dimensions (WxH)  |
|----------------------|------------------|
| `AdsterAdSize.small` | 320 x 50         |
| `AdsterAdSize.medium`| 300 x 250        |
| `AdsterAdSize.custom`| Custom (w x h)   |

### ✅ Example Usage

```dart
import 'package:adster_flutter_sdk/adster_flutter_sdk.dart';

AdsterBannerAd(
  adPlacementName: "adster_banner_320x50",
  adSize: AdsterAdSize.small,
  loadingWidget: SizedBox(
    width: AdsterAdSize.small.width,
    height: AdsterAdSize.small.height,
    child: Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 10),
          Text("Loading...."),
        ],
      ),
    ),
  ),
  onFailure: (AdsterAdsException error) {
    return Text("Banner not loaded: ${error.message}");
  },
);
```

---

## 🎨 Native Ads

### 📏  Native Ad Click Type

| Type of component to be tracked by GAM (Only available in Android) |
|--------------------------------------------------------------------|
| `AdsterNativeAdClickComponent.body`                                |
| `AdsterNativeAdClickComponent.callToAction`                        |
| `AdsterNativeAdClickComponent.headline`                            |
| `AdsterNativeAdClickComponent.logo`                                |
| `AdsterNativeAdClickComponent.ratingBar`                           |

### ✅ Example Usage

```dart
AdsterNativeAd(
  adPlacementName: "adster_native_test",
  onAdLoaded: (value, widget, clickHandler) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
          SizedBox(width: 10),
          Expanded(child: widget),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Row(
                    children: [
                      CachedNetworkImage(
                        imageUrl: value.imageUrl ?? "",
                        placeholder:
                            (context, url) =>
                                CircularProgressIndicator(),
                        errorWidget:
                            (context, url, error) =>
                                Icon(Icons.error),
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: InkWell(
                          onTap: () {
                            clickHandler.call(
                              AdsterNativeAdClickComponent
                                  .headline,
                            );
                          },
                          child: Text(
                            value.headLine ?? "",
                            maxLines: 2,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  InkWell(
                    onTap: () {
                      clickHandler.call(
                        AdsterNativeAdClickComponent.body,
                      );
                    },
                    child: Text(value.body ?? ""),
                  ),
                  SizedBox(height: 5),
                  MaterialButton(
                    onPressed: () {
                      clickHandler.call(
                        AdsterNativeAdClickComponent
                            .callToAction,
                      );
                    },
                    color: Colors.grey,
                    child: Text(value.callToAction ?? ""),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  },
  onFailure: (AdsterAdsException error) {
    return Text(error.message ?? "");
  },
  clickCallback: getNativeAdCallback(),
)
```

---

## 🎨 Interstitial Ads

### ✅ Example Usage

```dart
AdsterInterstitialAds() interstitialAds = AdsterInterstitialAds();
interstitialAds.loadInterstitialAd(
    adPlacementName: "adster_interstitial_test",
      callback: getInterstitialAdCallback(),
    )
    .then((value) {
      if (value) {
          interstitialAds.showInterstitialAd();
      }
    })
    .onError((error, stackTrace) {
      print(error);
});
```

---

## 🎨 Rewarded Ads

### ✅ Example Usage

```dart
AdsterRewardedAds rewardedAds = AdsterRewardedAds();
rewardedAds.loadRewardedAd(adPlacementName: "adster_rewarded_test")
  .then((value) {
      if (value) {
        rewardedAds.showRewardedAd();
      }
  })
  .onError((error, stackTrace) {
    print(error);
});
```

---

## 🎨 App Opened Ads

### ✅ Example Usage

```dart
AdsterAppOpenedAds appOpenedAds = AdsterAppOpenedAds();
appOpenedAds
    .loadAd(adPlacementName: "adster_app_opened_test")
    .then((value) {
      ///Ad loaded and shown
      print("onAppOpenAdLoaded");
    })
    .onError((error, stackTrace) {
      ///Ad failed to load
      print("onFailure: $error");
  });
```

---

## 🎨 Unified Ads

### ✅ Example Usage

```dart
AdsterUnifiedAd(
  adPlacementName: "adster_unified_test",
  bannerAdSize: AdsterAdSize.medium,
  unifiedAdClickCallback: controller.getUnifiedAdCallback(
    AdsterAdSize.medium.toString(),
  ),
  onBannerAdLoaded: (bannerView) {
    return bannerView;
  },
  onNativeAdLoaded: (value, nativeMediaView, clickHandler) {
    return SizedBox(
      height: 200,
      child: Row(
        children: [
        SizedBox(width: 10),
        Expanded(child: nativeMediaView),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                SizedBox(height: 10),
                Row(
                  children: [
                  CachedNetworkImage(
                    imageUrl: value.imageUrl ?? "",
                    height: 40,
                    width: 40,
                    placeholder:
                    (context, url) =>
                      CircularProgressIndicator(),
                    errorWidget:
                    (context, url, error) => Icon(Icons.error),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: InkWell(
                      onTap: () {
                        clickHandler.call(
                          AdsterNativeAdClickComponent.headline,
                        );
                      },
                      child: Text(
                        value.headLine ?? "",
                        maxLines: 2,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
                ),
                SizedBox(height: 5),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      clickHandler.call(
                        AdsterNativeAdClickComponent.body,
                      );
                    },
                    child: Text(
                      value.body ?? "",
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                MaterialButton(
                  onPressed: () {
                    clickHandler.call(
                      AdsterNativeAdClickComponent.callToAction,
                    );
                  },
                  color: Colors.grey,
                  child: Text(value.callToAction ?? ""),
                ),
              ],
              ),
                    ),
                  ),
                ],
              ),
            );
          },
  onFailure: (error) {
    return Text("Unified not loaded: ${error.message} (${error.code})");
  },
)
```

## 🔒 License

This project is licensed under the MIT License.  
See the [LICENSE](https://pub.dev/packages/adster_flutter_sdk/license) file for details.