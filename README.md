# 🚀 Adster Flutter SDK Example

This Flutter project demonstrates the integration of the `adster_flutter_sdk` for showing various ad formats including:

- Banner Ads
- Native Ads
- Interstitial Ads
- Rewarded Ads
- App open (Beta)

---

## 📱 Android Setup

### 🔐 Authentication Setup for Adster Orchestration SDK

To securely access the native Adster SDK hosted on GitHub Packages, your project must provide authentication credentials. These are required to fetch the sdk from our private Maven repository.

#### 📦 Step 1: Add Maven Credentials

You can provide the credentials in **either of two ways**:

##### 🔧 Option A: Add to `gradle.properties`

Add the following lines to either your project’s `android/gradle.properties` file **or** your global `~/.gradle/gradle.properties`:

```properties
adsterMavenUsername=YOUR_GITHUB_USERNAME
adsterMavenPassword=YOUR_PERSONAL_ACCESS_TOKEN
```

> 💡 You can generate a [GitHub Personal Access Token (classic)](https://github.com/settings/tokens?type=beta) with `read:packages` and `repo` scopes.

##### 🌐 Option B: Use Environment Variables (ideal for CI/CD)

Alternatively, you can export these environment variables in your terminal or CI setup:

```bash
export ADSTER_MAVEN_USERNAME=YOUR_GITHUB_USERNAME
export ADSTER_MAVEN_PASSWORD=YOUR_PERSONAL_ACCESS_TOKEN
```

---

#### ⚠️ Build Fails Without Credentials

If credentials are not set, the build will fail fast with a clear error message:

```text
❗ Missing Adster Maven credentials.
Please set 'adsterMavenUsername' and 'adsterMavenPassword'
in gradle.properties or as environment variables.
```

#### ✅ That's It!

Once credentials are provided, the Flutter plugin will be able to fetch and integrate the native orchestration SDK seamlessly.

If you face any issues, feel free to contact [support@adster.tech](mailto:support@adster.tech).

---

### ✅ Manifest Changes Required for SDK

Please add the following permissions to your Android `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="com.google.android.gms.permission.AD_ID"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

If you don’t have an AdMob account and want to test SDK initialization, also add:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-7640426597645136~3443205346" />
```



---

## 🍏 iOS Setup

This framework depends on RealmSwift. Please install RealmSwift via Swift Package Manager - https://github.com/realm/realm-swift.git

#### ⚠️ Important: Adding RealmSwift to Runner

When adding the Realm package to the Runner target in Xcode,
👉 select only _RealmSwift_.

Do not select Realm directly — RealmSwift already includes it.
This avoids duplicate linking issues and ensures the app builds and runs correctly.

#### Check that RealmSwift in “Frameworks, Libraries, and Embedded Content”
- Open your project in Xcode.
- Go to Runner target → General tab.
- Scroll to Frameworks, Libraries, and Embedded Content.
- Ensure both Realm.framework and RealmSwift.framework are listed.
- Set them to Embed & Sign (not just Do Not Embed).

Mofify the iOS/Podfile:
```shell
use_frameworks! :linkage => :static
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